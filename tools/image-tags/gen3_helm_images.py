#!/usr/bin/env python3
"""Report the container image used by each chart in uc-cdis/gen3-helm.

Reads helm/<chart>/values.yaml (image.repository, image.tag) and Chart.yaml
(appVersion), lists charts whose deployed tag is not main/master (an empty
tag deploys the chart's appVersion), and flags unquoted tags that YAML or
Helm may read as something other than text.

Examples:
    gen3_helm_images.py                      # fetch master from GitHub
    gen3_helm_images.py --ref some-branch
    gen3_helm_images.py --local ./gen3-helm  # use a local clone
    gen3_helm_images.py --json               # machine-readable output
    gen3_helm_images.py --check              # CI: fail on tags Helm may misread
    gen3_helm_images.py --check unquoted     # CI: fail on any unquoted tag

Exit codes:
    0  success (and --check found nothing)
    1  --check found problem tags
    2  error: bad arguments, download failure, no charts found

Requires Python 3.10+, PyYAML and requests (see requirements.txt).
"""

# Design notes for maintainers
# ----------------------------
# * This module is also a library. weekly_slack_report.py and image_ages.py
#   import load_images(), ChartImage, effective_tag(), non_default_tag_charts(),
#   ChartLoadError and the DEFAULT_*/EXIT_* constants. Keep those names stable,
#   or update all three files together.
# * YAML is read as a *node tree* (yaml.SafeLoader.get_single_node), not with
#   yaml.safe_load. Loading converts values (2025.10 -> 2025.1, 010 -> 8) and
#   throws away quote style; nodes keep the exact source text, quote style and
#   line number, which is what this tool reports on.
# * "Ambiguous" means "Helm might not deploy the tag as written". Helm parses
#   YAML with a Go library whose rules differ from PyYAML's, so the check
#   combines both (see _is_ambiguous). It errs toward flagging: the fix,
#   quoting the tag, is always safe.
# * Empty tags: the gen3 templates render `.Values.image.tag | default
#   .Chart.AppVersion`, so an empty tag deploys the chart's appVersion.
#   effective_tag() applies that rule; everything that asks "what's deployed?"
#   goes through it. appVersion itself isn't checked for quoting here: that's
#   Chart.yaml hygiene, enforced in gen3-helm's "Lint and Test Charts" workflow
#   by a custom chart-testing schema (.github/chart_schema.yaml).
# * The JSON output (--json) is consumed by the GitHub Actions workflow. Adding
#   fields is fine; renaming or removing them needs a workflow update.

from __future__ import annotations

import argparse
import io
import json
import logging
import re
import sys
import tarfile
from collections.abc import Iterable, Iterator
from dataclasses import asdict, dataclass
from pathlib import Path, PurePosixPath
from urllib.parse import quote

import requests
import yaml

log = logging.getLogger(__name__)

# codeload serves a .tar.gz of any branch, tag or commit with one request and,
# unlike the GitHub REST API, has no 60-requests-per-hour anonymous limit.
TARBALL_URL = "https://codeload.github.com/uc-cdis/gen3-helm/tar.gz/{ref}"
DEFAULT_REF = "master"  # gen3-helm's default branch; change here if it's renamed
DEFAULT_BRANCH_TAGS = frozenset({"main", "master"})
REQUEST_TIMEOUT_S = 60  # applies to connecting and to each read, not the total

# Same convention as grep and ruff; argparse already exits 2 on bad arguments.
EXIT_OK, EXIT_CHECK_FAILED, EXIT_ERROR = 0, 1, 2

# YAML tags that PyYAML's resolver assigns to plain (unquoted) scalars.
YAML_STR = "tag:yaml.org,2002:str"
YAML_NULL = "tag:yaml.org,2002:null"
QUOTE_STYLES = frozenset({'"', "'"})  # node.style for 'single' and "double" quotes
# Helm's Go YAML parser reads these as numbers even where PyYAML (YAML 1.1)
# keeps them as text, e.g. 1e3, or a short commit SHA that happens to be
# digits plus one "e", like 7e10.
# Underscores are allowed because the Go parser strips them before parsing.
GO_NUMBER = re.compile(r"[-+]?(\d[\d_]*\.?[\d_]*|\.\d[\d_]*)([eE][-+]?\d+)?")

# One chart's files as (chart_name, values_yaml_text, chart_yaml_text or None).
ChartFiles = tuple[str, str, str | None]


class ChartLoadError(Exception):
    """The charts could not be loaded (network, archive, file or encoding error)."""


