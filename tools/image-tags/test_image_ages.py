"""Tests for image_ages (no network: registry responses are faked). Run: pytest -q"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone

import pytest
import requests

import image_ages as a
from gen3_helm_images import ChartImage

NOW = datetime(2026, 11, 24, tzinfo=timezone.utc)


class Resp:
    def __init__(self, status=200, data=None):
        self.status_code, self._data = status, data

    def json(self):
        if isinstance(self._data, Exception):
            raise self._data
        return self._data


def fake_get(status=200, data=None, calls=None):
    def get(url, **kw):
        if calls is not None:
            calls.append((url, kw.get("params")))
        return Resp(status, data)
    return get


# --- registry routing and parsing ---------------------------------------------

def test_quay_uses_start_ts():
    calls = []
    get = fake_get(data={"tags": [{"name": "master", "start_ts": 1764000000}]}, calls=calls)
    pushed, note = a.lookup_pushed("quay.io/cdis/fence", "master", get)
    assert pushed == datetime.fromtimestamp(1764000000, tz=timezone.utc) and note == ""
    assert calls == [("https://quay.io/api/v1/repository/cdis/fence/tag/",
                      {"specificTag": "master", "onlyActiveTags": "true"})]


def test_quay_falls_back_to_last_modified():
    get = fake_get(data={"tags": [{"last_modified": "Mon, 02 Nov 2026 10:00:00 -0000"}]})
    pushed, _ = a.lookup_pushed("quay.io/cdis/x", "v1", get)
    assert pushed == datetime(2026, 11, 2, 10, tzinfo=timezone.utc)


@pytest.mark.parametrize(
    ("status", "data", "note"),
    [(404, None, "not found"), (500, None, "HTTP 500"), (200, {"tags": []}, "tag not found"),
     (200, {"tags": [{}]}, "no date in response"),
     (200, ValueError("bad json"), "lookup failed (ValueError)")],
)
def test_quay_failures(status, data, note):
    assert a.lookup_pushed("quay.io/cdis/x", "v1", fake_get(status, data)) == (None, note)


@pytest.mark.parametrize(
    ("repository", "expected_url"),
    [("datawire/ambassador", "https://hub.docker.com/v2/repositories/datawire/ambassador/tags/1.4.2"),
     ("docker.io/datawire/ambassador", "https://hub.docker.com/v2/repositories/datawire/ambassador/tags/1.4.2"),
     ("nginx", "https://hub.docker.com/v2/repositories/library/nginx/tags/1.4.2")],
)
def test_dockerhub_routing_and_date(repository, expected_url):
    calls = []
    get = fake_get(data={"tag_last_pushed": "2020-05-01T12:00:00.000000Z"}, calls=calls)
    pushed, _ = a.lookup_pushed(repository, "1.4.2", get)
    assert pushed == datetime(2020, 5, 1, 12, tzinfo=timezone.utc)
    assert calls[0][0] == expected_url


def test_tag_with_colon_is_url_encoded_for_dockerhub():
    calls = []
    a.lookup_pushed("ns/img", "a:b/c", fake_get(404, calls=calls))
    assert calls[0][0].endswith("/tags/a%3Ab%2Fc")


@pytest.mark.parametrize("repository", ["ghcr.io/org/img", "localhost:5000/img", "localhost/img"])
def test_unsupported_registries(repository):
    pushed, note = a.lookup_pushed(repository, "v1", fake_get())
    assert pushed is None and note.startswith("unsupported registry")


def test_network_error_is_a_note_not_a_crash():
    def boom(url, **kw):
        raise requests.ConnectionError("down")
    result = a.lookup_pushed("quay.io/cdis/x", "v1", boom)
    assert result == (None, "lookup failed (ConnectionError)")


# --- formatting -----------------------------------------------------------------

@pytest.mark.parametrize(
    ("days", "expected"),
    [(0, "<1 day"), (1, "1 day"), (59, "59 days"), (60, "2 months"), (729, "24 months"),
     (730, "2.0 years"), (2000, "5.5 years")],
)
def test_format_age(days, expected):
    assert a.format_age(NOW - timedelta(days=days), NOW) == expected


def test_build_table_rows():
    images = {
        "fence": ChartImage("fence", "quay.io/cdis/fence", "master", tag_quoted=True),
        "guppy": ChartImage("guppy", "quay.io/cdis/guppy", "", tag_quoted=True),
        "gen3": ChartImage("gen3", None, None),
        "odd": ChartImage("odd", "quay.io/cdis/x", "a:b", tag_quoted=True),
    }
    lookups = {"fence": (NOW - timedelta(days=3), ""), "odd": (None, "not found")}
    rows = a.build_table(images, lookups, NOW).splitlines()
    assert rows[0].endswith("| Tag pushed | Age |")
    assert rows[2] == "| fence | `quay.io/cdis/fence` | `master` | yes |  | 2026-11-21 | 3 days |"
    assert rows[3].endswith("| (empty, no appVersion) | yes | ✓ | _nothing to look up_ | — |")
    assert rows[4] == "| gen3 | — | — | — |  | — | — |"
    assert rows[5].endswith("| _not found_ | — |")


def test_main_end_to_end_with_fake_registry(tmp_path, monkeypatch, capsys):
    d = tmp_path / "helm" / "fence"
    d.mkdir(parents=True)
    (d / "values.yaml").write_text('image:\n  repository: quay.io/cdis/fence\n  tag: "master"\n')
    monkeypatch.setattr(a.requests, "get",
                        fake_get(data={"tags": [{"start_ts": NOW.timestamp() - 86400 * 10}]}))
    assert a.main(["--local", str(tmp_path)]) == 0
    out = capsys.readouterr().out
    assert "| fence | `quay.io/cdis/fence` | `master` | yes |" in out and "days |" in out


# --- appVersion fallback for empty tags ----------------------------------------
# effective_tag() itself is tested in test_gen3_helm_images.py.

def test_empty_tag_is_looked_up_via_app_version(tmp_path, monkeypatch, capsys):
    d = tmp_path / "helm" / "arborist"
    d.mkdir(parents=True)
    (d / "values.yaml").write_text('image:\n  repository: quay.io/cdis/arborist\n  tag: ""\n')
    (d / "Chart.yaml").write_text('name: arborist\nappVersion: "master"\n')
    calls = []
    monkeypatch.setattr(a.requests, "get",
                        fake_get(data={"tags": [{"start_ts": NOW.timestamp() - 86400}]},
                                 calls=calls))
    assert a.main(["--local", str(tmp_path)]) == 0
    assert calls[0][1]["specificTag"] == "master"
    # Resolves to master, so it's looked up and not flagged as off main/master.
    assert "| (empty → `master`) | yes |  |" in capsys.readouterr().out
