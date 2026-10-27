# Changelog

## 2026-10-27 -- Verified against Claude Code v2.1.311

The second refresh. Re-checking against the Claude Code docs, the model pricing
pages and the anthropics/claude-code CHANGELOG turned up six claims that were wrong
when I wrote them, plus a set of things that have changed since August.

### Corrected -- wrong at time of writing

- **"Before v2.1.179 the default display mode was `auto`" is unsupported.** No
  changelog entry backs the version claim. Removed it; the default is `in-process`.
- **"Forks cannot spawn further forks" is unverified.** Removed. What is verified is
  that forks count toward the 3-level depth cap.
- **Auto-compaction has no fixed ~95% trigger.** By default it compacts at the
  model's context limit (about 967K tokens on native-1M models); `/autocompact
  <tokens>` sets an earlier trigger.
- **A skill does not cost "~1 line" at startup.** The listing entry is the
  `description` plus `when_to_use`, capped at 1,536 characters per skill, and the
  whole listing is budgeted at 1% of the context window. Reworded everywhere as
  "one description per skill (keep it short)".
- **Unspecified teammates do not simply inherit the lead's model.** Resolution runs:
  spawn prompt, the agent definition's `model`, `CLAUDE_CODE_SUBAGENT_MODEL`, then
  the lead's model.
- **Fable does not "investigate before acting" or "verify its own output".** Neither
  claim appears in any official source, which describes Fable 5.1 as "for demanding
  reasoning and long-horizon agentic work". Removed, along with the claim that
  "remember to test this" reminders are unnecessary.

Also corrected: teammates do load MCP servers (this guide said they only had project
CLAUDE.md and skills), exit code 2 on `PostToolUse` cannot block but its stderr is
shown to Claude (it was described as having "no effect"), and the 24-hand-built-skills
and 65-phase figures were out of date (see the README for the current numbers).

### Corrected -- changed since August

- **Model lineup replaced.** Fable 5.1 ($10/$50, 1M), Opus 5.5 ($4/$20, 1M, what
  `opus` resolves to), Sonnet 5.5 ($2/$10, 1M) and Haiku 5.5 ($0.10/$0.50, 1M; rises
  to $0.50/$2.50 for prompts over 100K tokens). Fable 5, Opus 5, Sonnet 5 and Haiku
  4.5 are now legacy but still available. `best` is Fable 5.1 where available, else
  Opus 5.5. Role guidance is unchanged, just renamed.
- **Opus got cheaper.** Opus 5.5 is $4/$20 per MTok, 20% below Opus 5's $5/$25.
- **Sonnet 5 introductory pricing was made permanent.** It launched at $2/$10 as
  introductory pricing through 31 August 2026; the scheduled rise to $3/$15 did not
  happen.
- **Effort defaults.** `high` remains the default on models that support it, but
  Opus 5.5, Sonnet 5.5 and Haiku 5.5 now default to `medium` (Opus 4.7 defaults to
  `xhigh`).
- **`ultracode` is a separate toggle since v2.1.284**, not a "`xhigh` plus
  workflows" effort setting. It runs at whichever effort level the session uses;
  only the `--effort ultracode` launch flag also sets `xhigh`.
- **Workflow `medium` size is now fewer than 10 agents** (lowered from 15 in
  v2.1.271). The default is `small` when signed in on Pro.
- **Path-scoped rules and child-directory CLAUDE.md load on more than reads.** They
  also load when Claude writes or edits a matching file (v2.1.288) and when Bash
  views a single file with `cat`, `head`, `tail`, `sed -n` or `grep` (v2.1.293).
- **Teammate and workflow model resolution.** `CLAUDE_CODE_SUBAGENT_MODEL` became a
  default rather than an override in v2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1`
  forces it (v2.1.257), and `CLAUDE_CODE_WORKFLOW_SUBAGENT_MODEL` pins every
  workflow agent to one model (v2.1.296).

### Fixed -- examples

- **`examples/hooks/block-destructive.sh` rewritten.** It now catches `rm -rf`,
  `-fr` and `-r -f` on `/`, `~` and `$HOME` in any flag order, allows
  `--force-with-lease`, and blocks `DROP SCHEMA` and writes to raw disk devices.
- **`examples/hooks/settings-hooks.json`:** the `PostToolUse` prettier command now
  handles paths containing spaces (`xargs -r -I{}`).
- **`examples/hooks/README.md`:** the demo now pipes JSON straight into the hook
  instead of asking Claude to run `rm -rf`.
- **Example agents given `tools:` and `model:`.** `accessibility-auditor`,
  `design-reviewer` and `responsive-tester` had only `name` and `description`, so
  they inherited every tool including Write, Edit and Bash. Each now has a read-only
  `tools:` list plus the Playwright tools it uses, and `model: sonnet`.

### Added

- `/doctor prompt-audit` (v2.1.283) in `docs/memory-hierarchy.md`: audits CLAUDE.md,
  rules, skills, agents and commands for stale paths and contradictions and proposes
  edits without making them.
- `AGENTS.md` fallback (v2.1.277) in `docs/memory-hierarchy.md`: read when no
  CLAUDE.md or CLAUDE.local.md exists at or above the working directory.
- `/skill-doctor` (v2.1.261) and `disable-model-invocation: true` in
  `docs/skills-strategy.md`.
- `PreModelSwitch` (v2.1.251) in the blocking list in `docs/hooks.md`, alongside
  `TeammateIdle`, `TaskCreated`, `TaskCompleted` and `PreCompact`.
- Linux/WSL and Windows managed-policy CLAUDE.md paths.
- Agent Teams: the `~/.claude/teams/` and `~/.claude/tasks/` cleanup behaviour, and
  that Claude may launch a subagent as a teammate unprompted while teams are enabled
  (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=0` reverts it).
- Workflow concurrency override (`CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS`, 1-256).

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
