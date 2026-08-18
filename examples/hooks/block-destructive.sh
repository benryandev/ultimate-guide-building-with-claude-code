#!/usr/bin/env bash
# PreToolUse hook for the Bash tool.
#
# Receives the tool call as JSON on stdin. Emits a permission decision as JSON on
# stdout to deny, or exits 0 silently to fall through to the normal permission flow.
#
# Wire it up via examples/hooks/settings-hooks.json.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

# Patterns we never want executed, whatever the model decides.
DENY_PATTERNS=(
  'rm[[:space:]]+-rf[[:space:]]+/'
  'git[[:space:]]+push[[:space:]]+.*--force'
  'DROP[[:space:]]+DATABASE'
  '>[[:space:]]*/dev/sd'
)

for pattern in "${DENY_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qE "$pattern"; then
    jq -n --arg reason "Blocked by block-destructive.sh: matched /$pattern/" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
    exit 0
  fi
done

# No opinion -- normal permission flow applies.
exit 0
