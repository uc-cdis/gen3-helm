"""Tests for weekly_slack_report. Run with: pytest -q"""

from __future__ import annotations

import json
from datetime import date

import pytest
import requests

import gen3_helm_images
import weekly_slack_report as r
from gen3_helm_images import ChartImage

WEBHOOK = "https://hooks.slack.com/services/T000/B000/SECRET"

IMAGES = {
    "dash": ChartImage("dash", "r", "2025.10", tag_quoted=False, tag_ambiguous=True),
    "fence": ChartImage("fence", "r", "master", tag_quoted=True),
    "funnel": ChartImage("funnel", "r", "main-gen3", tag_quoted=False),
    "indexd": ChartImage("indexd", "r", "", tag_quoted=True),
}


def section_texts(payload: dict) -> list[str]:
    return [b["text"]["text"] for b in payload["blocks"] if b["type"] == "section"]


def write_chart(root, chart, text):
    d = root / "helm" / chart
    d.mkdir(parents=True)
    (d / "values.yaml").write_text(text)


# --- build_report -------------------------------------------------------------

def test_report_lists_each_category():
    payload = r.build_report(IMAGES, source="master", today=date(2026, 11, 30))
    status, ambiguous, non_default, unquoted = section_texts(payload)

    assert ":rotating_light: 1 tag(s) may be misread" in status
    assert "3 not on main/master · 2 unquoted" in status
    assert "`dash`: `2025.10`" in ambiguous
    assert "`indexd`: (empty, no appVersion)" in non_default and "fence" not in non_default
    assert "`funnel`: `main-gen3`" in unquoted
    assert "2026-11-30" in payload["blocks"][1]["elements"][0]["text"]
    assert payload["text"].startswith("gen3-helm image tag report: :rotating_light:")


def test_report_all_clear_omits_empty_sections():
    images = {"fence": ChartImage("fence", "r", "master", tag_quoted=True)}
    payload = r.build_report(images, source="master")
    assert section_texts(payload) == [
        "*:white_check_mark: No tags at risk of being misread*\n0 not on main/master · 0 unquoted"
    ]


def test_report_allow_empty():
    payload = r.build_report(IMAGES, source="master", allow_empty=True)
    assert "2 not on main/master" in section_texts(payload)[0]


def test_report_source_label():
    def context(**kw):
        return r.build_report(IMAGES, **kw)["blocks"][1]["elements"][0]["text"]

    remote, local = context(source="dev"), context(source="/tmp/x", is_local=True)
    assert "<https://github.com/uc-cdis/gen3-helm/tree/dev/helm|dev>" in remote
    assert "local: `/tmp/x`" in local and "github.com" not in local


def test_report_escapes_mrkdwn():
    images = {"x": ChartImage("x", "r", "<!channel>&", tag_quoted=True)}
    text = "\n".join(section_texts(r.build_report(images, source="master")))
    assert "<!channel>" not in text and "&lt;!channel&gt;&amp;" in text


def test_long_list_is_truncated_at_a_line_break():
    images = {f"chart-{n:03}": ChartImage(f"chart-{n:03}", "r", "v" * 40, tag_quoted=True)
              for n in range(200)}
    texts = section_texts(r.build_report(images, source="master"))
    assert all(len(t) <= r.SECTION_LIMIT for t in texts)
    listing = texts[1]
    assert listing.endswith("_…list truncated_")
    assert listing.splitlines()[-2].startswith("• `chart-")  # last kept line is whole


def test_header_within_slack_limit():
    header = r.build_report(IMAGES, source="master")["blocks"][0]["text"]["text"]
    assert len(header) <= 150


def test_failure_message():
    payload = r.build_failure("Could not load charts: 404", source="master")
    assert payload["text"].startswith(":x:")
    assert "404" in section_texts(payload)[0]


# --- post_to_slack ------------------------------------------------------------

class FakeResponse:
    def __init__(self, status=200, text="ok"):
        self.status_code, self.text = status, text


def test_post_sends_payload(monkeypatch):
    sent = {}
    monkeypatch.setattr(r.requests, "post",
                        lambda url, **kw: sent.update(url=url, **kw) or FakeResponse())
    r.post_to_slack(WEBHOOK, {"text": "hi"})
    assert sent["url"] == WEBHOOK and sent["json"] == {"text": "hi"}
    assert sent["timeout"] == r.SLACK_TIMEOUT_S