@dataclass(frozen=True, slots=True)
class ChartImage:
    """Image settings for one chart, with tags exactly as written in the file.

    Field order and names are part of the --json output (via asdict).
    """

    chart: str
    repository: str | None
    tag: str | None
    # True for 'single' or "double" quotes. None when there is no tag. Block
    # scalars (tag: |) count as unquoted here but are never ambiguous, since
    # YAML always reads them as text.
    tag_quoted: bool | None = None
    # Unquoted and may be read as a number, boolean or date rather than text
    # (e.g. 2025.10 -> 2025.1). Errs toward flagging; quoting is always safe.
    tag_ambiguous: bool = False
    # 1-based line of the tag in values.yaml. If the tag comes from an anchor
    # or merge key, this is where the anchored value is written.
    tag_line: int | None = None
    # appVersion from Chart.yaml, as written. Charts whose templates use
    # `.Values.image.tag | default .Chart.AppVersion` deploy this when the
    # tag is empty (true of every empty-tag gen3 chart as of Nov 2026).
    app_version: str | None = None


# --- Sources ----------------------------------------------------------------
# Each source yields ChartFiles tuples, one per chart that has a values.yaml.
# To add one (e.g. a git checkout at a specific commit), write another
# generator with that shape.

CHART_FILENAMES = ("values.yaml", "Chart.yaml")


def iter_github_charts(ref: str) -> Iterator[ChartFiles]:
    """Download the repo tarball (~2 MB) and yield each chart's files."""
    # quote() keeps "/" so branches like feature/x work, but encodes characters
    # git allows in branch names that would break a URL (#, %, spaces).
    url = TARBALL_URL.format(ref=quote(ref, safe="/"))
    # Read via resp.content rather than streaming resp.raw: errors from the
    # raw urllib3 stream bypass requests' exception types.
    resp = requests.get(url, timeout=REQUEST_TIMEOUT_S)
    resp.raise_for_status()
    # Archive order is arbitrary, so gather each chart's files before yielding.
    found: dict[str, dict[str, str]] = {}
    with tarfile.open(fileobj=io.BytesIO(resp.content), mode="r:gz") as tar:
        for member in tar:
            # Layout: <repo>-<ref>/helm/<chart>/<file>. Requiring exactly four
            # parts skips subcharts (helm/<chart>/charts/...) and the
            # pax_global_header entry GitHub adds. Members are only read, never
            # extracted, so hostile paths in the archive can't touch the disk.
            parts = PurePosixPath(member.name).parts
            if (member.isfile() and len(parts) == 4 and parts[1] == "helm"
                    and parts[3] in CHART_FILENAMES):
                f = tar.extractfile(member)
                if f is not None:
                    found.setdefault(parts[2], {})[parts[3]] = f.read().decode("utf-8")
    for chart, files in found.items():
        if "values.yaml" in files:  # a Chart.yaml alone isn't something we report on
            yield chart, files["values.yaml"], files.get("Chart.yaml")


def iter_local_charts(repo_root: Path) -> Iterator[ChartFiles]:
    """Yield each chart's files from a local clone."""
    helm_dir = repo_root / "helm"
    if not helm_dir.is_dir():
        raise FileNotFoundError(f"No helm/ directory under {repo_root}")
    for path in helm_dir.glob("*/values.yaml"):
        chart_yaml = path.parent / "Chart.yaml"
        yield (path.parent.name, path.read_text(encoding="utf-8"),
               chart_yaml.read_text(encoding="utf-8") if chart_yaml.is_file() else None)


# --- Parsing & analysis -----------------------------------------------------

def _child(loader: yaml.SafeLoader, node: yaml.Node | None, key: str) -> yaml.Node | None:
    """Value node for `key` in a mapping node, with the same semantics as
    yaml.load: merge keys (<<: *anchor) are applied and the last duplicate wins."""
    if not isinstance(node, yaml.MappingNode):
        return None
    # flatten_mapping is PyYAML's own merge-key logic (used by yaml.load). It
    # rewrites node.value in place, putting merged pairs before explicit ones.
    loader.flatten_mapping(node)
    for k, v in reversed(node.value):  # reversed: later keys override earlier ones
        if isinstance(k, yaml.ScalarNode) and k.value == key:
            return v
    return None


def _scalar(node: yaml.Node | None) -> yaml.ScalarNode | None:
    """The node if it is a non-null scalar, else None (covers tag:, tag: ~, tag: null)."""
    if isinstance(node, yaml.ScalarNode) and node.tag != YAML_NULL:
        return node
    return None


