# Hooks: Enforcement Instead of Suggestion

CLAUDE.md shapes behaviour. Hooks enforce it. This distinction is the single most
useful thing to understand about Claude Code configuration, and the original version
of this repo missed it entirely.

## Why Hooks Exist

CLAUDE.md content is delivered to Claude as a user message after the system prompt.
It is **context, not enforced configuration**. Claude reads it and tries to follow
it, but there is no guarantee of compliance -- especially for vague instructions, or
when a long session has pushed the rule far up the context window.

The failure mode is nastier than outright non-compliance: an instruction that works
*most* of the time. Intermittent adherence is invisible until you audit and find the
gaps.

> **The test:** if you have written "always" or "never" in CLAUDE.md and then found
> yourself checking whether it actually happened, that instruction wants to be a hook.

## Hook Events

There are over 30 events (33 are listed in the docs). These are the ones worth knowing first:

| Event | Fires When | Typical Use |
|-------|-----------|-------------|
| `PreToolUse` | Before a tool call executes | Block destructive commands, validate inputs |
| `PostToolUse` | After a tool call succeeds | Auto-format, lint, run type checks |
| `PostToolUseFailure` | After a tool call fails | Log, notify, attempt recovery |
| `UserPromptSubmit` | Before Claude processes a prompt | Inject context, reject unsafe prompts |
| `SessionStart` | Session begins or resumes | Load state, check for updates |
| `SessionEnd` | Session terminates | Persist state, clean up |
| `Stop` | Claude finishes responding | Enforce a quality gate before the turn ends |
| `SubagentStart` / `SubagentStop` | A subagent spawns / finishes | Track delegated work |
| `PreCompact` / `PostCompact` | Around context compaction | Save or restore state across compaction |
| `InstructionsLoaded` | CLAUDE.md or a rules file loads | Debug which instructions actually loaded |
| `TeammateIdle` | An Agent Teams teammate goes idle | Send feedback and keep it working |
| `TaskCreated` / `TaskCompleted` | Shared task list changes | Enforce task hygiene |

## Exit Code 2 Is the Whole Mechanism

A hook that exits with code **2** is a blocking error. Where it blocks depends on
whether the event represents a preventable action:

**Blocks:**
- `PreToolUse` -- blocks the tool call
- `UserPromptSubmit` -- blocks prompt processing
- `Stop` / `SubagentStop` -- prevents stopping, continues the conversation
- `PostToolBatch` -- stops the agentic loop before the next model call
- `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `PreCompact`
- `PreModelSwitch` (v2.1.251)
- `ConfigChange`, `Elicitation`, `WorktreeCreate`

**Cannot block** (the action already happened, but stderr is shown to Claude):
- `PostToolUse`, `PostToolUseFailure`, `PermissionDenied`

Any other non-zero exit without valid JSON is treated as a non-blocking error and
execution continues.

## Where Hooks Live

| Location | Scope | Shareable |
|----------|-------|-----------|
| `~/.claude/settings.json` | All projects | No (local machine) |
| `.claude/settings.json` | Single project | Yes (commit it) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| `hooks/hooks.json` in a plugin | Wherever the plugin is enabled | Yes (bundled) |
| Skill or subagent frontmatter | Current session | Yes (in the file) |
| Managed policy settings | Organisation-wide | Yes (admin-controlled) |

## Worked Example: Block Destructive Commands

See [`examples/hooks/`](../examples/hooks/) for the runnable version.

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-destructive.sh"
          }
        ]
      }
    ]
  }
}
```

The hook receives the tool input as JSON on stdin and returns a permission decision
as JSON on stdout. Returning nothing and exiting 0 means "no opinion" -- the normal
permission flow applies.

## Worked Example: Format After Every Edit

The most common useful hook. No decision logic, just a side effect:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs -r npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

## Debugging Hooks

- Run `claude --debug` to see which hooks matched, their exit codes, and their output.
- Use the `InstructionsLoaded` hook to log exactly which instruction files load, when, and why. This is the fastest way to diagnose a path-scoped rule that isn't firing.
- A hook that fails to run is reported as a non-blocking error; check the debug log rather than assuming it worked.

## When *Not* to Use a Hook

- **Advisory guidance.** "Prefer composition over inheritance" is a CLAUDE.md line, not a hook.
- **Anything needing judgement.** Hooks are shell commands; they cannot reason about intent.
- **Things a linter already does on commit.** Do not duplicate CI in a hook unless you want the feedback inside the session.

## Further Reading

- See `docs/memory-hierarchy.md` for what CLAUDE.md *is* good at
- See `examples/hooks/` for runnable configurations
