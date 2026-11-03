#!/usr/bin/env python3
"""Compute, stamp and publish Helm chart versions.

Chart versions are frozen at a placeholder (0.0.0) in git. The real version is
derived from the existing ``<chart>-X.Y.Z`` git tags at release time and stamped
into a throwaway working tree just before packaging, so nothing is hardcoded in
the repo and nothing has to be bumped in a PR.

Subcommands:

    plan    --base SHA --head SHA    compute the publish set; no side effects
    stamp   --plan plan.json         rewrite Chart.yaml versions in the worktree
    publish --plan plan.json         package charts and upload releases + index

``plan`` is pure so that PR CI can run the exact same code path as the release
job to preview what a merge would publish.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict, deque
from pathlib import Path

import yaml

HELM_DIR = Path("helm")
PLACEHOLDER = "0.0.0"
BASE_VERSION = "0.1.0"
FILE_PREFIX = "file://"

# Anchored on exactly three numeric components so that the chart name is
# captured in full. Keying on the full name is what keeps `gen3-workflow-0.1.29`
# from being read as a `gen3` tag -- a `gen3-*` glob matches 7 different charts.
TAG_RE = re.compile(r"^(?P<name>.+)-(?P<version>\d+\.\d+\.\d+)$")


# --------------------------------------------------------------------------
# git helpers
# --------------------------------------------------------------------------


def git(*args: str, check: bool = True) -> str:
    proc = subprocess.run(
        ["git", *args], capture_output=True, text=True, check=False
    )
    if check and proc.returncode != 0:
        raise SystemExit(f"git {' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout.strip()


def rev_exists(rev: str) -> bool:
    return (
        subprocess.run(
            ["git", "cat-file", "-e", f"{rev}^{{commit}}"],
            capture_output=True,
        ).returncode
        == 0
    )


def is_ancestor(a: str, b: str) -> bool:
    return (
        subprocess.run(
            ["git", "merge-base", "--is-ancestor", a, b], capture_output=True
        ).returncode
        == 0
    )


def resolve_base(before: str | None, head: str) -> str | None:
    """Pick the ref to diff against for a push event.

    Returns None when no trustworthy base exists. Callers must treat that as a
    hard error rather than silently falling back to "publish everything" -- an
    accidental ~50-chart release burst is far worse than a skipped run, and a
    skipped run self-heals on the next merge.
    """
    if not before or set(before) == {"0"}:
        return None  # branch creation / initial push
    if not rev_exists(before):
        return None  # garbage collected after a force-push
    if not is_ancestor(before, head):
        # Force-push: `before..head` would silently under-report.
        merge_base = git("merge-base", before, head, check=False)
        if merge_base:
            return merge_base
        parent = git("rev-parse", f"{head}^1", check=False)
        return parent or None
    return before


def changed_paths(base: str, head: str) -> list[str]:
    out = git("diff", "--name-only", f"{base}..{head}")
    return [line for line in out.splitlines() if line.strip()]


# --------------------------------------------------------------------------
# chart discovery and dependency graph
# --------------------------------------------------------------------------


def load_charts() -> dict[str, dict]:
    """Map chart *name* -> {dir, meta}.

    Keyed on the declared ``name:``, never the directory: helm/observability
    declares ``name: lgtma-chart`` and owns the ``lgtma-chart-*`` tag line.
    """
    charts: dict[str, dict] = {}
    for chart_yaml in sorted(HELM_DIR.glob("*/Chart.yaml")):
        meta = yaml.safe_load(chart_yaml.read_text()) or {}
        name = meta.get("name")
        if not name:
            raise SystemExit(f"{chart_yaml} has no name:")
        if name in charts:
            # Turns a silent clobber (two charts publishing under one name,
            # last writer wins) into a loud failure.
            raise SystemExit(
                f"duplicate chart name {name!r}: "
                f"{charts[name]['dir']} and {chart_yaml.parent}"
            )
        charts[name] = {"dir": chart_yaml.parent, "meta": meta}
    return charts


def local_dep_target(dep: dict, chart_dir: Path, charts: dict[str, dict]) -> str | None:
    """Resolve a file:// dependency to a chart name, by path.

    The path is authoritative; the dep's own ``name:`` field is only checked for
    consistency.
    """
    repo = str(dep.get("repository") or "")
    if not repo.startswith(FILE_PREFIX):
        return None
    target_dir = (chart_dir / repo[len(FILE_PREFIX) :]).resolve()
    for name, chart in charts.items():
        if chart["dir"].resolve() == target_dir:
            declared = dep.get("name")
            if declared and declared != name:
                raise SystemExit(
                    f"{chart_dir}/Chart.yaml declares dependency name "
                    f"{declared!r} but {repo} resolves to chart {name!r}"
                )
            return name
    raise SystemExit(f"{chart_dir}/Chart.yaml: {repo} does not resolve to a chart")


def reverse_deps(charts: dict[str, dict]) -> dict[str, set[str]]:
    """dep name -> set of charts that depend on it (file:// edges only)."""
    rdeps: dict[str, set[str]] = defaultdict(set)
    for name, chart in charts.items():
        for dep in chart["meta"].get("dependencies") or []:
            target = local_dep_target(dep, chart["dir"], charts)
            if target:
                rdeps[target].add(name)
    return rdeps


def transitive_closure(seeds: set[str], rdeps: dict[str, set[str]]) -> set[str]:
    seen = set(seeds)
    queue = deque(seeds)
    while queue:
        for parent in rdeps.get(queue.popleft(), ()):
            if parent not in seen:
                seen.add(parent)
                queue.append(parent)
    return seen


def charts_from_paths(paths: list[str], charts: dict[str, dict]) -> set[str]:
    """Map changed file paths to chart names via their helm/<dir>/ component."""
    by_dir = {chart["dir"].name: name for name, chart in charts.items()}
    touched: set[str] = set()
    for path in paths:
        parts = Path(path).parts
        if len(parts) < 3 or parts[0] != HELM_DIR.name:
            continue
        # helm/<dir>/charts/** is vendored build output, not a source change.
        if len(parts) > 2 and parts[2] == "charts":
            continue
        name = by_dir.get(parts[1])
        if name:
            touched.add(name)
    return touched


# --------------------------------------------------------------------------
# version derivation
# --------------------------------------------------------------------------


def version_key(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in version.split("."))


def tags_by_chart() -> dict[str, list[str]]:
    index: dict[str, list[str]] = defaultdict(list)
    for tag in git("tag", "--list").splitlines():
        match = TAG_RE.match(tag.strip())
        if match:
            index[match.group("name")].append(match.group("version"))
    return index


def release_exists(tag: str) -> bool:
    """Whether a GitHub release already exists for this tag.

    Only an extra guard against re-using a version after a partially failed
    run; the tag list is the primary source. Treats an unavailable gh CLI or
    missing token as "no release" rather than failing the run.
    """
    if not os.environ.get("GITHUB_TOKEN") and not os.environ.get("CR_TOKEN"):
        return False
    if shutil.which("gh") is None:
        return False
    return (
        subprocess.run(
            ["gh", "release", "view", tag], capture_output=True
        ).returncode
        == 0
    )


def next_version(name: str, index: dict[str, list[str]], check_releases: bool = False) -> str:
    versions = index.get(name)
    if not versions:
        return BASE_VERSION
    # Semantic, not lexical: sorted() would pick fence-0.1.9 over fence-0.1.82.
    highest = max(versions, key=version_key)
    major, minor, patch = version_key(highest)
    candidate = f"{major}.{minor}.{patch + 1}"
    if check_releases:
        # A prior run may have created the release but died before tagging.
        while release_exists(f"{name}-{candidate}"):
            patch += 1
            candidate = f"{major}.{minor}.{patch + 1}"
    if candidate == PLACEHOLDER:
        raise SystemExit(f"refusing to publish placeholder version for {name}")
    return candidate


# --------------------------------------------------------------------------
# stamping
# --------------------------------------------------------------------------


def stamp_version(chart_yaml: Path, version: str) -> None:
    """Rewrite the top-level version: line, preserving everything else.

    Dependency versions are indented, so anchoring at column 0 is unambiguous.
    A line-oriented edit keeps the explanatory comment blocks intact.
    """
    text = chart_yaml.read_text()
    new_text, count = re.subn(
        r"^version:.*$", f"version: {version}", text, count=1, flags=re.M
    )
    if count != 1:
        raise SystemExit(f"{chart_yaml}: expected exactly one top-level version:")
    chart_yaml.write_text(new_text)


def stamp_dependencies(chart_yaml: Path, versions: dict[str, str], charts: dict[str, dict]) -> None:
    """Point each file:// dependency at the version we are about to publish.

    Not required for resolution -- Chart.lock and the vendored subchart copies
    already carry concrete versions -- but `helm show chart` is what consumers
    read, and "*" tells them nothing.
    """
    meta = yaml.safe_load(chart_yaml.read_text()) or {}
    deps = meta.get("dependencies") or []
    if not deps:
        return
    chart_dir = chart_yaml.parent
    lines = chart_yaml.read_text().splitlines(keepends=True)

    # Walk the dependency list textually so comments and key order survive.
    current: str | None = None
    for i, line in enumerate(lines):
        name_match = re.match(r"^\s*-\s+name:\s*(\S+)", line)
        if name_match:
            current = name_match.group(1)
            continue
        version_match = re.match(r"^(\s+version:\s*)(\S+)(.*)$", line)
        if version_match and current:
            dep = next((d for d in deps if d.get("name") == current), None)
            if dep is None:
                continue
            target = local_dep_target(dep, chart_dir, charts)
            if target and target in versions:
                lines[i] = f"{version_match.group(1)}{versions[target]}\n"
            current = None
    chart_yaml.write_text("".join(lines))


# --------------------------------------------------------------------------
# subcommands
# --------------------------------------------------------------------------


def build_plan(base: str | None, head: str, all_charts: bool) -> dict:
    charts = load_charts()
    rdeps = reverse_deps(charts)

    if all_charts:
        selected = set(charts)
        directly = selected
    else:
        if base is None:
            raise SystemExit(
                "could not determine a trustworthy base commit (initial push, "
                "force-push, or gc'd ref). Re-run via workflow_dispatch with an "
                "explicit --base, or pass --all deliberately."
            )
        directly = charts_from_paths(changed_paths(base, head), charts)
        selected = transitive_closure(directly, rdeps)

    index = tags_by_chart()
    entries = []
    for name in sorted(selected):
        entries.append(
            {
                "name": name,
                "dir": str(charts[name]["dir"]),
                "version": next_version(name, index),
                "previous": max(index.get(name, ["-"]), key=lambda v: version_key(v))
                if index.get(name)
                else None,
                "direct": name in directly,
            }
        )

    # Charts that are not being released but get vendored into one that is.
    # They still need a real version stamped in: an umbrella packaged with
    # unstamped subcharts ships them at the 0.0.0 placeholder, and its own
    # dependency block keeps the "*" constraint. Their current version is the
    # newest existing tag -- they have not changed, so nothing is incremented.
    vendored = []
    for name in sorted(set(charts) - selected):
        versions = index.get(name)
        vendored.append(
            {
                "name": name,
                "dir": str(charts[name]["dir"]),
                "version": max(versions, key=version_key)
                if versions
                else BASE_VERSION,
            }
        )
    return {"base": base, "head": head, "charts": entries, "vendored": vendored}


def cmd_plan(args: argparse.Namespace) -> int:
    base = args.base
    if base is None and not args.all:
        base = resolve_base(os.environ.get("GITHUB_EVENT_BEFORE"), args.head)
    plan = build_plan(base, args.head, args.all)

    if args.markdown:
        entries = plan["charts"]
        if not entries:
            print("## Chart releases\n\nNo charts would be published by this change.")
            return 0
        cascaded = sum(1 for e in entries if not e["direct"])
        print(f"## Chart releases ({len(entries)} charts)\n")
        if cascaded:
            print(
                f"{len(entries) - cascaded} directly changed, "
                f"{cascaded} cascaded via dependencies.\n"
            )
        print("| Chart | Current | Would publish | Reason |")
        print("| --- | --- | --- | --- |")
        for e in entries:
            reason = "changed" if e["direct"] else "depends on a changed chart"
            print(f"| {e['name']} | {e['previous'] or '-'} | {e['version']} | {reason} |")
    else:
        print(json.dumps(plan, indent=2))

    if args.output:
        Path(args.output).write_text(json.dumps(plan, indent=2))
    return 0


def cmd_stamp(args: argparse.Namespace) -> int:
    plan = json.loads(Path(args.plan).read_text())
    charts = load_charts()
    # Stamp released and merely-vendored charts alike. A released umbrella
    # vendors its whole dependency tree, so any subchart left at the
    # placeholder would ship inside it as 0.0.0.
    everything = plan["charts"] + plan.get("vendored", [])
    versions = {e["name"]: e["version"] for e in everything}

    for entry in everything:
        stamp_version(Path(entry["dir"]) / "Chart.yaml", entry["version"])
    # Second pass, once every version is known: rewrite the "*" constraints so
    # the published Chart.yaml records concrete versions.
    for entry in everything:
        stamp_dependencies(Path(entry["dir"]) / "Chart.yaml", versions, charts)

    for entry in plan["charts"]:
        print(f"stamped {entry['name']} -> {entry['version']} (releasing)")
    print(f"stamped {len(plan.get('vendored', []))} more charts at their current version")
    return 0


def count_index_versions(
    pages_branch: str, index_path: str, fetch: bool = False
) -> int | None:
    """Total chart versions listed in the published index.yaml.

    Used to assert the index never shrinks: it carries ~1700 versions, and
    replacing rather than merging it would break every consumer pinned to an
    older release. Returns None if the index can't be read, so a missing branch
    doesn't fail the run on its own.
    """
    if fetch:
        subprocess.run(
            ["git", "fetch", "origin", pages_branch], capture_output=True
        )
    for ref in (f"origin/{pages_branch}", pages_branch):
        raw = git("show", f"{ref}:{index_path}", check=False)
        if raw:
            entries = (yaml.safe_load(raw) or {}).get("entries") or {}
            return sum(len(v or []) for v in entries.values())
    return None


def clean_vendored(chart_dir: Path) -> None:
    """Remove build artifacts so each package is resolved from a clean slate.

    Both the chart's own charts/ dir and any nested ones left by a sibling's
    earlier `dependency update`. Chart.lock goes too, since a stale lock makes
    `dependency build` resolve the wrong versions.
    """
    for path in [chart_dir / "charts", *chart_dir.glob("charts/*/charts")]:
        if path.is_dir():
            shutil.rmtree(path)
    lock = chart_dir / "Chart.lock"
    if lock.exists():
        lock.unlink()


def cmd_publish(args: argparse.Namespace) -> int:
    plan = json.loads(Path(args.plan).read_text())
    packages = Path(args.packages)
    packages.mkdir(parents=True, exist_ok=True)

    for entry in plan["charts"]:
        chart_dir = Path(entry["dir"])
        # Resolve dependencies immediately before packaging this chart, and
        # clean first. Leftover charts/ dirs from a previous chart's resolution
        # get vendored a second level deep (e.g. gen3/charts/fence/charts/common),
        # and the nested copy shadows the parent's global values at render time.
        clean_vendored(chart_dir)
        # Always `update`: despite the !helm/funnel/charts gitignore exception,
        # no helm/*/charts/* files are actually tracked, so there are no
        # committed tarballs to preserve and the lock file may be stale.
        subprocess.run(["helm", "dependency", "update", str(chart_dir)], check=True)
        subprocess.run(
            ["helm", "package", str(chart_dir), "-d", str(packages)], check=True
        )
        # Don't leave this chart's vendored deps behind for the next one.
        clean_vendored(chart_dir)
        print(f"packaged {entry['name']}-{entry['version']}")

    if args.package_only:
        return 0

    owner, repo = args.repo.split("/", 1)
    subprocess.run(
        [
            "cr", "upload",
            "-o", owner,
            "-r", repo,
            "--package-path", str(packages),
            "--skip-existing",
            "--make-release-latest=false",
        ],
        check=True,
    )
    before = count_index_versions(args.pages_branch, args.index_path)
    subprocess.run(
        [
            "cr", "index",
            "-o", owner,
            "-r", repo,
            "--package-path", str(packages),
            "--index-path", args.index_path,
            "--pages-branch", args.pages_branch,
            "--push",
        ],
        check=True,
    )
    after = count_index_versions(args.pages_branch, args.index_path, fetch=True)
    if before is not None and after is not None and after < before:
        raise SystemExit(
            f"index shrank {before} -> {after} versions; the published repo has "
            "lost entries and consumers pinning old versions will break"
        )
    print(f"index versions: {before} -> {after}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("plan", help="compute the publish set (no side effects)")
    p.add_argument("--base")
    p.add_argument("--head", default="HEAD")
    p.add_argument("--all", action="store_true", help="select every chart")
    p.add_argument("--markdown", action="store_true")
    p.add_argument("--output")
    p.set_defaults(func=cmd_plan)

    s = sub.add_parser("stamp", help="write real versions into the working tree")
    s.add_argument("--plan", required=True)
    s.set_defaults(func=cmd_stamp)

    u = sub.add_parser("publish", help="package and upload")
    u.add_argument("--plan", required=True)
    u.add_argument("--repo", default="uc-cdis/gen3-helm")
    u.add_argument("--packages", default=".cr-release-packages")
    u.add_argument("--index-path", default="index.yaml")
    u.add_argument("--pages-branch", default="gh-pages")
    u.add_argument("--package-only", action="store_true")
    u.set_defaults(func=cmd_publish)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
