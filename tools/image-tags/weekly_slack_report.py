#!/usr/bin/env python3
"""Run the gen3-helm image tag check and post a summary to Slack.

Meant to be run on a schedule (cron, Kubernetes CronJob, etc.). If the
check itself fails, a failure notice is posted so silence never hides a
broken job.

With --state, each report also lists what changed since the previous one
(tags, repositories, added and removed charts, and appVersion for charts
whose empty tag falls back to it). The state file is updated
only after Slack accepts the post, and never on --dry-run. Any successful
post counts, including a manual test run.

Environment:
    SLACK_WEBHOOK_URL   Slack incoming-webhook URL (not needed with --dry-run)

Examples:
    weekly_slack_report.py --state state.json   # post, with changes since last time
    weekly_slack_report.py --dry-run            # print the Slack payload instead
    weekly_slack_report.py --local ./gen3-helm --dry-run

Exit codes: 0 posted, 2 error (check failed to run, Slack rejected the post,
or the state file could not be saved).
"""

# Design notes for maintainers
# ----------------------------
# * All chart loading and analysis lives in gen3_helm_images.py; this file only
#   formats results for Slack, posts them and tracks week-over-week state.
# * Slack Block Kit limits (enforced by Slack; a violation rejects the whole
#   message with HTTP 400 "invalid_blocks" and nothing is posted):
#     section text <= 3000 chars, header text <= 150, <= 50 blocks per message.
#   _section() enforces the first; the fixed block layout keeps us far below
#   the others. Test layout changes with --dry-run and Slack's Block Kit Builder.
# * The webhook URL is a credential. It must never appear in logs or errors.
# * State file format (JSON), versioned so it can evolve:
#     {"version": 1, "date": "YYYY-MM-DD", "source": "<ref or path>",
#      "charts": {"<chart>": {"repository": str|null, "tag": str|null,
#                             "app_version": str|null}}}
#   app_version was added later without a version bump: it's optional, and
#   diff_snapshots ignores it for charts saved before it existed. For an
#   incompatible change, bump STATE_VERSION; old files are then ignored (one
#   report shows "nothing to compare yet") rather than misread.

from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from collections.abc import Iterable
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Literal
from urllib.parse import quote

import requests

import gen3_helm_images as g

log = logging.getLogger("weekly_slack_report")

REPO_URL = "https://github.com/uc-cdis/gen3-helm/tree/{ref}/helm"
HEADER = "gen3-helm image tag report"  # Slack header blocks allow 150 chars
SLACK_TIMEOUT_S = 30
SECTION_LIMIT = 3000  # Slack rejects section text longer than this
ERROR_DETAIL_LIMIT = 1500  # keeps failure notices well inside SECTION_LIMIT
STATE_VERSION = 1
# This script never uses EXIT_CHECK_FAILED (1); problem tags are reported, not fatal.
EXIT_OK, EXIT_ERROR = g.EXIT_OK, g.EXIT_ERROR


# --- State: the previous report's snapshot ----------------------------------

@dataclass(frozen=True, slots=True)
class Change:
    chart: str
    kind: Literal["tag", "repository", "appVersion", "added", "removed"]
    old: str | None = None
    new: str | None = None
    # For "added" only: the new chart's appVersion, so an empty tag can be
    # shown as "(empty → x)" like everywhere else.
    new_app_version: str | None = None


def make_snapshot(images: dict[str, g.ChartImage], *, source: str, today: date) -> dict:
    """What gets saved for next time. Only fields that are compared are kept."""
    return {
        "version": STATE_VERSION,
        "date": today.isoformat(),
        "source": source,
        "charts": {n: {"repository": i.repository, "tag": i.tag, "app_version": i.app_version}
                   for n, i in images.items()},
    }


