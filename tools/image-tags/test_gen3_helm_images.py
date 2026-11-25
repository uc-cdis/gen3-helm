"""Tests for gen3_helm_images. Run with: pytest -q"""

from __future__ import annotations

import io
import json
import tarfile
from pathlib import Path

import pytest
import requests

import gen3_helm_images as m
from gen3_helm_images import ChartImage


def make_tarball(files: dict[str, str | bytes], root: str = "gen3-helm-master") -> bytes:
    """Build an in-memory .tar.gz with the given {relative_path: contents}."""
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w:gz") as tar:
        for rel, text in files.items():
            data = text if isinstance(text, bytes) else text.encode()
            info = tarfile.TarInfo(f"{root}/{rel}")
            info.size = len(data)
            tar.addfile(info, io.BytesIO(data))
    return buf.getvalue()


def write_chart(root: Path, chart: str, text: str, chart_yaml: str | None = None) -> None:
    chart_dir = root / "helm" / chart
    chart_dir.mkdir(parents=True)
    (chart_dir / "values.yaml").write_text(text)
    if chart_yaml is not None:
        (chart_dir / "Chart.yaml").write_text(chart_yaml)


# --- parse_image --------------------------------------------------------------

@pytest.mark.parametrize(
    ("text", "expected"),
    [
        ("image:\n  repository: quay.io/cdis/fence\n  tag: master\n",
         ("quay.io/cdis/fence", "master")),
        ('image:\n  repository: r\n  tag: ""\n', ("r", "")),          # empty, not missing
        ("image:\n  repository: r\n", ("r", None)),                  # tag key absent
        ("image:\n  tag: main\n", (None, "main")),                   # repository absent
        ("replicas: 1\n", (None, None)),                              # no image block
        ("image: quay.io/cdis/fence:master\n", (None, None)),         # image is a string
        ("", (None, None)),                                           # empty file
        ("- a\n- b\n", (None, None)),                                 # top level is a list
    ],
    ids=["normal", "empty-tag", "no-tag", "no-repo", "no-image",
         "image-scalar", "empty-file", "list-root"],
)
def test_parse_image(text, expected):
    img = m.parse_image("c", text)
    assert (img.repository, img.tag) == expected
    assert img.chart == "c"


@pytest.mark.parametrize("raw", ["2025.04", "2025.10", "1.10", "2022", "010", "1_000", "1e3"])
def test_parse_image_numeric_looking_tag_kept_verbatim(raw):
    # Plain yaml.safe_load would turn all but 1e3 into numbers (2025.1, 8, ...).
    assert m.parse_image("c", f"image:\n  tag: {raw}\n").tag == raw


@pytest.mark.parametrize(
    "text",
    ["image: [unclosed\n",
     "image:\n  tag: a\n---\nimage:\n  tag: b\n",   # multiple documents
     "image:\n  <<: 5\n"],                             # invalid merge value
    ids=["unclosed", "multi-doc", "bad-merge"],
)
def test_parse_image_invalid_yaml_logs_warning(caplog, text):
    assert m.parse_image("broken", text) == ChartImage("broken", None, None)
    assert "broken: invalid YAML" in caplog.text


@pytest.mark.parametrize(
    ("tag_line", "tag", "quoted", "ambiguous"),
    [
        ('tag: "master"', "master", True, False),
        ("tag: 'master'", "master", True, False),
        ("tag: master", "master", False, False),
        ('tag: ""', "", True, False),
        ('tag: "2025.10"', "2025.10", True, False),   # quoted number: safe
        ("tag: 2025.10", "2025.10", False, True),     # Helm reads 2025.1
        ("tag: 010", "010", False, True),             # Helm reads 8
        ("tag: true", "true", False, True),           # Helm reads a boolean
        ("tag: 2025-10-01", "2025-10-01", False, True),  # YAML date
        ("tag: v1.2", "v1.2", False, False),
        ("tag: 2.15.0-DEV", "2.15.0-DEV", False, False),
        ("tag: 1e3", "1e3", False, True),             # text to PyYAML, number to Helm
        ("tag: 7e10", "7e10", False, True),           # SHA-like: digits plus one e
        ("tag: v1e3", "v1e3", False, False),
        ("tag: |\n    master", "master\n", False, False),  # block scalar is text
        ("tag:", None, None, False),                  # null
        ("tag: ~", None, None, False),
        ("repository: r", None, None, False),         # no tag key
    ],
)
def test_parse_image_quote_detection(tag_line, tag, quoted, ambiguous):
    img = m.parse_image("c", f"image:\n  {tag_line}\n")
    assert (img.tag, img.tag_quoted, img.tag_ambiguous) == (tag, quoted, ambiguous)