def test_post_http_error_reports_slack_reason(monkeypatch):
    monkeypatch.setattr(r.requests, "post", lambda url, **kw: FakeResponse(400, "invalid_blocks"))
    with pytest.raises(RuntimeError, match="HTTP 400: invalid_blocks"):
        r.post_to_slack(WEBHOOK, {})


def test_post_network_error_never_leaks_webhook(monkeypatch):
    def boom(url, **kw):
        raise requests.ConnectionError(f"Max retries exceeded with url: {url}")

    monkeypatch.setattr(r.requests, "post", boom)
    with pytest.raises(RuntimeError) as exc:
        r.post_to_slack(WEBHOOK, {})
    assert "SECRET" not in str(exc.value)
    assert exc.value.__cause__ is None and exc.value.__suppress_context__


# --- main ---------------------------------------------------------------------

@pytest.fixture
def repo(tmp_path):
    write_chart(tmp_path, "fence", 'image:\n  repository: r\n  tag: "master"\n')
    write_chart(tmp_path, "dash", "image:\n  repository: r\n  tag: 2025.10\n")
    return tmp_path


@pytest.fixture
def posts(monkeypatch):
    sent = []
    monkeypatch.setattr(r, "post_to_slack", lambda url, payload: sent.append(payload))
    return sent


def test_main_dry_run_prints_payload_without_webhook(repo, capsys, posts, monkeypatch):
    monkeypatch.delenv("SLACK_WEBHOOK_URL", raising=False)
    assert r.main(["--local", str(repo), "--dry-run"]) == r.EXIT_OK
    assert "`dash`: `2025.10`" in json.dumps(json.loads(capsys.readouterr().out))
    assert posts == []


def test_main_posts_report(repo, posts, monkeypatch):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)
    assert r.main(["--local", str(repo)]) == r.EXIT_OK
    assert len(posts) == 1 and ":rotating_light:" in posts[0]["text"]


def test_main_posts_failure_notice_when_check_cannot_run(tmp_path, posts, monkeypatch):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)
    assert r.main(["--local", str(tmp_path)]) == r.EXIT_ERROR
    assert len(posts) == 1 and posts[0]["text"].startswith(":x:")


def test_main_requires_webhook(repo, posts, monkeypatch, caplog):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", "  ")
    assert r.main(["--local", str(repo)]) == r.EXIT_ERROR
    assert "SLACK_WEBHOOK_URL is not set" in caplog.text and posts == []


def test_main_slack_rejection_is_an_error(repo, monkeypatch, caplog):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)
    monkeypatch.setattr(r.requests, "post", lambda url, **kw: FakeResponse(404, "no_service"))
    assert r.main(["--local", str(repo)]) == r.EXIT_ERROR
    assert "HTTP 404: no_service" in caplog.text and "SECRET" not in caplog.text


# --- change tracking ----------------------------------------------------------

def charts(**tags):
    return {name: {"repository": "r", "tag": tag} for name, tag in tags.items()}


def snap(source="master", day="2026-11-23", **tags):
    return {"version": r.STATE_VERSION, "date": day, "source": source, "charts": charts(**tags)}


def test_diff_snapshots_covers_every_kind():
    old = charts(dash="2025.04", fence="master", gone="v1", same="main")
    new = charts(dash="2025.10", fence="master", same="main", fresh="")
    new["fence"]["repository"] = "quay.io/new/fence"
    assert r.diff_snapshots(old, new) == [
        r.Change("dash", "tag", "2025.04", "2025.10"),
        r.Change("fence", "repository", "r", "quay.io/new/fence"),
        r.Change("fresh", "added", new=""),
        r.Change("gone", "removed", old="v1"),
    ]


def test_diff_snapshots_tag_appearing_or_disappearing():
    assert r.diff_snapshots(charts(a=None), charts(a="v1")) == [r.Change("a", "tag", None, "v1")]


def test_changes_section_lists_changes():
    text = r.changes_section(snap(dash="2025.04", x="v1"), snap(dash="2025.10"))["text"]["text"]
    assert text.splitlines() == [
        "*Changes since 2026-11-23*",
        "• `dash`: tag `2025.04` → `2025.10`",
        "• `x`: removed",
    ]


