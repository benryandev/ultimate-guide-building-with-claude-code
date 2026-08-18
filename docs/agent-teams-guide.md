# Agent Teams: Patterns and Model Selection

Agent Teams allow Claude Code to coordinate multiple AI agents working in parallel on different aspects of a project. A lead agent decomposes work and delegates to teammates, each operating in their own context window. This guide covers how to enable Agent Teams, select models, and apply proven coordination patterns.

## Enabling Agent Teams

Agent Teams are experimental and **disabled by default**, and have been since they
shipped as a research preview in v2.1.32. Without this variable no team is set up,
no team directories are written, and Claude will not spawn teammates however you
phrase the request. Enable them by adding an environment variable to your global
settings:

**In `~/.claude/settings.json`:**

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Once enabled, describe the task and the teammates you want in plain language -- Claude spawns them and coordinates the work. There is no separate mode to switch into. (`Shift+Tab` cycles *permission* modes, not delegation; earlier versions of this guide called it "Delegate Mode", which was never a real feature.)

## Choosing a Display Mode

The default is **`in-process`**: every teammate runs inside your main terminal and
you move between them with the arrow keys, Enter to open a transcript, Escape to
interrupt. It works in any terminal with no extra setup.

Split panes -- one pane per teammate -- require tmux or iTerm2 with the `it2` CLI,
and are opt-in via `teammateMode`:

```json
{ "teammateMode": "in-process" }
```

Valid values are `in-process` (default), `auto`, `tmux`, and `iterm2`. Before
v2.1.179 the default was `auto`, which is why older setups opened split panes
automatically and newer ones don't.

> **Removed from this repo:** earlier versions shipped a `launch-team.sh` script that
> killed and recreated a tmux session before launching Claude. It is obsolete. Team
> directories are cleaned up automatically when the session ends, and in-process mode
> needs no session management at all.

## Model Selection Strategy

Not every task needs the most powerful model. Matching models to task complexity saves cost while maintaining quality where it matters.

| Model | Alias | Context | $/Mtok (in/out) |
|-------|-------|---------|-----------------|
| Claude Fable 5 | `fable` | 1M | $10 / $50 |
| Claude Opus 5 | `opus` | 1M | $5 / $25 |
| Claude Sonnet 5 | `sonnet` | 1M | $2 / $10 |
| Claude Haiku 4.5 | `haiku` | 200K | $1 / $5 |

| Role | Model | Rationale |
|------|-------|-----------|
| **Team Lead** | **Opus 5** | Best reasoning, coordination, and synthesis. Handles complex task decomposition and quality assessment. |
| **Teammate (default)** | **Sonnet 5** | Good balance of capability and cost for most implementation tasks. |
| **Teammate (escalated)** | **Opus 5** | For highly technical tasks -- see escalation criteria below. |
| **Teammate (long-running)** | **Fable 5** | Work that would otherwise span several sittings. Investigates before acting and verifies its own output. |
| **Sub-agent (read-only/research)** | **Haiku 4.5** | Fast, cheap, sufficient for file search and codebase exploration. |
| **Sub-agent (code changes)** | **Sonnet 5** | Default for implementation sub-agents. |
| **Sub-agent (complex/critical)** | **Opus 5** | Security audits, architecture decisions, complex refactors. |

**How to set a teammate's model:** name it in the spawn prompt ("use Sonnet for each
teammate"), or set `CLAUDE_CODE_SUBAGENT_MODEL`. The `teammateDefaultModel` setting
was **removed in v2.1.234** and a leftover value is ignored. Teammates you don't
specify a model for inherit the lead's model, and all teammates inherit the lead's
effort level.

### When to Escalate Teammates to Opus

Escalate from Sonnet to Opus when a teammate's task involves:

- Complex architecture decisions spanning multiple modules
- Security-critical code (authentication, cryptography, input validation, API security)
- Performance-sensitive implementations (render optimisation, bundle splitting)
- Intricate animation choreography (coordinated timelines, scroll-triggered chains)
- Tasks requiring deep reasoning across multiple codebases
- Quality gate or final review tasks where accuracy is paramount

## Team Patterns

### Pattern 1: Parallel Page Build

Best for building multiple independent pages or components simultaneously.

```
Lead (Opus): Breaks work into page-level tasks
  |-- Teammate A (Sonnet): Builds /services page
  |-- Teammate B (Sonnet): Builds /about page
  |-- Teammate C (Sonnet): Builds /contact page
  +-- Lead synthesises, reviews consistency, merges
```

**Key considerations:**
- Each teammate owns distinct files to avoid write conflicts
- The lead ensures design consistency across pages after teammates complete their work
- Pass rich context in spawn prompts since teammates do not inherit the lead's conversation history

### Pattern 2: Design Review Team

Best for comprehensive quality assurance across multiple pages.

```
Lead (Opus): Coordinates review, collates feedback, ensures consistency
  |-- Teammate A (Sonnet): Screenshots all pages via Playwright, reports issues
  |-- Teammate B (Sonnet): Accessibility audit (axe-core, a11y tree)
  |-- Teammate C (Sonnet): Performance audit (Lighthouse, bundle analysis)
  +-- Lead prioritises findings, assigns fixes, verifies
```