def test_parse_image_duplicate_key_last_wins():
    text = "image:\n  tag: first\nimage:\n  tag: second\n"
    assert m.parse_image("c", text).tag == "second"


def test_parse_image_follows_anchors():
    text = 'base: &img\n  repository: r\n  tag: "v1"\nimage: *img\n'
    assert m.parse_image("c", text) == ChartImage("c", "r", "v1", tag_quoted=True, tag_line=3)


@pytest.mark.parametrize(
    ("image_block", "expected"),
    [
        ('  <<: *b\n  tag: "v2"\n', ("quay.io/x", "v2")),      # explicit key overrides
        ("  <<: *b\n", ("quay.io/x", "v1")),
        ('  <<: [*b, *c]\n', ("quay.io/x", "v1")),             # first merge source wins
    ],
    ids=["override", "inherit", "merge-list"],
)
def test_parse_image_merge_keys(image_block, expected):
    text = ('b: &b\n  repository: quay.io/x\n  tag: "v1"\n'
            'c: &c\n  repository: quay.io/y\n  tag: "v9"\n'
            "image:\n" + image_block)
    img = m.parse_image("c", text)
    assert (img.repository, img.tag) == expected


def test_parse_image_records_tag_line():
    text = "# comment\nreplicas: 1\nimage:\n  repository: r\n  tag: v1\n"
    assert m.parse_image("c", text).tag_line == 5
    assert m.parse_image("c", "image:\n  repository: r\n").tag_line is None


@pytest.mark.parametrize(
    ("chart_yaml", "expected"),
    [('appVersion: "master"\n', "master"),
     ("appVersion: 1.10\n", "1.10"),          # unquoted number kept as written
     ("name: x\n", None),                      # no appVersion
     ("appVersion:\n", None),                  # null
     (None, None)],                             # no Chart.yaml at all
    ids=["quoted", "numeric", "missing", "null", "no-file"],
)
def test_parse_app_version(chart_yaml, expected):
    assert m.parse_image("c", "image:\n  tag: \"\"\n", chart_yaml).app_version == expected


def test_invalid_chart_yaml_warns_but_keeps_image(caplog):
    img = m.parse_image("c", 'image:\n  repository: r\n  tag: "v1"\n', "appVersion: [oops\n")
    assert (img.tag, img.app_version) == ("v1", None)
    assert "c: invalid Chart.yaml" in caplog.text


def test_app_version_survives_invalid_values_yaml():
    img = m.parse_image("c", "image: [oops\n", 'appVersion: "master"\n')
    assert (img.tag, img.app_version) == (None, "master")


def test_parse_image_ignores_nested_images():
    text = "image:\n  tag: master\nsidecar:\n  image:\n    tag: v9\n"
    assert m.parse_image("c", text).tag == "master"


# --- collect_images / non_default_tag_charts ----------------------------------

def test_collect_images_sorted_by_chart():
    files = [("zeta", "image:\n  tag: main\n", None), ("alpha", "image:\n  tag: v1\n", None)]
    assert list(m.collect_images(files)) == ["alpha", "zeta"]


IMAGES = [
    ChartImage("main-chart", "r", "main"),
    ChartImage("master-chart", "r", "master"),
    ChartImage("pinned", "r", "1.4.2"),
    ChartImage("empty", "r", ""),
    ChartImage("missing", None, None),
]


