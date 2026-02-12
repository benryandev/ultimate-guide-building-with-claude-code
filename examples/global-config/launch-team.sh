#!/usr/bin/env bash
# launch-team.sh -- Clean tmux session for Agent Teams
# Usage: launch-team.sh [project-dir] [session-name]

set -euo pipefail

PROJECT_DIR="${1:-.}"
SESSION_NAME="${2:-claude-team}"

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# Kill existing session if present (clean slate)
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

# Create new tmux session in the project directory
tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR"

# Launch Claude in the first pane
tmux send-keys -t "$SESSION_NAME" "claude" C-m

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