**Key considerations:**
- Each teammate captures a different quality dimension
- The lead collates feedback and identifies cross-cutting issues
- After fixes, the team can re-run checks to verify improvements

### Pattern 3: Research + Implement

Best when the approach requires investigation before coding.

```
Lead (Opus): Decomposes problem, assigns research vs implementation
  |-- Teammate A (Opus): Researches architecture approach (escalated -- complex)
  |-- Teammate B (Sonnet): Implements based on research findings
  |-- Teammate C (Sonnet): Writes tests for the implementation
  +-- Lead reviews, ensures architectural consistency
```

**Key considerations:**
- Research teammate should be escalated to Opus for complex decisions
- Implementation depends on research findings, so the lead sequences these
- The test-writing teammate can work in parallel with later implementation tasks

## Best Practices

### For Agent Teams

1. **Tell the lead to wait for its teammates.** Leads sometimes start implementing instead of delegating. "Wait for your teammates to complete their tasks before proceeding" fixes it.

2. **Assign 5--6 tasks per teammate** -- this keeps everyone productive and lets the lead reassign work if someone gets stuck.

3. **Avoid file conflicts** -- each teammate should own distinct files. Two teammates editing the same file causes overwrites and lost work.

4. **Give teammates rich context in spawn prompts** -- teammates do not inherit the lead's conversation history. They only have access to project CLAUDE.md and skills. Include relevant decisions, constraints, and design specifications in the spawn prompt.

5. **Require plan approval for risky tasks** -- for tasks that could have significant architectural impact, instruct the teammate to present a plan before making changes.

6. **Keep the team small** -- start with 3--5 teammates. Token cost scales linearly and coordination overhead scales worse. Three focused teammates routinely outperform five scattered ones.

7. **Shut down through the lead** -- ask the lead to send a shutdown request so teammates can finish cleanly. You no longer need to clean up after them: team config directories are removed automatically when the session ends.

### For Sub-agents

1. **Always preload relevant skills** via the `skills:` field when creating custom sub-agents. This is the single highest-leverage improvement for sub-agent quality.

   **Caveat:** the `skills:` and `mcpServers:` frontmatter fields are **not applied when a subagent definition runs as a teammate**. Teammates load skills and MCP servers from project and user settings like a normal session. If a role depends on preloaded skills, run it as a subagent, not a teammate.

2. **Use persistent memory** (`memory: user` or `memory: project`) for sub-agents that run repeatedly -- they build knowledge over time.

3. **Isolate high-volume operations** -- test suites, log analysis, dependency audits -- in sub-agents to keep the main context clean.

4. **Resume sub-agents** instead of spawning new ones when continuing the same task. This preserves accumulated context.

5. **Prefer a fork when the task needs this conversation.** `/subtask` spawns a subagent that inherits the full conversation and reuses the prompt cache, making it *cheaper* than a fresh subagent rather than more expensive.

## Limitations

Agent Teams is experimental, and these constraints bite in practice:

- **No session resumption for in-process teammates.** `/resume` and `/rewind` do not restore them; the lead may try to message teammates that no longer exist.
- **Task status can lag.** Teammates sometimes fail to mark tasks complete, which blocks dependent tasks.
- **No nested teams.** Teammates cannot spawn their own teammates.
- **The lead is fixed** for the session and cannot be transferred.
- **Permissions are set at spawn.** All teammates start with the lead's permission mode.
- **Split panes need tmux or iTerm2** -- unsupported in VS Code's integrated terminal, Windows Terminal, and Ghostty.

## When to Use Agent Teams vs Single-Threaded

| Scenario | Approach | Why |
|----------|----------|-----|
| Building 4 independent pages | Agent Teams | Pages have no dependencies, parallelize well |
| Sequential feature with tests | Single-threaded | Each step depends on the previous |
| Cross-cutting quality audit | Agent Teams | Different audit dimensions are independent |
| Database schema + API + UI | Hybrid | Schema first (single), then API + UI in parallel |
| Research + implementation | Agent Teams | Research and test setup can run while implementation is sequenced |

## Example: Creating a Custom Sub-agent

Sub-agents are defined as Markdown files in `.claude/agents/`:

```markdown
---
name: design-reviewer
description: Reviews UI screenshots for quality, consistency, and UX issues.
tools: Read, Bash, Grep, Glob
model: sonnet
skills:
  - visual-design-review
---

You are a senior UI/UX designer. Review screenshots and provide actionable feedback.

## Process
1. Assess visual hierarchy and spacing consistency
2. Evaluate typography and colour contrast
3. Check responsive adaptation at each breakpoint
4. Score each dimension 1-10

## Output Format
Provide specific, actionable fixes with CSS/component references.
```

**Key fields:**
- `skills:` -- Preloads relevant skills at startup
- `model:` -- Choose based on task complexity (see selection table above)
- `tools:` -- Restrict to only what the sub-agent needs

## Further Reading

- See `examples/agents/` for complete sub-agent definitions
- See `docs/visual-design-loop.md` for how teams coordinate design reviews
- See `docs/context-engineering.md` for managing context across parallel agents
- See `docs/subagents-and-workflows.md` for when a workflow beats a team