def test_non_default_tag_charts_default():
    assert m.non_default_tag_charts(IMAGES) == ["pinned", "empty"]


def test_non_default_tag_charts_include_missing():
    assert m.non_default_tag_charts(IMAGES, include_missing=True) == ["pinned", "empty", "missing"]


def test_non_default_tag_charts_custom_allowed():
    allowed = m.DEFAULT_BRANCH_TAGS | {""}
    assert m.non_default_tag_charts(IMAGES, allowed_tags=allowed) == ["pinned"]


APP_IMAGES = [
    ChartImage("empty-master", "r", "", app_version="master"),
    ChartImage("empty-pinned", "r", "", app_version="1.2"),
    ChartImage("empty-none", "r", ""),
    ChartImage("tagged", "r", "v9", app_version="master"),  # a real tag ignores appVersion
]


def test_empty_tags_judged_by_app_version():
    assert m.non_default_tag_charts(APP_IMAGES) == ["empty-pinned", "empty-none", "tagged"]


def test_allow_empty_accepts_every_empty_tag():
    allowed = m.DEFAULT_BRANCH_TAGS | {""}
    assert m.non_default_tag_charts(APP_IMAGES, allowed_tags=allowed) == ["tagged"]


@pytest.mark.parametrize(
    ("img", "effective", "display"),
    [(APP_IMAGES[0], "master", "(empty → master)"),
     (APP_IMAGES[1], "1.2", "(empty → 1.2)"),
     (APP_IMAGES[2], None, "(empty, no appVersion)"),
     (APP_IMAGES[3], "v9", "v9"),
     (ChartImage("x", None, None, app_version="master"), None, "-")],
    ids=["empty-master", "empty-pinned", "empty-none", "tagged", "no-tag"],
)
def test_effective_tag_and_display(img, effective, display):
    assert (m.effective_tag(img), m.tag_display(img)) == (effective, display)


def test_main_empty_tag_with_master_app_version_is_not_flagged(tmp_path, capsys):
    write_chart(tmp_path, "arborist", 'image:\n  repository: r\n  tag: ""\n',
                chart_yaml='appVersion: "master"\n')
    write_chart(tmp_path, "old", 'image:\n  repository: r\n  tag: ""\n',
                chart_yaml='appVersion: "2022.08"\n')
    assert m.main(["--local", str(tmp_path), "--json"]) == 0
    assert json.loads(capsys.readouterr().out)["non_default_tags"] == ["old"]
    assert m.main(["--local", str(tmp_path)]) == 0
    assert "(empty → master)" in capsys.readouterr().out


def test_tag_match_is_exact():
    images = [ChartImage("a", "r", "Master"), ChartImage("b", "r", "main-gen3")]
    assert m.non_default_tag_charts(images) == ["a", "b"]


# --- sources ------------------------------------------------------------------

def test_iter_local_charts(tmp_path):
    write_chart(tmp_path, "fence", "image:\n  tag: master\n", chart_yaml="appVersion: x\n")
    write_chart(tmp_path, "indexd", "image:\n  tag: v1\n")  # no Chart.yaml
    (tmp_path / "helm" / "README.md").write_text("not a chart")
    assert sorted(m.iter_local_charts(tmp_path)) == [
        ("fence", "image:\n  tag: master\n", "appVersion: x\n"),
        ("indexd", "image:\n  tag: v1\n", None),
    ]


def test_iter_local_charts_missing_helm_dir(tmp_path):
    with pytest.raises(FileNotFoundError):
        list(m.iter_local_charts(tmp_path))


class FakeResponse:
    def __init__(self, content: bytes, status: int = 200):
        self.content = content
        self.status = status

    def raise_for_status(self):
        if self.status >= 400:
            raise requests.HTTPError(f"{self.status}")


@pytest.fixture
def fake_get(monkeypatch):
    """Patch requests.get; returns a setter for the response and the list of URLs called."""
    state = {"response": FakeResponse(b""), "calls": []}

    def get(url, **kwargs):
        state["calls"].append(url)
        return state["response"]

    monkeypatch.setattr(m.requests, "get", get)
    return state


