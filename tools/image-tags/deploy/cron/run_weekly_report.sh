#!/usr/bin/env bash
# Cron entry point for the weekly gen3-helm image tag report (posts to Slack).
#
# Runs the code straight from a gen3-helm checkout (this file lives at
# tools/image-tags/deploy/cron/ in it), so updating the report is `git pull`.
# Everything specific to this machine lives in a data directory outside the
# checkout, so a pull can never touch the secret or the state:
#
#   $GEN3_IMAGE_REPORT_HOME (default: ~/.gen3-image-report)
#     .venv/       python3 -m venv .venv && .venv/bin/pip install -r <tools>/requirements.txt
#     slack.env    SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...  (chmod 600)
#                  Optional: GEN3_IMAGE_REPORT_AUTO_UPDATE=1 (see below)
#     state.json   last report's results, for "changes since"; created automatically
#     report.log   output of each run, if you use the crontab line below
#
# Example crontab line (Mondays 09:00 server time; edit with `crontab -e`):
#   0 9 * * 1  bash /opt/gen3-helm/tools/image-tags/deploy/cron/run_weekly_report.sh >> "$HOME/.gen3-image-report/report.log" 2>&1
# Calling it via `bash` means it works even if the file lost its executable bit.
#
# Extra arguments are passed through to weekly_slack_report.py, e.g.
#   bash run_weekly_report.sh --dry-run
set -euo pipefail

# tools/image-tags/, two levels up from this script. readlink -f resolves
# symlinks (GNU/Linux), so the crontab can point at a symlink too.
TOOL_DIR="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
DATA_DIR="${GEN3_IMAGE_REPORT_HOME:-$HOME/.gen3-image-report}"
log() { echo "$(date -Is) $*"; }

if [[ ! -r "$DATA_DIR/slack.env" ]]; then
  log "ERROR: $DATA_DIR/slack.env not found" >&2
  exit 2  # same "error" exit code as the Python scripts
fi
if [[ ! -x "$DATA_DIR/.venv/bin/python" ]]; then
  log "ERROR: no virtual environment at $DATA_DIR/.venv" >&2
  exit 2
fi
# Export every variable in slack.env, so the webhook URL reaches Python
# without ever appearing in the crontab or the repository.
set -a
# shellcheck source=/dev/null
source "$DATA_DIR/slack.env"
set +a

# Optional: pull the latest gen3-helm before running. Off by default, since it
# means whatever is merged to master runs here unattended. A failed pull is
# logged and the run continues with the code already checked out.
if [[ "${GEN3_IMAGE_REPORT_AUTO_UPDATE:-0}" == "1" ]]; then
  if git -C "$TOOL_DIR" pull --ff-only --quiet; then
    "$DATA_DIR/.venv/bin/pip" install --quiet -r "$TOOL_DIR/requirements.txt"
  else
    log "WARNING: git pull failed; running the current checkout" >&2
  fi
fi

log "Running weekly gen3-helm image report ($TOOL_DIR)"
# exec replaces this shell, so the job's exit code is the Python script's.
exec "$DATA_DIR/.venv/bin/python" "$TOOL_DIR/weekly_slack_report.py" \
  --state "$DATA_DIR/state.json" "$@"
