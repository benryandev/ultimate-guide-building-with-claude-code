# Hook Examples

| File | What it shows |
|------|---------------|
| `settings-hooks.json` | The `hooks` block to merge into `.claude/settings.json` -- a `PreToolUse` guard, a `PostToolUse` formatter, and a `SessionStart` fetch |
| `block-destructive.sh` | A runnable `PreToolUse` hook that denies destructive shell commands |

## Trying it

1. Merge the `hooks` object from `settings-hooks.json` into your `.claude/settings.json`.
2. Copy `block-destructive.sh` to `.claude/hooks/` and make it executable.
3. Ask Claude to run `rm -rf /tmp/something`. The hook denies it and shows the reason.

Run `claude --debug` to see which hooks matched and how they exited.

See [`docs/hooks.md`](../../docs/hooks.md) for the full event list and exit-code semantics.