def test_iter_github_charts_filters_paths(fake_get):
    body = make_tarball({
        "helm/fence/Chart.yaml": "name: fence\n",                 # listed before values
        "helm/fence/values.yaml": "image:\n  tag: master\n",
        "helm/fence/README.md": "docs\n",                         # wrong file
        "helm/indexd/values.yaml": "image: {}\n",                 # no Chart.yaml
        "helm/only-chart/Chart.yaml": "name: x\n",                # no values.yaml: skipped
        "helm/fence/charts/sub/values.yaml": "image: {}\n",        # too deep
        "docs/values.yaml": "x: 1\n",                              # wrong dir
        "helm/values.yaml": "x: 1\n",                              # too shallow
    })
    fake_get["response"] = FakeResponse(body)

    assert sorted(m.iter_github_charts("dev")) == [
        ("fence", "image:\n  tag: master\n", "name: fence\n"),
        ("indexd", "image: {}\n", None),
    ]
    assert fake_get["calls"] == [m.TARBALL_URL.format(ref="dev")]


def test_iter_github_charts_url_encodes_ref(fake_get):
    fake_get["response"] = FakeResponse(make_tarball({}))
    list(m.iter_github_charts("feature/a#b"))
    assert fake_get["calls"] == [m.TARBALL_URL.format(ref="feature/a%23b")]


# --- main ---------------------------------------------------------------------

@pytest.fixture
def repo(tmp_path):
    write_chart(tmp_path, "fence", "image:\n  repository: r/fence\n  tag: master\n")
    write_chart(tmp_path, "arborist", 'image:\n  repository: r/arborist\n  tag: ""\n')
    write_chart(tmp_path, "ambassador", "image:\n  repository: r/amb\n  tag: 1.4.2\n")
    return tmp_path


def run_json(args, capsys) -> dict:
    assert m.main(args + ["--json"]) == 0
    return json.loads(capsys.readouterr().out)


def test_main_json(repo, capsys):
    out = run_json(["--local", str(repo)], capsys)
    assert out["non_default_tags"] == ["ambassador", "arborist"]
    assert {"chart": "fence", "repository": "r/fence", "tag": "master",
            "tag_quoted": False, "tag_ambiguous": False, "tag_line": 3,
            "app_version": None, "effective_tag": "master"} in out["images"]
    assert out["unquoted_tags"] == ["ambassador", "fence"]
    assert out["ambiguous_tags"] == []


def test_main_allow_empty(repo, capsys):
    out = run_json(["--local", str(repo), "--allow-empty"], capsys)
    assert out["non_default_tags"] == ["ambassador"]


def test_main_table(repo, capsys):
    assert m.main(["--local", str(repo)]) == 0
    out = capsys.readouterr().out
    assert "2 chart(s) not on main/master" in out
    assert "(empty, no appVersion)" in out
    assert "2 chart(s) with an unquoted tag" in out
    assert "* Unquoted" not in out  # no ambiguous tags in this repo


def test_main_table_marks_ambiguous_tags(tmp_path, capsys):
    write_chart(tmp_path, "dash", "image:\n  repository: r\n  tag: 2025.10\n")
    assert m.main(["--local", str(tmp_path)]) == 0
    out = capsys.readouterr().out
    assert "2025.10" in out and "no *" in out and "* Unquoted" in out


def test_render_table_columns():
    rows = m.render_table([
        ChartImage("a", "r", "main", tag_quoted=True),
        ChartImage("b", "r", "main", tag_quoted=False),
        ChartImage("c", None, None),
    ]).splitlines()
    assert rows[0].split() == ["CHART", "REPOSITORY", "TAG", "QUOTED"]
    assert [r.split()[-1] for r in rows[1:]] == ["yes", "no", "-"]


def test_main_errors_when_no_charts_found(tmp_path, caplog):
    (tmp_path / "helm").mkdir()
    assert m.main(["--local", str(tmp_path)]) == m.EXIT_ERROR
    assert "No helm/<chart>/values.yaml files found" in caplog.text