@pytest.mark.parametrize(
    ("previous", "expected"),
    [
        (None, "First report: nothing to compare yet."),
        (snap(dash="v1"), "No changes."),
        (snap(source="dev", dash="v1"), "Previous report covered `dev`, so no comparison."),
    ],
    ids=["first-run", "no-changes", "different-source"],
)
def test_changes_section_special_cases(previous, expected):
    assert expected in r.changes_section(previous, snap(dash="v1"))["text"]["text"]


def test_changes_section_escapes_values():
    text = r.changes_section(snap(a="v1"), snap(a="<!here>"))["text"]["text"]
    assert "<!here>" not in text and "&lt;!here&gt;" in text


def test_changes_appear_right_after_status():
    changes = r.changes_section(None, snap())
    blocks = r.build_report(IMAGES, source="master", changes_block=changes)["blocks"]
    assert blocks[3] is changes


def test_save_and_load_state_round_trip(tmp_path):
    path = tmp_path / "sub" / "state.json"            # parent dir is created
    r.save_state(path, snap(dash="v1"))
    assert r.load_state(path) == snap(dash="v1")
    assert list(path.parent.iterdir()) == [path]      # no leftover .tmp file


@pytest.mark.parametrize(
    "content",
    ["not json", "[]", '{"version": 99, "charts": {}}', '{"version": 1, "charts": []}',
     '{"version": 1, "charts": {"a": "v1"}}'],
    ids=["garbage", "list", "wrong-version", "charts-list", "chart-not-object"],
)
def test_load_state_ignores_bad_files(tmp_path, caplog, content):
    path = tmp_path / "state.json"
    path.write_text(content)
    assert r.load_state(path) is None
    assert "Ignoring unreadable state file" in caplog.text


def test_load_state_missing_file_is_silent(tmp_path, caplog):
    assert r.load_state(tmp_path / "nope.json") is None
    assert caplog.text == ""


# --- main with --state --------------------------------------------------------

def run_week(repo, state, posts, tag):
    (repo / "helm" / "dash" / "values.yaml").write_text(
        f'image:\n  repository: r\n  tag: "{tag}"\n')
    return r.main(["--local", str(repo), "--state", str(state)])


def test_main_tracks_changes_week_over_week(repo, posts, monkeypatch, tmp_path):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)
    state = tmp_path / "state" / "last.json"

    assert run_week(repo, state, posts, "2025.04") == r.EXIT_OK
    assert "First report" in json.dumps(posts[-1])
    assert json.loads(state.read_text())["charts"]["dash"]["tag"] == "2025.04"

    assert run_week(repo, state, posts, "2025.10") == r.EXIT_OK
    assert "`dash`: tag `2025.04` → `2025.10`" in json.dumps(posts[-1], ensure_ascii=False)

    assert run_week(repo, state, posts, "2025.10") == r.EXIT_OK
    assert "No changes." in json.dumps(posts[-1])


def test_main_failed_post_keeps_previous_state(repo, monkeypatch, tmp_path):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)
    state = tmp_path / "last.json"
    r.save_state(state, snap(source=str(repo), dash="old"))
    monkeypatch.setattr(r.requests, "post", lambda url, **kw: FakeResponse(500, "oops"))

    assert r.main(["--local", str(repo), "--state", str(state)]) == r.EXIT_ERROR
    assert json.loads(state.read_text())["charts"] == charts(dash="old")


def test_main_dry_run_never_writes_state(repo, posts, monkeypatch, tmp_path, capsys):
    monkeypatch.delenv("SLACK_WEBHOOK_URL", raising=False)
    state = tmp_path / "last.json"
    assert r.main(["--local", str(repo), "--state", str(state), "--dry-run"]) == r.EXIT_OK
    assert "First report" in capsys.readouterr().out
    assert not state.exists()


def test_main_load_failure_keeps_previous_state(tmp_path, posts, monkeypatch):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)
    state = tmp_path / "last.json"
    r.save_state(state, snap(dash="old"))
    before = state.read_text()
    assert r.main(["--local", str(tmp_path / "missing"), "--state", str(state)]) == r.EXIT_ERROR
    assert posts[-1]["text"].startswith(":x:") and state.read_text() == before


