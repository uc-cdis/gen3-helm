# Image tag tools for gen3-helm

Most charts in [`helm/`](../../helm) say which container image its service runs, as an image **repository** and a **tag** in `values.yaml`. Most charts follow the default branch (`main` or `master`), but some are pinned to a release or a feature branch. And an unquoted tag can be silently changed by Helm: `2025.10` is deployed as `2025.1`. These tools find both kinds of chart automatically, so nobody has to open each file by hand.

This folder is the single source for all aspects of this tool set. The pull-request check and the weekly Slack report both run the code from here, so only one source needs to be updated.

## What's in this folder

| File | Purpose |
|---|---|
| `gen3_helm_images.py` | **The checker.** Lists every chart's image, and flags tags that are not main/master or may be misread. The other tools build on it. |
| `weekly_slack_report.py` | Posts a weekly summary to Slack, including what changed since the previous report. |
| `image_ages.py` | Adds when each image tag was last pushed, and how long ago. |
| `test_*.py` | Tests for all three scripts (165 in total, none need the internet). |
| `requirements.txt` / `requirements-dev.txt` | Packages needed to run the tools / to also run the tests. |
| `deploy/cron/`, `deploy/k8s/` | Two ways to schedule the Slack report: cron on a server, or a Kubernetes CronJob. |
| `docs/HOW_TO_USE.md` | Step-by-step guide to running the checker on your own computer. |
| `docs/SLACK_REPORT_SETUP.md` | How to set up the weekly Slack report. |

## Where the tools run

- **On every pull request:** `.github/workflows/check-image-tags.yaml` runs all the tests above, then the checker with `--check`. If a tag may be misread by Helm, the check fails and puts an error on that line in the pull request's "Files changed" view. The full table appears in the run's summary page.
- **Weekly, in Slack (optional):** see `docs/SLACK_REPORT_SETUP.md`.
- **On your computer, any time:** see `docs/HOW_TO_USE.md`. Use `--local ../..` to check your own working copy before opening a pull request.

A related check lives outside this folder: the existing "Lint and Test Charts" workflow rejects unquoted numeric `appVersion` values in `Chart.yaml`, through the custom chart-testing schema in `.github/chart_schema.yaml`.

## How the checker works

1. **Gets the charts.** It downloads gen3-helm from GitHub in one request, or reads a local copy (`--local`).
2. **Reads each chart's settings.** For every chart, it pulls `image.repository` and `image.tag` from `values.yaml`, plus `appVersion` from `Chart.yaml`, which is what a blank tag falls back to.
3. **Flags exceptions.** It lists every chart whose deployed tag isn't exactly `main` or `master`. For a blank tag, that's the chart's `appVersion`.
4. **Checks quoting.** It notes whether each tag is quoted, and warns if an unquoted tag may be misread by Helm. The check errs on the side of warning, since quoting is always safe.
5. **Reports.** It prints a table of all charts followed by the flagged list, or JSON output for use by other tools.

### Options

| Option | Effect |
|---|---|
| `--allow-empty` | Treats every blank tag as acceptable, whatever it falls back to |
| `--include-missing` | Also flags charts with no image tag at all |
| `--ref BRANCH` | Checks a different branch |
| `--local PATH` | Uses a local copy instead of downloading |
| `--json` | Machine-readable output |
| `--check` | Exits with code 1 if any tag may be misread by Helm, for use in CI |
| `--check unquoted` | Stricter: exits with code 1 if any tag is unquoted |

### Exit codes

* `gen3_helm_images.py`: `0` success, `1` `--check` found problem tags, `2` error (bad arguments, download failure, no charts found).  
* `weekly_slack_report.py` uses only `0` and `2`.  
* `image_ages.py` always exits `0` once the charts load, and warns about any lookups that failed.

### Limitations

- **Only the main `image:` setting is read.** Extra images in a chart, such as sidecars or helper containers, aren't checked.
- **Tags are reported exactly as written.** For unquoted tags that may be misread, the checker shows a warning rather than the value Helm would deploy.
- **Blank tags assume the standard template.** The `appVersion` fallback assumes the chart's template uses `.Values.image.tag | default .Chart.AppVersion` (true of all charts with blank tags as of November 2026).
- **`appVersion` quoting is checked elsewhere,** by "Lint and Test Charts" ([see above, at the bottom of "Where the tools run"](#where-the-tools-run)), not by these tools.
- **Read-only.** None of the tools change any files.

## Maintaining

- **Requirements:** Python 3.10+ with `requests` and `PyYAML` (`requirements.txt`). The tests also need `pytest` (`requirements-dev.txt`). Run them with `python -m pytest -q` from this folder.
- **The pull-request check tests every change here,** including changes to the Slack report and image-age tool.
- **Deployed copies:** a cron deployment runs straight from a gen3-helm checkout, so `git pull` updates it. A Kubernetes deployment runs from a ConfigMap, which has to be recreated after changes (see `docs/SLACK_REPORT_SETUP.md`).
- **Each script starts with design notes for maintainers,** covering why it's built the way it is and which names other files depend on.