def test_main_errors_on_load_error(tmp_path, caplog):
    assert m.main(["--local", str(tmp_path)]) == m.EXIT_ERROR
    assert "Could not load charts" in caplog.text


@pytest.mark.parametrize(
    ("response", "message"),
    [
        (FakeResponse(b"", status=404), "404"),
        (FakeResponse(b"<html>not a tarball</html>"), "Could not load charts"),
        (FakeResponse(make_tarball({"helm/x/values.yaml": b"tag: \xff"})), "Could not load charts"),
    ],
    ids=["http-404", "corrupt-tarball", "non-utf8"],
)
def test_main_errors_on_github_errors(fake_get, caplog, response, message):
    fake_get["response"] = response
    assert m.main(["--ref", "nope"]) == m.EXIT_ERROR
    assert message in caplog.text


def test_main_errors_on_non_utf8_local_file(tmp_path, caplog):
    chart_dir = tmp_path / "helm" / "x"
    chart_dir.mkdir(parents=True)
    (chart_dir / "values.yaml").write_bytes(b"image:\n  tag: \xff\n")
    assert m.main(["--local", str(tmp_path)]) == m.EXIT_ERROR


# --- --check ------------------------------------------------------------------

@pytest.mark.parametrize(
    ("tags", "check", "expected"),
    [
        (['"main"', '"v1"'], [], m.EXIT_OK),                         # no --check
        (["2025.10"], [], m.EXIT_OK),                                # report only
        (['"main"', "main"], ["--check"], m.EXIT_OK),                # unquoted but safe
        (['"main"', "2025.10"], ["--check"], m.EXIT_CHECK_FAILED),
        (['"main"', "main"], ["--check", "unquoted"], m.EXIT_CHECK_FAILED),
        (['"main"', '"2025.10"'], ["--check", "unquoted"], m.EXIT_OK),
    ],
    ids=["off", "off-ambiguous", "safe", "ambiguous", "unquoted", "all-quoted"],
)
def test_check_exit_codes(tmp_path, capsys, tags, check, expected):
    for n, tag in enumerate(tags):
        write_chart(tmp_path, f"c{n}", f"image:\n  repository: r\n  tag: {tag}\n")
    assert m.main(["--local", str(tmp_path), *check]) == expected


def test_check_failure_message_names_charts(tmp_path, capsys, caplog):
    write_chart(tmp_path, "dash", "image:\n  tag: 2025.10\n")
    write_chart(tmp_path, "fence", 'image:\n  tag: "master"\n')
    assert m.main(["--local", str(tmp_path), "--check"]) == m.EXIT_CHECK_FAILED
    assert "--check ambiguous failed for 1 chart(s): dash" in caplog.text


def test_check_with_json_keeps_stdout_parseable(tmp_path, capsys):
    write_chart(tmp_path, "dash", "image:\n  tag: 2025.10\n")
    assert m.main(["--local", str(tmp_path), "--check", "--json"]) == m.EXIT_CHECK_FAILED
    assert json.loads(capsys.readouterr().out)["ambiguous_tags"] == ["dash"]


def test_check_rejects_unknown_mode():
    with pytest.raises(SystemExit) as exc:
        m.parse_args(["--check", "bogus"])
    assert exc.value.code == m.EXIT_ERROR


def test_ref_and_local_are_mutually_exclusive():
    with pytest.raises(SystemExit):
        m.parse_args(["--ref", "x", "--local", "."])


def test_json_includes_effective_tag(tmp_path, capsys):
    write_chart(tmp_path, "arborist", 'image:\n  repository: r\n  tag: ""\n',
                chart_yaml='appVersion: "master"\n')
    assert m.main(["--local", str(tmp_path), "--json"]) == 0
    (img,) = json.loads(capsys.readouterr().out)["images"]
    assert (img["tag"], img["app_version"], img["effective_tag"]) == ("", "master", "master")
