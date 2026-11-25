#!/usr/bin/env python3
"""Show when each gen3-helm chart's image tag was last pushed, and how long ago.

Prints a Markdown table: chart, repository, tag, quoted, not-main/master,
tag pushed (date) and age. Registry lookups use public APIs, no login needed:
    quay.io/<ns>/<name>          https://quay.io/api/v1/repository/...
    docker.io/<ns>/<name>, or    https://hub.docker.com/v2/repositories/...
    <ns>/<name> with no registry

Examples:
    image_ages.py                       # charts from GitHub master
    image_ages.py --local ./gen3-helm
    image_ages.py > image_ages.md

Empty tags are resolved the way the gen3 chart templates do it,
`.Values.image.tag | default .Chart.AppVersion`: the chart's appVersion from
Chart.yaml is looked up instead, shown as "(empty → <appVersion>)".

Note: "pushed" is when the tag last pointed at a new image. For moving tags
like master that's the latest push, not when the tag was first created.
"""

# Maintainer notes:
# * Chart loading and tag resolution come from gen3_helm_images.py
#   (g.effective_tag: the tag, or appVersion when the tag is empty); this file
#   only adds registry lookups.
# * Each lookup returns (pushed_at, note): pushed_at is None when the date
#   couldn't be found, and note says why ("not found", "HTTP 500", ...).
#   One failed lookup never stops the rest.
# * To support another registry, add a function with the same signature as
#   _quay() and route to it in lookup_pushed().

from __future__ import annotations

import argparse
import logging
import sys
from collections.abc import Callable
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from pathlib import Path
from urllib.parse import quote

import requests

import gen3_helm_images as g

log = logging.getLogger("image_ages")

QUAY_TAG_API = "https://quay.io/api/v1/repository/{repo}/tag/"
DOCKERHUB_TAG_API = "https://hub.docker.com/v2/repositories/{repo}/tags/{tag}"
TIMEOUT_S = 20
WORKERS = 8  # parallel lookups; ~50 images take a few seconds

Lookup = tuple[datetime | None, str]  # (pushed_at, note)
Getter = Callable[..., requests.Response]  # requests.get or a test fake


def _quay(get: Getter, repo: str, tag: str) -> Lookup:
    resp = get(QUAY_TAG_API.format(repo=repo), timeout=TIMEOUT_S,
               params={"specificTag": tag, "onlyActiveTags": "true"})
    if resp.status_code != 200:
        return None, "not found" if resp.status_code == 404 else f"HTTP {resp.status_code}"
    tags = resp.json().get("tags") or []
    if not tags:
        return None, "tag not found"
    t = tags[0]
    # start_ts (Unix seconds) is when this tag started pointing at its current
    # image; last_modified is the same moment as an RFC 2822 string.
    if t.get("start_ts"):
        return datetime.fromtimestamp(t["start_ts"], tz=timezone.utc), ""
    if t.get("last_modified"):
        when = parsedate_to_datetime(t["last_modified"])
        # Quay writes "-0000", which the email-date parser treats as "zone
        # unknown" and returns a naive datetime; Quay's times are UTC.
        return (when if when.tzinfo else when.replace(tzinfo=timezone.utc)), ""
    return None, "no date in response"


def _dockerhub(get: Getter, repo: str, tag: str) -> Lookup:
    if "/" not in repo:
        repo = f"library/{repo}"  # official images, e.g. "nginx"
    resp = get(DOCKERHUB_TAG_API.format(repo=repo, tag=quote(tag, safe="")), timeout=TIMEOUT_S)
    if resp.status_code != 200:
        return None, "not found" if resp.status_code == 404 else f"HTTP {resp.status_code}"
    data = resp.json()
    stamp = data.get("tag_last_pushed") or data.get("last_updated")
    if not stamp:
        return None, "no date in response"
    # Python 3.10's fromisoformat doesn't accept "Z"; an unexpected format
    # raises ValueError, which lookup_pushed turns into "lookup failed".
    return datetime.fromisoformat(stamp.replace("Z", "+00:00")), ""


