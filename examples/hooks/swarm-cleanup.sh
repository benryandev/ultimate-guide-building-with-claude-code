#!/usr/bin/env bash
# swarm-cleanup.sh -- reap orphaned Agent Teams tmux swarms.
#
# Split-pane teammates run as separate tmux servers on sockets named
# claude-swarm-<pid>, where <pid> is the Claude session that spawned them. When a
# lead exits uncleanly the teammates keep running, idle, indefinitely.
#
# Wired to SessionStart (sweep orphans from earlier crashes) and SessionEnd
# (clean up after ourselves).
#
# TWO guards before anything is killed, because a false positive would destroy
# a colleague session's live work:
#   1. The owning PID must be dead.
#   2. The socket must be older than SWARM_MAX_IDLE_HOURS (default 4).
# Both must hold. A swarm whose name doesn't parse as a PID is never touched.
#
# Env:
#   SWARM_MAX_IDLE_HOURS  staleness threshold in hours (default 4)
#   SWARM_CLEANUP_DRYRUN  set to 1 to log decisions without killing

set -uo pipefail

THRESHOLD_HOURS="${SWARM_MAX_IDLE_HOURS:-4}"
DRYRUN="${SWARM_CLEANUP_DRYRUN:-0}"
LOG="$HOME/.claude/logs/swarm-cleanup.log"
mkdir -p "$(dirname "$LOG")"

log() { printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG"; }

# Hooks inherit a minimal PATH (often just /usr/bin:/bin:/usr/sbin:/sbin), so a
# Homebrew tmux is invisible unless we go looking for it. Failing silently here is
# exactly the bug this script exists to catch, so say so in the log.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
TMUX_BIN="$(command -v tmux 2>/dev/null || true)"
if [ -z "$TMUX_BIN" ]; then
  log "SKIP  tmux not found on PATH ($PATH) -- nothing to reap"
  exit 0
fi

SOCKET_DIR="${TMUX_TMPDIR:-/private/tmp}/tmux-$(id -u)"
[ -d "$SOCKET_DIR" ] || SOCKET_DIR="/tmp/tmux-$(id -u)"
[ -d "$SOCKET_DIR" ] || exit 0

now=$(date +%s)
reaped=0

for socket in "$SOCKET_DIR"/claude-swarm-*; do
  [ -S "$socket" ] || continue
  name=$(basename "$socket")
  pid="${name#claude-swarm-}"

  # Guard 0: the suffix must be a plain number, or we don't understand this
  # socket and must leave it alone.
  case "$pid" in
    ''|*[!0-9]*) log "SKIP  $name (suffix is not a pid)"; continue ;;
  esac

  # Guard 1: owning session still alive -> its teammates are legitimately running.
  if kill -0 "$pid" 2>/dev/null; then
    log "SKIP  $name (owner pid $pid alive)"
    continue
  fi

  # Guard 2: must also be stale, so a session mid-restart isn't caught.
  mtime=$(stat -f %m "$socket" 2>/dev/null || stat -c %Y "$socket" 2>/dev/null || echo "$now")
  age_h=$(( (now - mtime) / 3600 ))
  if [ "$age_h" -lt "$THRESHOLD_HOURS" ]; then
    log "SKIP  $name (owner dead but only ${age_h}h old, threshold ${THRESHOLD_HOURS}h)"
    continue
  fi

  panes=$("$TMUX_BIN" -S "$socket" list-panes -a 2>/dev/null | wc -l | tr -d ' ')
  if [ "$DRYRUN" = "1" ]; then
    log "DRYRUN would reap $name (owner $pid dead, ${age_h}h old, ${panes} panes)"
    continue
  fi

  if "$TMUX_BIN" -S "$socket" kill-server 2>/dev/null; then
    log "REAPED $name (owner $pid dead, ${age_h}h old, ${panes} panes)"
    reaped=$((reaped + 1))
  else
    # kill-server also fails when the server is already gone and only the socket
    # file is left behind. That is the common case, not an error -- removing the
    # file below still does the useful work.
    log "CLEARED $name (no server responding, stale socket file, ${age_h}h old)"
    reaped=$((reaped + 1))
  fi
  rm -f "$socket" 2>/dev/null
done

[ "$reaped" -gt 0 ] && log "reaped $reaped orphaned swarm(s)"
exit 0
