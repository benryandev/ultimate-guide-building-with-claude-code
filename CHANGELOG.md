# Changelog

## 2026-08-18 -- Verified against Claude Code v2.1.234

The first substantive refresh since publication. Six months of Claude Code releases
invalidated several claims here, and re-checking turned up four that were wrong when
originally written, not merely stale.

### Corrected -- wrong at time of writing

- **"Delegate Mode (`Shift+Tab`)" never existed.** It appeared twice in
  `agent-teams-guide.md` and once in `visual-design-loop.md`. `Shift+Tab` cycles
  *permission* modes (`default`, `acceptEdits`, `plan`, `bypassPermissions`, `auto`).
  There is no delegation mode to switch into -- you describe the team you want in
  plain language. Removed and replaced with the actual guidance.
- **`@`-imports do not defer loading.** `context-engineering.md` claimed Claude
  "reads the referenced file when it determines it is relevant". Imported files are
  expanded and loaded into context **at launch**. Imports organise; they do not save
  context. Only skills and path-scoped rules defer.
- **The memory hierarchy had eight layers listed, not ten.** Managed-policy
  CLAUDE.md was missing entirely (it existed all along and cannot be excluded by
  user settings), and path-scoped rules were folded in with unconditional rules
  despite having completely different loading behaviour.
- **The "under 500 lines" CLAUDE.md target was my own guess.** Anthropic's published
  guidance is **under 200 lines** per file. Corrected, with a note on `/doctor`'s
  trim proposals.

### Corrected -- changed since February

- **Agent Teams display mode.** The default is now `in-process` (any terminal, no
  setup), not tmux. Before v2.1.179 the default was `auto`, which is why older
  setups opened split panes and newer ones don't.
- **`launch-team.sh` removed.** The script killed and recreated a tmux session
  before launching Claude. It is obsolete: team directories clean up automatically
  on session exit, and in-process mode needs no session management.
- **`teammateDefaultModel` removed in v2.1.234.** Name teammate models in the spawn
  prompt or set `CLAUDE_CODE_SUBAGENT_MODEL`. A leftover value is ignored.
- **Model lineup replaced.** Fable 5 ($10/$50, 1M), Opus 5 ($5/$25, 1M, what `opus` resolves to),
  Sonnet 5 ($2/$10, 1M), Haiku 4.5 ($1/$5, 200K). Fable 5 is a genuinely new tier
  above Opus for long autonomous sessions.
- **Auto memory limit.** Loads the first 200 lines **or 25KB**, whichever comes
  first -- not just the line count.
- **Issue #16299 rescoped.** The headline bug (path-scoped rules loading globally)
  is no longer reproducible; see the fact-check note below on why no version is
  cited. The issue remains open for two narrower traps:
  unscoped `.md` files anywhere under `.claude/rules/` load at launch and discovery
  is recursive; and `@`-imports inside a path-scoped rule load unconditionally.
- **Subagent `skills:` and `mcpServers:` frontmatter is ignored when the definition
  runs as a teammate.** Teammates load skills from project and user settings like a
  normal session.
- **`svg-generator` renamed** to `image-prompter` in the content pipeline example.

### Caught in the fact-check pass

- **The 200-subagent-per-session spawn cap no longer exists.** It was removed in
  v2.1.224; only the depth (3) and concurrency (20) limits still apply. The docs
  page still listed it, so this was verified against the changelog instead --
  a reminder that docs can lag releases.
- **The #16299 fix is not pinned to a version.** Earlier drafts of this refresh
  said "fixed around v2.1.63". No changelog entry supports that; the evidence is a
  reporter's confirmation plus local observation. Reworded to say the behaviour is
  no longer reproducible and to tell readers to verify with `/context`.
- **Opus 5 is the default *Opus* model, not every account's default model.** The
  `default` alias resolves to whatever is recommended for your account type.

### Added

- `docs/plugins.md` -- packaging and distribution, marketplaces, build vs install.
- `docs/hooks.md` -- the enforcement layer the original repo omitted entirely.
- `docs/subagents-and-workflows.md` -- forks (`/subtask`) and dynamic workflows, plus
  a decision table for choosing a parallelism primitive.
- `examples/hooks/` -- runnable `PreToolUse` guard, `PostToolUse` formatter, and
  `SessionStart` bootstrap.
- `examples/skills/claude-code-reference/` -- the reference tables extracted out of
  an always-on CLAUDE.md into an on-demand skill, as a worked example of the
  principle this repo argues for.
- Context engineering rules 8 and 9: effort levels and per-job model selection.
- An Agent Teams limitations section.

### Added later the same day

- **The orphaned-swarm failure mode**, documented in `agent-teams-guide.md` and
  addressed by `examples/hooks/swarm-cleanup.sh`. Split-pane teammates are separate
  processes that survive an unclean lead exit and idle indefinitely; a real swarm
  accumulated 24 idle teammates over nearly three days before anyone noticed.
  In-process teammates cannot orphan, which is the strongest argument for the
  default display mode.

### Changed

- `examples/global-config/global-claude.md` slimmed from 85 to 53 lines by moving
  the reference tables into the `claude-code-reference` skill.
- `examples/global-config/settings.json` now shows `teammateMode: "in-process"` and
  an explicit effort level.

## 2026-02-12 -- Initial release

Companion repo published alongside the original article: five deep-dive docs,
example CLAUDE.md files, skills, agents, rules, and MCP configs.
