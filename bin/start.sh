#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   runbook_start.sh <session_name>
# Example:
#   runbook_start.sh cla_commander_setup

NAME="${1:-cla_session}"
TS="$(date +%Y-%m-%d_%H%M%S)"
SESSION_DIR="$HOME/auto-runbook/runs/${TS}_${NAME}"
mkdir -p "$SESSION_DIR"

LOG_PATH="$SESSION_DIR/session.log"
META_PATH="$SESSION_DIR/meta.txt"

{
  echo "date: $(date -Is)"
  echo "host: $(hostname)"
  echo "user: $(whoami)"
  echo "cwd:  $(pwd)"
  echo "name: $NAME"
  echo "dir:  $SESSION_DIR"
} > "$META_PATH"

TMUX_SESSION="rb_${TS}_${NAME}"

# Start tmux session
tmux new-session -d -s "$TMUX_SESSION"

# Start logging everything printed in pane to file
tmux send-keys -t "$TMUX_SESSION" "echo '--- AUTO-RUNBOOK START: $(date -Is) ---' | tee -a '$LOG_PATH'" C-m
tmux pipe-pane -t "$TMUX_SESSION" -o "cat >> '$LOG_PATH'"

# Helpful prompt note
tmux send-keys -t "$TMUX_SESSION" "echo 'Logging to: $LOG_PATH'" C-m
tmux send-keys -t "$TMUX_SESSION" "echo 'When done, type: exit'" C-m

# Attach
tmux attach -t "$TMUX_SESSION"

# After exit, tmux session usually closes; create runbook automatically
echo "茶 Session ended. Generating runbook..."
"$HOME/auto-runbook/bin/summarize_run.sh" "$SESSION_DIR"
echo "✅ Done. Open: $SESSION_DIR/runbook.md"

cd "$HOME/auto-runbook"
git add runs
git commit -m "Runbook: $(basename "$SESSION_DIR")" || true