def test_main_unwritable_state_is_an_error_after_posting(repo, posts, monkeypatch, tmp_path,
                                                          caplog):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)

    def fail(path, snapshot):
        raise PermissionError("read-only file system")

    monkeypatch.setattr(r, "save_state", fail)
    assert r.main(["--local", str(repo), "--state", str(tmp_path / "s.json")]) == r.EXIT_ERROR
    assert len(posts) == 1 and "Report posted, but could not save state" in caplog.text


def test_main_without_state_has_no_changes_section(repo, posts, monkeypatch):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)
    assert r.main(["--local", str(repo)]) == r.EXIT_OK
    assert "Changes since" not in json.dumps(posts[-1])


# --- regression tests from the review ----------------------------------------

def test_failure_message_long_error_keeps_code_block_closed():
    text = section_texts(r.build_failure("x" * 10_000, source="master"))[0]
    assert len(text) <= r.SECTION_LIMIT
    assert text.endswith(" …```")  # closing fence survives


def test_source_link_url_encodes_ref():
    label = r._source_label("feature/a#b|c", is_local=False)
    assert "tree/feature/a%23b%7Cc/helm|feature/a#b|c>" in label


def test_main_local_source_is_resolved_for_state(repo, posts, monkeypatch, tmp_path):
    monkeypatch.setenv("SLACK_WEBHOOK_URL", WEBHOOK)
    monkeypatch.chdir(repo.parent)
    state = tmp_path / "s.json"
    r.main(["--local", f"./{repo.name}", "--state", str(state)])
    r.main(["--local", repo.name, "--state", str(state)])
    assert json.loads(state.read_text())["source"] == str(repo.resolve())
    assert "No changes." in json.dumps(posts[-1])  # same source, so compared


def test_defaults_shared_with_checker():
    assert r.parse_args([]).ref == gen3_helm_images.DEFAULT_REF
    assert (r.EXIT_OK, r.EXIT_ERROR) == (gen3_helm_images.EXIT_OK, gen3_helm_images.EXIT_ERROR)


# --- empty tags resolved via appVersion ----------------------------------------

def test_report_empty_tag_resolving_to_master_is_not_listed():
    images = {"arb": ChartImage("arb", "r", "", tag_quoted=True, app_version="master"),
              "old": ChartImage("old", "r", "", tag_quoted=True, app_version="2022.08")}
    status, listing = section_texts(r.build_report(images, source="master"))
    assert "1 not on main/master" in status
    assert listing == "*Not on main/master*\n• `old`: (empty → `2022.08`)"


def with_app(tag, app):
    return {"repository": "r", "tag": tag, "app_version": app}


@pytest.mark.parametrize(
    ("before", "after", "expected"),
    [(with_app("", "master"), with_app("", "1.2"), [r.Change("c", "appVersion", "master", "1.2")]),
     (with_app("v1", "master"), with_app("v1", "1.2"), []),   # real tag: appVersion irrelevant
     ({"repository": "r", "tag": ""}, with_app("", "master"), []),  # old snapshot, no field
     (with_app("", "master"), with_app("", "master"), [])],
    ids=["empty-tag-changed", "tagged-ignored", "pre-upgrade-state", "unchanged"],
)
def test_diff_app_version(before, after, expected):
    assert r.diff_snapshots({"c": before}, {"c": after}) == expected


def test_snapshot_records_app_version():
    snap_ = r.make_snapshot({"a": ChartImage("a", "r", "", app_version="master")},
                            source="master", today=date(2026, 11, 24))
    assert snap_["charts"]["a"] == {"repository": "r", "tag": "", "app_version": "master"}


def test_app_version_change_line():
    line = r._change_line(r.Change("arb", "appVersion", "master", "1.2"))
    assert line == "• `arb`: appVersion `master` → `1.2`"


@pytest.mark.parametrize(
    ("entry", "expected"),
    [(with_app("", "master"), "• `n`: added, tag (empty → `master`)"),
     (with_app("", None), "• `n`: added, tag (empty, no appVersion)"),
     (with_app("v1", "master"), "• `n`: added, tag `v1`")],
    ids=["empty-resolves", "empty-unresolved", "tagged"],
)
def test_added_chart_shows_resolved_tag(entry, expected):
    (change,) = r.diff_snapshots({}, {"n": entry})
    assert r._change_line(change) == expected
