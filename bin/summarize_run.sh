#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   summarize_run.sh <session_dir> [model]
# Example:
#   summarize_run.sh ~/auto-runbook/runs/2026-02-11_0930_cla llama3.1

SESSION_DIR="${1:-}"
MODEL="${2:-glm-4.7-flash}"

if [[ -z "$SESSION_DIR" || ! -d "$SESSION_DIR" ]]; then
  echo "ERROR: Provide a valid session directory."
  echo "Usage: $0 <session_dir> [model]"
  exit 1
fi

LOG_PATH="$SESSION_DIR/session.log"
OUT_PATH="$SESSION_DIR/runbook.md"

if [[ ! -f "$LOG_PATH" ]]; then
  echo "ERROR: Missing log file: $LOG_PATH"
  exit 1
fi

SESSION_NAME="$(basename "$SESSION_DIR")"
DATE_STR="$(date -Is)"
HOST="$(hostname)"
USER_NAME="$(whoami)"
PWD_STR="$(pwd)"

# Read log (cap extremely large logs to last N lines to keep AI fast/stable)
MAX_LINES=8000
LOG_TEXT="$(tail -n "$MAX_LINES" "$LOG_PATH")"

AI_RUNBOOK=""

if command -v ollama >/dev/null 2>&1; then
  PROMPT=$(cat <<'PROMPT_EOF'
You are an expert SRE who writes clean runbooks.

Convert this raw Linux terminal session log into a structured Markdown runbook.

Rules:
- Do NOT invent facts. If unsure, write "Unknown".
- Keep it practical and short.
- Include these sections exactly (in this order):
  1) Objective
  2) Environment
  3) Step-by-step (numbered)
  4) Commands (code blocks)
  5) Errors & Fixes
  6) Result
  7) Artifacts
- Focus on CLA Commander actions, configs, networking, versions, and failures/retries.
PROMPT_EOF
)
export MODEL PROMPT LOG_TEXT OUT_PATH LOG_PATH SESSION_NAME SESSION_DIR DATE_STR HOST USER_NAME PWD_STR MAX_LINES AI_RUNBOOK
  AI_RUNBOOK="$(python3 - <<PY
import os, subprocess, textwrap

model = os.environ["MODEL"]
prompt = os.environ["PROMPT"]
log_text = os.environ["LOG_TEXT"]

full = prompt + "\n\nSESSION LOG:\n---\n" + log_text + "\n---\n"

p = subprocess.run(
    ["ollama", "run", model],
    input=full,
    text=True,
    capture_output=True
)
if p.returncode != 0:
    print("")
else:
    print(p.stdout.strip())
PY
)"
else
  echo "WARN: ollama not found; generating a basic runbook without AI."
fi

# Fallback if AI returned empty
if [[ -z "$AI_RUNBOOK" ]]; then
  AI_RUNBOOK=$(cat <<FALLBACK
## Objective
Unknown (AI summarization unavailable).

## Environment
- Date: $DATE_STR
- Host: $HOST
- User: $USER_NAME

## Step-by-step
1. See raw log.

## Commands
(See raw log.)

## Errors & Fixes
(See raw log.)

## Result
Unknown.

## Artifacts
- Raw log: $LOG_PATH
FALLBACK
)
fi

# Write final runbook with a small header
python3 - <<PY
from pathlib import Path
import os

out_path = Path(os.environ["OUT_PATH"])
session_name = os.environ["SESSION_NAME"]
date_str = os.environ["DATE_STR"]
host = os.environ["HOST"]
user = os.environ["USER_NAME"]
log_path = os.environ["LOG_PATH"]
runbook = os.environ["AI_RUNBOOK"]

header = f"# Runbook: {session_name}\n\n- Date: {date_str}\n- Host: {host}\n- User: {user}\n- Raw log: {log_path}\n\n---\n\n"
out_path.write_text(header + runbook.strip() + "\n")
print(f"✅ Runbook created: {out_path}")
PY

