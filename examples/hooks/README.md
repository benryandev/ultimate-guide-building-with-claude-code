# Hook Examples

| File | What it shows |
|------|---------------|
| `settings-hooks.json` | The `hooks` block to merge into `.claude/settings.json` -- a `PreToolUse` guard, a `PostToolUse` formatter, and a `SessionStart` fetch |
| `block-destructive.sh` | A runnable `PreToolUse` hook that denies destructive shell commands |
| `swarm-cleanup.sh` | A `SessionStart`/`SessionEnd` hook that reaps orphaned Agent Teams tmux swarms |

## Trying it

1. Merge the `hooks` object from `settings-hooks.json` into your `.claude/settings.json`.
2. Copy `block-destructive.sh` to `.claude/hooks/` and make it executable.
3. Ask Claude to run `rm -rf /tmp/something`. The hook denies it and shows the reason.

Run `claude --debug` to see which hooks matched and how they exited.

## Reaping orphaned swarms

Split-pane teammates are separate processes and survive a lead that exits uncleanly,
idling indefinitely. `swarm-cleanup.sh` reaps `claude-swarm-*` tmux sockets. Wire it
to both `SessionStart` (sweep orphans from earlier crashes) and `SessionEnd` (clean
up after yourself) by merging this into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/swarm-cleanup.sh\"" }] }
    ],
    "SessionEnd": [
      { "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/swarm-cleanup.sh\"" }] }
    ]
  }
}
```

It refuses to kill anything unless **both** the owning PID is dead **and** the socket
is older than `SWARM_MAX_IDLE_HOURS` (default 4), and it never touches a socket whose
name suffix does not parse as a PID. A false positive would destroy another session's
live work, so test with `SWARM_CLEANUP_DRYRUN=1` first and read
`~/.claude/logs/swarm-cleanup.log`.

The better fix is to not need it: set `teammateMode: "in-process"` and teammates
cannot outlive the lead at all.

See [`docs/hooks.md`](../../docs/hooks.md) for the full event list and exit-code semantics.
