#!/usr/bin/env bash
# PreToolUse hook for the Bash tool.
#
# Receives the tool call as JSON on stdin. Emits a permission decision as JSON on
# stdout to deny, or exits 0 silently to fall through to the normal permission flow.
#
# Wire it up via examples/hooks/settings-hooks.json.
#
# This is a backstop, not a sandbox: a determined command can always be phrased to slip
# past a regex. It catches the common shapes and errs toward denying.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

deny() {
  jq -n --arg reason "Blocked by block-destructive.sh: $1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

matches() { printf '%s' "$COMMAND" | grep -qE "$1"; }

# Recursive rm aimed at the filesystem root or the home directory, in any flag order:
# rm -rf /, rm -fr ~, rm -r -f "$HOME", rm --recursive --force /*
if matches '(^|[;&|[:space:]])rm[[:space:]]' &&
   matches '[[:space:]](-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)([[:space:]]|$)' &&
   matches '[[:space:]]"?(/|/\*|~|~/|~/\*|\$HOME|\$HOME/|\$\{HOME\})"?([[:space:];&|]|$)'; then
  deny "recursive rm targeting / or the home directory"
fi

# Force push. --force-with-lease is the safe variant and is deliberately allowed.
if matches 'git[[:space:]]+push([[:space:]].*)?[[:space:]](--force|-f)([[:space:]]|$)'; then
  deny "git push --force (use --force-with-lease)"
fi

if matches '(DROP|drop)[[:space:]]+(DATABASE|database|SCHEMA|schema)'; then
  deny "DROP DATABASE/SCHEMA"
fi

if matches '>[[:space:]]*/dev/(sd|nvme|disk)'; then
  deny "write to a raw disk device"
fi

# No opinion -- normal permission flow applies.
exit 0
