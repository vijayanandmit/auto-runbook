#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   summarize_run.sh <session_dir> [model]
#
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
TPL_PATH="$HOME/auto-runbook/templates/runbook_template.md"

if [[ ! -f "$LOG_PATH" ]]; then
  echo "ERROR: Missing log file: $LOG_PATH"
  exit 1
fi

HOST="$(hostname)"
USER_NAME="$(whoami)"
DATE_STR="$(date -Is)"
PWD_STR="$(pwd)"
SESSION_NAME="$(basename "$SESSION_DIR")"

# Small helper: extract likely commands (best-effort)
# This won't catch everything (because logs include output), but it's useful.
COMMANDS_EXTRACT="$(grep -E '^[[:alnum:]_./-]+|^\$ |^# ' "$LOG_PATH" | tail -n 200 || true)"

PROMPT=$(cat <<PROMPT_EOF
You are an expert SRE who writes clean runbooks.

Given a raw Linux terminal session log, produce a structured Markdown runbook.

Hard requirements:
- Use concise headings and bullets.
- Provide a step-by-step section with numbered steps.
- Extract important commands in code blocks.
- Include an "Errors & Fixes" section (even if empty).
- Include a "Result" section (best guess based on log).
- Do NOT invent facts. If unsure, say "Unknown".

Output ONLY the runbook content for insertion into a template:
- STEPS (bullets + numbered steps)
- COMMANDS (code blocks)
- ERRORS (bullets/table)
- RESULT (short bullets)

Here is the session log:
---
$(cat "$LOG_PATH")
---

If the log is huge, focus on:
- CLA Commander steps
- config edits
- network actions
- file paths
- version checks
- failures/retries
PROMPT_EOF
)

# Call ollama (offline). If ollama isn't available, fail clearly.
if ! command -v ollama >/dev/null 2>&1; then
  echo "ERROR: ollama not found. Install Ollama or modify this script to use another AI tool."
  exit 1
fi

AI_OUT="$(printf "%s" "$PROMPT" | ollama run "$MODEL")"

# Split AI_OUT into sections (simple heuristic):
# We ask the model to output content; we’ll just embed it as STEPS for now if not labeled.
STEPS="$AI_OUT"
COMMANDS="$COMMANDS_EXTRACT"
ERRORS="(See Steps section; if none found, leave empty.)"
RESULT="(See Steps section.)"

# Render template
sed \
  -e "s|{{SESSION_NAME}}|$SESSION_NAME|g" \
  -e "s|{{DATE}}|$DATE_STR|g" \
  -e "s|{{HOST}}|$HOST|g" \
  -e "s|{{USER}}|$USER_NAME|g" \
  -e "s|{{PWD}}|$PWD_STR|g" \
  -e "s|{{LOG_PATH}}|$LOG_PATH|g" \
  -e "s|{{STEPS}}|$STEPS|g" \
  -e "s|{{COMMANDS}}|$(printf "%s" "$COMMANDS" | sed 's/[&/\]/\\&/g')|g" \
  -e "s|{{ERRORS}}|$ERRORS|g" \
  -e "s|{{RESULT}}|$RESULT|g" \
  "$TPL_PATH" > "$OUT_PATH"

echo "✅ Runbook created: $OUT_PATH"
