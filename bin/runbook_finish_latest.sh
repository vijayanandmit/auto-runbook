#!/usr/bin/env bash
set -euo pipefail

LATEST_DIR="$(ls -td "$HOME/auto-runbook/runs/"* | head -n 1 || true)"
if [[ -z "$LATEST_DIR" ]]; then
  echo "No runs found."
  exit 1
fi

"$HOME/auto-runbook/bin/summarize_run.sh" "$LATEST_DIR"
echo "✅ Updated runbook: $LATEST_DIR/runbook.md"