def lookup_pushed(repository: str, tag: str, get: Getter | None = None) -> Lookup:
    """When `repository:tag` was last pushed, routed by registry host."""
    # Resolved at call time (not as a default argument) so tests can patch requests.get.
    get = get or requests.get
    first, _, rest = repository.partition("/")
    try:
        if first == "quay.io":
            return _quay(get, rest, tag)
        if first in ("docker.io", "index.docker.io", "registry-1.docker.io"):
            return _dockerhub(get, rest, tag)
        # No registry host (no "." or ":" in the first part) means Docker Hub.
        if not rest or ("." not in first and ":" not in first and first != "localhost"):
            return _dockerhub(get, repository, tag)
        return None, f"unsupported registry ({first})"
    except (requests.RequestException, ValueError, KeyError, TypeError) as exc:
        # ValueError covers bad JSON and unparseable dates.
        return None, f"lookup failed ({type(exc).__name__})"


def _tag_cell(img: g.ChartImage) -> str:
    """Markdown version of g.tag_display (same wording, tags in backticks)."""
    if img.tag is None:
        return "—"
    if img.tag:
        return f"`{img.tag}`"
    return f"(empty → `{img.app_version}`)" if img.app_version else "(empty, no appVersion)"


def format_age(pushed: datetime, now: datetime) -> str:
    days = (now - pushed).days
    if days < 1:
        return "<1 day"
    if days < 60:
        return f"{days} day{'s' if days != 1 else ''}"
    if days < 730:
        return f"{days // 30} months"
    return f"{days / 365.25:.1f} years"


def build_table(images: dict[str, g.ChartImage], lookups: dict[str, Lookup],
                now: datetime) -> str:
    flagged = set(g.non_default_tag_charts(images.values()))
    rows = ["| Chart | Repository | Tag | Quoted | Not main/master | Tag pushed | Age |",
            "|---|---|---|---|---|---|---|"]
    for name, img in images.items():
        tag = _tag_cell(img)
        quoted = ("—" if img.tag_quoted is None
                  else "no ⚠️" if img.tag_ambiguous else "yes" if img.tag_quoted else "no")
        repo = f"`{img.repository}`" if img.repository else "—"
        if name in lookups:
            pushed, note = lookups[name]
            when = pushed.date().isoformat() if pushed else f"_{note}_"
            age = format_age(pushed, now) if pushed else "—"
        else:
            # Not looked up: no image/tag key, or an empty tag with no appVersion.
            when = "_nothing to look up_" if img.tag == "" else "—"
            age = "—"
        rows.append(f"| {name} | {repo} | {tag} | {quoted} | "
                    f"{'✓' if name in flagged else ''} | {when} | {age} |")
    return "\n".join(rows)


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    src = p.add_mutually_exclusive_group()
    src.add_argument("--ref", default=g.DEFAULT_REF,
                     help=f"branch, tag or commit to fetch (default: {g.DEFAULT_REF})")
    src.add_argument("--local", type=Path, metavar="PATH", help="local gen3-helm clone")
    args = p.parse_args(argv)
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    try:
        images = g.load_images(ref=args.ref, local=args.local)
    except g.ChartLoadError as exc:
        log.error("%s", exc)
        return g.EXIT_ERROR

    # Only charts with a repository and a tag Helm would actually deploy.
    todo = {n: (i.repository, g.effective_tag(i)) for n, i in images.items()
            if i.repository and g.effective_tag(i)}
    log.info("Looking up %d image tags...", len(todo))
    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = {n: pool.submit(lookup_pushed, repo, tag) for n, (repo, tag) in todo.items()}
        lookups = {n: f.result() for n, f in futures.items()}

    print(build_table(images, lookups, datetime.now(timezone.utc)))
    failed = sum(1 for pushed, _ in lookups.values() if pushed is None)
    if failed:
        log.warning("%d of %d lookups found no date (see the Tag pushed column)",
                    failed, len(lookups))
    return g.EXIT_OK


if __name__ == "__main__":
    sys.exit(main())