def _is_ambiguous(tag: yaml.ScalarNode) -> bool:
    """Unquoted, and PyYAML or Helm's Go parser would not read it as text."""
    if tag.style is not None:  # quoted or block scalar: always text
        return False
    # PyYAML resolved it to a non-string (int, float, bool, date, ...), or it
    # looks like a number to Go even though PyYAML says string (1e3, 7e10).
    return tag.tag != YAML_STR or GO_NUMBER.fullmatch(tag.value) is not None


def parse_app_version(chart: str, chart_yaml: str | None) -> str | None:
    """appVersion from Chart.yaml as written (node tree, so 1.10 stays "1.10").

    Reported as written, like tags. Quoting isn't checked here; gen3-helm's
    chart-testing schema rejects unquoted numeric appVersions (see the design
    notes).
    """
    if chart_yaml is None:
        return None
    loader = yaml.SafeLoader(chart_yaml)
    try:
        node = _scalar(_child(loader, loader.get_single_node(), "appVersion"))
    except yaml.YAMLError as exc:
        log.warning("%s: invalid Chart.yaml (%s)", chart, exc)
        return None
    finally:
        loader.dispose()
    return node.value if node else None


def parse_image(chart: str, text: str, chart_yaml: str | None = None) -> ChartImage:
    """Extract the top-level image block; missing or malformed yields None fields.

    Works on the YAML node tree rather than loaded values, so scalars keep
    their exact source text (2025.10 stays "2025.10") and their quote style.
    `chart_yaml` is the chart's Chart.yaml text, used only for app_version.
    """
    app_version = parse_app_version(chart, chart_yaml)
    loader = yaml.SafeLoader(text)
    try:
        # get_single_node raises on multi-document files (---), like safe_load.
        image = _child(loader, loader.get_single_node(), "image")
        repo = _scalar(_child(loader, image, "repository"))
        tag = _scalar(_child(loader, image, "tag"))
    except yaml.YAMLError as exc:
        # One broken chart shouldn't hide the other fifty: warn and move on.
        log.warning("%s: invalid YAML (%s)", chart, exc)
        return ChartImage(chart, None, None, app_version=app_version)
    finally:
        loader.dispose()

    return ChartImage(
        chart=chart,
        repository=repo.value if repo else None,
        tag=tag.value if tag else None,
        tag_quoted=None if tag is None else tag.style in QUOTE_STYLES,
        tag_ambiguous=tag is not None and _is_ambiguous(tag),
        tag_line=tag.start_mark.line + 1 if tag else None,  # start_mark is 0-based
        app_version=app_version,
    )


def collect_images(files: Iterable[ChartFiles]) -> dict[str, ChartImage]:
    """Map chart name -> ChartImage, sorted by chart name."""
    images = (parse_image(chart, values, chart_yaml) for chart, values, chart_yaml in files)
    return {img.chart: img for img in sorted(images, key=lambda i: i.chart)}


def load_images(*, ref: str = DEFAULT_REF, local: Path | None = None) -> dict[str, ChartImage]:
    """Load and parse every chart from a local clone or from GitHub at `ref`.

    Raises ChartLoadError for any failure, including finding no charts, so
    callers have one exception type to handle.
    """
    files = iter_local_charts(local) if local else iter_github_charts(ref)
    try:
        # The sources are generators, so download and file errors surface here.
        images = collect_images(files)
    except (requests.RequestException, tarfile.TarError, OSError, UnicodeDecodeError) as exc:
        raise ChartLoadError(f"Could not load charts: {exc}") from exc
    if not images:
        # Usually a wrong --local path or a changed repo layout. Treated as an
        # error so a scheduled job can't report "all clear" on nothing.
        raise ChartLoadError("No helm/<chart>/values.yaml files found")
    return images


def effective_tag(img: ChartImage) -> str | None:
    """The tag Helm actually deploys: the tag, or appVersion when the tag is empty.

    Mirrors the gen3 templates' `.Values.image.tag | default .Chart.AppVersion`.
    None means nothing deployable: no tag at all, or empty with no appVersion
    (Helm would then render an invalid "repository:" image reference).
    """
    if img.tag:
        return img.tag
    if img.tag == "" and img.app_version:
        return img.app_version
    return None


def tag_display(img: ChartImage) -> str:
    """Tag for plain-text tables: as written, or how an empty tag resolves.

    image_ages.py and weekly_slack_report.py have Markdown/mrkdwn versions of
    this; keep the wording ("(empty → x)", "(empty, no appVersion)") in sync.
    """
    if img.tag is None:
        return "-"
    if img.tag:
        return img.tag
    return f"(empty → {img.app_version})" if img.app_version else "(empty, no appVersion)"


