# Subagents, Forks and Workflows: Choosing a Parallelism Primitive

Agent Teams is the heaviest of four ways to parallelise work in Claude Code, and for
most tasks it is not the right one. This document covers the other three, two of
which did not exist when this repo was first published.

## The Decision Table

| | Subagents | Skills | Agent Teams | Workflows |
|---|---|---|---|---|
| **What it is** | A worker Claude spawns | Instructions Claude follows | Peer sessions under a lead | A script the runtime executes |
| **Who decides what runs next** | Claude, turn by turn | Claude, following the prompt | The lead, turn by turn | The script |
| **Where intermediate results live** | Claude's context window | Claude's context window | A shared task list | Script variables |
| **What's repeatable** | The worker definition | The instructions | The team definition | The orchestration itself |
| **Scale** | A few per turn | Same as subagents | A handful of long-running peers | Dozens to hundreds per run |
| **On interruption** | Restarts the turn | Restarts the turn | Teammates keep running | Resumable in the same session |

The distinction that matters: with subagents, skills and teams, **Claude is the
orchestrator** and every result lands in a context window. With a workflow, **the
script is the orchestrator** and Claude's context holds only the final answer.

## Subagents

A subagent runs a single task in its own context window and returns a summary. Use
one whenever an operation would otherwise dump volume into your main context: test
runs, log analysis, dependency audits, reading fifty files to answer one question.

**Defaults worth knowing:**

- Subagents run in the **background by default** in interactive sessions. Background subagents get a restricted tool set; foreground ones get the full set and block the conversation.
- Caps: **3 levels of nesting** and **20 concurrent**. The 200-per-session spawn cap was removed in v2.1.224, so long-running sessions no longer refuse new agents.
- Two built-ins are worth using by name: **`Explore`** for read-only codebase search and **`Plan`** for research in plan mode. Both deliberately skip loading CLAUDE.md and the git status snapshot -- a file-search agent does not need your commit message conventions.

Define custom ones in `.claude/agents/*.md`. See [`examples/agents/`](../examples/agents/).

## Forks

A **fork** is a subagent that inherits the entire parent conversation -- history,
system prompt, tools, model -- instead of starting fresh.

```
/subtask investigate why the checkout test is flaky
```

The economics are counter-intuitive and worth internalising: because a fork reuses
the parent's **prompt cache**, it is *cheaper* than spawning a clean subagent, not
more expensive. The old advice -- "spawn a fresh subagent to keep context clean" --
is now wrong for any task that actually needs the conversation's context.

**Use a fork when:** the side task depends on what you have already discussed.
**Use a fresh subagent when:** a clean context window is the actual point.

Forks cannot spawn further forks, and they share the parent's permissions.

## Workflows

A dynamic workflow is a JavaScript script that orchestrates subagents at scale.
Claude writes the script for the task you describe; a runtime executes it in the
background while your session stays responsive.

Reach for one when a task needs more agents than one conversation can coordinate, or
when you want the orchestration itself codified and rerunnable:

- A codebase-wide bug sweep
- A 500-file migration
- A research question whose sources need cross-checking against each other
- A plan worth drafting from several independent angles before committing

**Starting one:**

```
ultracode: audit every API endpoint under src/routes/ for missing auth checks
```

Or just ask in plain words -- "use a workflow to ..." is treated as the same opt-in.
`/deep-research <question>` is a bundled workflow that fans out searches, cross-checks
sources, and returns a cited report with unsupported claims filtered out.

**Watching and saving:** `/workflows` lists runs and opens a progress view showing
each phase's agent count, token total and elapsed time. Press `p` to pause, `x` to
stop, and `s` to save the run's script as a reusable `/command` in
`.claude/workflows/` or `~/.claude/workflows/`.

**Limits:** 16 concurrent agents, 1,000 agents per run, no mid-run user input, no
filesystem or shell access from the script itself (the agents do that work). A
`Large workflow` warning appears past 25 scheduled agents or 1.5M projected tokens.

**Cost control:** set a size guideline in `/config` (`small` is fewer than 5 agents,
`medium` fewer than 15, `large` fewer than 50; default is `medium`). Run on a narrow
slice first to gauge spend. Every agent uses your session's model unless the script
routes a stage elsewhere, so check `/model` before a large run.

**A resume gotcha:** replay follows the order agents *started*. Cached results stop
at the first agent that did not finish, and everything started after it runs again --
even if it completed. A workflow that fans work across many small agents therefore
preserves far more progress than one built around a few long ones.

## Quick Selection Guide

| Situation | Reach for |
|-----------|-----------|
| "Read these 40 files and tell me one thing" | Subagent (`Explore`) |
| "Chase this tangent, you already know the context" | Fork (`/subtask`) |
| "Review this PR from security, perf and test angles, and have them argue" | Agent Team |
| "Do the same check on every file in the repo" | Workflow |
| "Migrate 500 files without them conflicting" | Workflow with worktree isolation |
| "Build four independent pages" | Agent Team |
| "Sequential feature where each step depends on the last" | Single session |

## Further Reading

- See `docs/agent-teams-guide.md` for team patterns and their limitations
- See `docs/context-engineering.md` for why isolation matters
- See `examples/agents/` for subagent definitions
