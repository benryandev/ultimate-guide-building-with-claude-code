# Global Preferences -- Ben Ryan

## Identity
- Owner: Ben Ryan
- Website: benryan.com.au
- Business: WordPress maintenance & web development

## Core Rules
- **Don't assume.** If you're unsure about a design decision, implementation approach, or requirement -- ask before proceeding.
- All designs must be responsive. Test at: 375, 768, 1024, 1280, 1440, 1920px.
- Import SVGs as components (`import X from "@/components/svg/X.svg"`). Never inline SVGs.
- Prefer pnpm over npm.
- Private repos by default when creating GitHub repos (`gh repo create --private`).

## Model Preferences
- Agent Team lead: Opus 5
- Agent Team teammates: Sonnet 5 by default
- Escalate teammates to Opus 5 for: complex architecture, security-critical code, performance-sensitive implementations, intricate animation choreography, tasks requiring deep cross-codebase reasoning
- Escalate to Fable 5 for: long autonomous sessions, ambiguous root-cause investigation, work I'd otherwise split across several sittings
- Subagent for read-only exploration: Haiku 4.5 (fast, cheap)
- Subagent for code changes: Sonnet 5 (default) or Opus 5 (complex)
- Name teammate models in the spawn prompt -- `teammateDefaultModel` was removed in v2.1.234

## Session Management
- Use `/clear` between unrelated tasks
- Use subagents for investigation to keep main context clean
- Course-correct early -- if something is going wrong, stop and rethink rather than iterating on a broken approach
- After 2 failed correction attempts, `/clear` and start fresh with a better prompt

## Compaction
When compacting, always preserve:
- All modified files and their purpose
- Current GSD phase/task
- Test/build commands and last results
- Design review feedback and scores
- Architectural decisions made this session

## Orchestration

### Agent Teams
- **Enablement:** experimental and off by default. `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set in `~/.claude/settings.json`.
- **Context injection:** Teammates start with amnesia. Always inject project libraries, patterns, constraints, and relevant file paths into spawn prompts. Never assume teammates know the codebase.
- **File ownership:** Assign each teammate to non-overlapping file/directory paths. Two teammates writing to the same file causes conflicts and lost work.
- **Task sizing:** 5-6 tasks per teammate is the sweet spot. Start with 3-5 teammates -- three focused beats five scattered.
- **Shutdown protocol:** Ask the Lead to shut teammates down so they can save state. Team directories clean up automatically when the session ends. Display mode defaults to in-process, so there are usually no tmux panes involved.

### Subagents
- **Strategy defaults:** Use parallel subagents for independent tasks (searching, file analysis). Use sequential subagents for debugging (each step depends on prior findings).
- **Forks:** Use `/subtask` when the side task needs this conversation's context -- a fork reuses the prompt cache and costs less than a fresh subagent.
- **Background execution:** Use `run_in_background` for test suites, builds, and large codebase searches. Keep the main thread free for interactive work.

## Reference
Memory hierarchy, model pricing, effort levels, context engineering rules and parallelism trade-offs live in the `claude-code-reference` skill. Invoke it when auditing configuration rather than carrying the tables in always-on context.