def non_default_tag_charts(
    images: Iterable[ChartImage],
    *,
    allowed_tags: frozenset[str] = DEFAULT_BRANCH_TAGS,
    include_missing: bool = False,
) -> list[str]:
    """Charts whose deployed tag isn't in allowed_tags (exact, case-sensitive).

    A tag passes if it's allowed as written (so "" in allowed_tags accepts
    every empty tag, which is what --allow-empty does) or if its effective
    tag is allowed (empty tag whose appVersion is master). Charts with no
    tag key are skipped unless include_missing is set.
    """
    flagged = []
    for img in images:
        if img.tag is None:
            if include_missing:
                flagged.append(img.chart)
        elif img.tag not in allowed_tags and effective_tag(img) not in allowed_tags:
            flagged.append(img.chart)
    return flagged


# --- CLI --------------------------------------------------------------------

def _quoted_cell(img: ChartImage) -> str:
    if img.tag_quoted is None:
        return "-"
    if img.tag_ambiguous:
        return "no *"  # explained by a footnote under the table
    return "yes" if img.tag_quoted else "no"


def render_table(images: Iterable[ChartImage]) -> str:
    rows = [("CHART", "REPOSITORY", "TAG", "QUOTED")]
    rows += [
        (i.chart, i.repository or "-", tag_display(i), _quoted_cell(i))
        for i in images
    ]
    # Size each column to its widest cell; the last column needs no padding.
    w0, w1, w2 = (max(len(r[n]) for r in rows) for n in range(3))
    return "\n".join(f"{a:<{w0}}  {b:<{w1}}  {c:<{w2}}  {d}" for a, b, c, d in rows)


def parse_args(argv: list[str] | None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    src = p.add_mutually_exclusive_group()
    src.add_argument("--ref", default=DEFAULT_REF,
                     help=f"branch, tag or commit to fetch (default: {DEFAULT_REF})")
    src.add_argument("--local", type=Path, metavar="PATH", help="local gen3-helm clone")
    p.add_argument("--allow-empty", action="store_true",
                   help='accept every tag "" whatever its appVersion (by default an '
                        'empty tag is judged by the appVersion it falls back to)')
    p.add_argument("--include-missing", action="store_true",
                   help="also flag charts with no image tag")
    p.add_argument("--json", action="store_true", help="emit JSON instead of a table")
    # nargs="?" + const: bare --check means "ambiguous"; --check unquoted is stricter.
    p.add_argument("--check", nargs="?", const="ambiguous", choices=("ambiguous", "unquoted"),
                   help="exit 1 if any tag may be misread by Helm (default), or with "
                        "'unquoted', if any tag is unquoted")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    # Logs go to stderr, so --json output on stdout stays machine-readable.
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    try:
        images = load_images(ref=args.ref, local=args.local)
    except ChartLoadError as exc:
        log.error("%s", exc)
        return EXIT_ERROR

    allowed = (DEFAULT_BRANCH_TAGS | {""}) if args.allow_empty else DEFAULT_BRANCH_TAGS
    flagged = non_default_tag_charts(images.values(), allowed_tags=allowed,
                                     include_missing=args.include_missing)
    unquoted = [i.chart for i in images.values() if i.tag_quoted is False]
    ambiguous = [i.chart for i in images.values() if i.tag_ambiguous]

    if args.json:
        # effective_tag is derived (not a ChartImage field), added so JSON
        # consumers don't have to reimplement the appVersion fallback.
        print(json.dumps({"images": [{**asdict(i), "effective_tag": effective_tag(i)}
                                     for i in images.values()],
                          "non_default_tags": flagged,
                          "unquoted_tags": unquoted,
                          "ambiguous_tags": ambiguous}, indent=2))
    else:
        print(render_table(images.values()))
        if ambiguous:
            print("\n* Unquoted and may be read as a number, date or true/false, so Helm "
                  "could deploy a different tag. Quote it in values.yaml.")
        print(f"\n{len(unquoted)} chart(s) with an unquoted tag.")
        print(f"\n{len(flagged)} chart(s) not on {'/'.join(sorted(allowed - {''}))}:")
        print("\n".join(f"  {c}" for c in flagged))

    # The report above is always printed; --check only decides the exit code.
    if args.check:
        failing = ambiguous if args.check == "ambiguous" else unquoted
        if failing:
            log.error("--check %s failed for %d chart(s): %s",
                      args.check, len(failing), ", ".join(failing))
            return EXIT_CHECK_FAILED
    return EXIT_OK


if __name__ == "__main__":
    sys.exit(main())