def load_state(path: Path) -> dict | None:
    """Previous snapshot, or None if missing or unreadable (logged, never fatal).

    A bad state file must not stop the report: worst case, one report says
    "nothing to compare yet" and the file is rewritten after the post.
    """
    if not path.exists():
        return None
    try:
        state = json.loads(path.read_text(encoding="utf-8"))
        charts = state.get("charts")  # AttributeError if the JSON isn't an object
        if (state.get("version") != STATE_VERSION or not isinstance(charts, dict)
                or not all(isinstance(v, dict) for v in charts.values())):
            raise ValueError("unrecognized format")
        return state
    except (OSError, ValueError, AttributeError) as exc:  # JSONDecodeError is a ValueError
        log.warning("Ignoring unreadable state file %s (%s)", path, exc)
        return None


def save_state(path: Path, snapshot: dict) -> None:
    """Write atomically, so a crash mid-write can't leave a corrupt file."""
    path.parent.mkdir(parents=True, exist_ok=True)
    # Write a temp file in the same directory, then rename over the target:
    # os.replace is atomic within a filesystem, so readers see old or new, never half.
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(json.dumps(snapshot, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(tmp, path)


def diff_snapshots(old: dict[str, dict], new: dict[str, dict]) -> list[Change]:
    """Changes from old to new chart maps, sorted by chart name.

    Uses .get() throughout so state files from older versions with missing
    fields still compare instead of crashing.
    """
    changes = []
    for chart in sorted(old.keys() | new.keys()):
        before, after = old.get(chart), new.get(chart)
        if before is None:
            changes.append(Change(chart, "added", new=after.get("tag"),
                                  new_app_version=after.get("app_version")))
        elif after is None:
            changes.append(Change(chart, "removed", old=before.get("tag")))
        else:
            for field in ("repository", "tag"):
                if before.get(field) != after.get(field):
                    changes.append(Change(chart, field, before.get(field), after.get(field)))
            # appVersion only decides what's deployed when the tag is empty, so
            # changes elsewhere are noise. "in before" skips snapshots saved
            # before the field existed (they'd all show none -> master).
            if (after.get("tag") == "" and "app_version" in before
                    and before["app_version"] != after.get("app_version")):
                changes.append(Change(chart, "appVersion",
                                      before["app_version"], after.get("app_version")))
    return changes


# --- Message building -------------------------------------------------------
# Everything that comes from the charts (names, tags, paths, errors) goes
# through _escape before it's put in mrkdwn text.

def _escape(text: str) -> str:
    """Escape Slack mrkdwn control characters (also blocks <!channel> pings)."""
    # & first, so the &s added for < and > aren't escaped again.
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def _section(text: str) -> dict:
    """A mrkdwn section block, cut at a line break if over Slack's limit.

    Only list sections can grow past the limit (failure details are capped
    separately), hence the "list truncated" wording.
    """
    if len(text) > SECTION_LIMIT:
        # Leave room for the marker; cut at the last whole line that fits.
        text = text[: SECTION_LIMIT - 20].rsplit("\n", 1)[0] + "\n_…list truncated_"
    return {"type": "section", "text": {"type": "mrkdwn", "text": text}}


def _value(v: str | None) -> str:
    """A tag or repository for display: `code`, or a note when missing/empty."""
    if v is None:
        return "_(none)_"
    return f"`{_escape(v)}`" if v else "_(empty)_"


def _resolved(tag: str | None, app_version: str | None) -> str:
    """mrkdwn tag, showing what an empty tag falls back to.

    Same wording as gen3_helm_images.tag_display, in Slack formatting.
    """
    if tag == "" and app_version:
        return f"(empty → `{_escape(app_version)}`)"
    if tag == "":
        return "(empty, no appVersion)"
    return _value(tag)


def _change_line(c: Change) -> str:
    name = f"`{_escape(c.chart)}`"
    if c.kind == "added":
        return f"• {name}: added, tag {_resolved(c.new, c.new_app_version)}"
    if c.kind == "removed":
        return f"• {name}: removed"
    return f"• {name}: {c.kind} {_value(c.old)} → {_value(c.new)}"


def changes_section(previous: dict | None, current: dict) -> dict:
    """Section comparing this snapshot with the previous one (from load_state)."""
    if previous is None:
        return _section("*Changes since last report*\n_First report: nothing to compare yet._")
    if previous.get("source") != current["source"]:
        # Comparing master with a feature branch would list misleading "changes".
        return _section(f"*Changes since last report*\n_Previous report covered "
                        f"`{_escape(str(previous.get('source')))}`, so no comparison._")
    title = f"*Changes since {_escape(str(previous.get('date', 'last report')))}*"
    changes = diff_snapshots(previous["charts"], current["charts"])
    if not changes:
        return _section(f"{title}\nNo changes.")
    return _section(title + "\n" + "\n".join(_change_line(c) for c in changes))


def _chart_list(title: str, images: Iterable[g.ChartImage]) -> dict:
    # Every listed chart has a tag key (missing tags are never flagged here),
    # so _resolved never sees None in practice; it would show "_(none)_".
    lines = [f"• `{_escape(i.chart)}`: {_resolved(i.tag, i.app_version)}" for i in images]
    return _section(f"*{title}*\n" + "\n".join(lines))


def _source_label(source: str, is_local: bool) -> str:
    if is_local:
        return f"local: `{_escape(source)}`"  # a path; no GitHub link possible
    # Slack link syntax is <url|label>; quote() keeps | and > out of the URL.
    return f"<{REPO_URL.format(ref=quote(source, safe='/'))}|{_escape(source)}>"


def build_report(images: dict[str, g.ChartImage], *, source: str, is_local: bool = False,
                 allow_empty: bool = False, today: date | None = None,
                 changes_block: dict | None = None) -> dict:
    """Slack webhook payload summarizing the check.

    `changes_block` is an optional section (from changes_section), shown right
    after the status line because it's the part people read first each week.
    """
    allowed = (g.DEFAULT_BRANCH_TAGS | {""}) if allow_empty else g.DEFAULT_BRANCH_TAGS
    flagged = set(g.non_default_tag_charts(images.values(), allowed_tags=allowed))
    ambiguous = [i for i in images.values() if i.tag_ambiguous]
    unquoted = [i for i in images.values() if i.tag_quoted is False]
    non_default = [i for i in images.values() if i.chart in flagged]

    status = (f":rotating_light: {len(ambiguous)} tag(s) may be misread by Helm"
              if ambiguous else ":white_check_mark: No tags at risk of being misread")
    blocks: list[dict] = [
        {"type": "header", "text": {"type": "plain_text", "text": HEADER}},
        {"type": "context", "elements": [{"type": "mrkdwn", "text":
            f"{(today or date.today()).isoformat()} · {_source_label(source, is_local)}"
            f" · {len(images)} charts"}]},
        _section(f"*{status}*\n{len(non_default)} not on main/master · "
                 f"{len(unquoted)} unquoted"),
    ]
    # Order is deliberate: what changed, then what needs fixing, then context.
    # Empty lists are omitted rather than shown as empty sections.
    if changes_block is not None:
        blocks.append(changes_block)
    if ambiguous:
        blocks.append(_chart_list(
            "May be misread by Helm (quote these in values.yaml)", ambiguous))
    if non_default:
        blocks.append(_chart_list("Not on main/master", non_default))
    if unquoted:
        blocks.append(_chart_list("Unquoted tags", unquoted))

    # `text` is the notification/fallback; Slack shows `blocks` in the channel.
    return {"text": f"{HEADER}: {status}", "blocks": blocks}


def build_failure(error: str, *, source: str) -> dict:
    """Payload for when the check couldn't run, so the failure is visible in Slack."""
    text = f":x: The weekly gen3-helm image tag check failed to run ({_escape(source)})"
    # Cap the detail before wrapping it in ``` so truncation can never cut off
    # the closing fence (which would turn the rest of the message into code).
    if len(error) > ERROR_DETAIL_LIMIT:
        error = error[:ERROR_DETAIL_LIMIT] + " …"
    return {"text": text, "blocks": [_section(f"*{text}*\n```{_escape(error)}```")]}


# --- Posting ----------------------------------------------------------------

def post_to_slack(webhook_url: str, payload: dict) -> None:
    """POST to the webhook. Errors never include the URL, which is a secret.

    Raises RuntimeError on any failure. Slack's webhook answers 200 "ok" on
    success, or an error code in the body (invalid_blocks, no_service, ...).
    """
    try:
        resp = requests.post(webhook_url, json=payload, timeout=SLACK_TIMEOUT_S)
    except requests.RequestException as exc:
        # requests' messages contain the full URL, so report only the exception
        # type, and `from None` keeps the original out of any traceback.
        raise RuntimeError(f"Slack request failed ({type(exc).__name__})") from None
    if resp.status_code != 200:
        raise RuntimeError(f"Slack returned HTTP {resp.status_code}: {resp.text[:200]}")


# --- CLI --------------------------------------------------------------------

def parse_args(argv: list[str] | None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    src = p.add_mutually_exclusive_group()
    src.add_argument("--ref", default=g.DEFAULT_REF,
                     help=f"branch, tag or commit to fetch (default: {g.DEFAULT_REF})")
    src.add_argument("--local", type=Path, metavar="PATH", help="local gen3-helm clone")
    p.add_argument("--allow-empty", action="store_true",
                   help='never list empty tags under "Not on main/master" (by default '
                        'they are judged by the appVersion they fall back to)')
    p.add_argument("--state", type=Path, metavar="FILE",
                   help="JSON file holding the last report's results; enables "
                        "'changes since' (created on first run)")
    p.add_argument("--dry-run", action="store_true",
                   help="print the Slack payload instead of posting it (never writes --state)")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    # `source` labels the report and is stored in the state file. Local paths
    # are resolved so ./gen3-helm and gen3-helm count as the same source.
    if args.local:
        source, is_local = str(args.local.resolve()), True
    else:
        source, is_local = args.ref, False

    # Check the webhook first: no point downloading charts we can't report on.
    webhook = os.environ.get("SLACK_WEBHOOK_URL", "").strip()
    if not webhook and not args.dry_run:
        log.error("SLACK_WEBHOOK_URL is not set")
        return EXIT_ERROR

    today = date.today()  # one value for both the message and the snapshot
    snapshot = None  # set only on a successful load with --state; saved after posting
    try:
        images = g.load_images(ref=args.ref, local=args.local)
        changes_block = None
        if args.state:
            snapshot = make_snapshot(images, source=source, today=today)
            changes_block = changes_section(load_state(args.state), snapshot)
        payload = build_report(images, source=source, is_local=is_local,
                               allow_empty=args.allow_empty, today=today,
                               changes_block=changes_block)
        status = EXIT_OK
    except g.ChartLoadError as exc:
        # Still post (a failure notice), but exit non-zero so cron/Kubernetes
        # record the run as failed. State is left untouched.
        log.error("%s", exc)
        payload, status = build_failure(str(exc), source=source), EXIT_ERROR

    if args.dry_run:
        print(json.dumps(payload, indent=2))
        return status

    try:
        post_to_slack(webhook, payload)
    except RuntimeError as exc:
        log.error("%s", exc)
        return EXIT_ERROR
    log.info("Posted report to Slack")

    # Only after a successful post, so next week compares against what people saw.
    if snapshot is not None:
        try:
            save_state(args.state, snapshot)
        except OSError as exc:
            # The report is out, but next week's comparison would be wrong or
            # missing; fail loudly so the job shows up as failed.
            log.error("Report posted, but could not save state to %s: %s", args.state, exc)
            return EXIT_ERROR
    return status


if __name__ == "__main__":
    sys.exit(main())
