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
- Agent Team lead: always Opus
- Agent Team teammates: Sonnet by default
- Escalate teammates to Opus for: complex architecture, security-critical code, performance-sensitive implementations, intricate animation choreography, tasks requiring deep cross-codebase reasoning
- Subagent model for read-only exploration: Haiku (fast, cheap)
- Subagent model for code changes: Sonnet (default) or Opus (complex)

## Session Management
- Use `/clear` between unrelated tasks
- Use subagents for investigation to keep main context clean
- Course-correct early -- if something is going wrong, stop and rethink rather than iterating on a broken approach
- After 2 failed correction attempts, `/clear` and start fresh with a better prompt

## Compaction
When compacting, always preserve:
- All modified files and their purpose
- Current task or project phase
- Test/build commands and last results
- Design review feedback and scores
- Architectural decisions made this session

## Memory Hierarchy

Claude Code loads memory in layers. Understanding the cost of each layer prevents context waste.

| Layer | Location | Loaded | Cost |
|-------|----------|--------|------|
| Global | `~/.claude/CLAUDE.md` | Every session | Always in context |
| Global Rules | `~/.claude/rules/*.md` | Every session | Always in context (bug: no path filtering) |
| Project | `./CLAUDE.md` | Every project session | Always in context |
| Project Rules | `.claude/rules/*.md` | Every project session | Always in context |
| Project Local | `./CLAUDE.local.md` | Every project session | Always in context (gitignored) |
| Child Directory | `./packages/foo/CLAUDE.md` | On demand | Only when Claude reads files in that dir |
| Auto Memory | `~/.claude/projects/<id>/memory/` | First 200 lines | Partial, per session |
| Skills | `.claude/skills/<name>/SKILL.md` | Description at start; full on invoke | ~1 line per skill at start |

**Principle:** CLAUDE.md = always-on (expensive). Skills = on-demand (cheap). Put always-needed rules in CLAUDE.md. Put reference material in skills.

## Model Selection Strategy

| Role | Model | When |
|------|-------|------|
| Team Lead | Opus (always) | Coordination, synthesis, complex decomposition |
| Teammate (default) | Sonnet | Standard implementation tasks |
| Teammate (escalated) | Opus | Complex architecture, security-critical, performance-sensitive, intricate animation, deep cross-codebase reasoning |
| Subagent (read-only) | Haiku | File search, codebase exploration |
| Subagent (code changes) | Sonnet (default) or Opus (complex) | Implementation or refactoring |

## Context Engineering

Context is a finite resource. Every token matters.

- **CLAUDE.md** = always-on context. Only put things here that must apply to every interaction.
- **Skills** = on-demand context. Descriptions load every session (~1 line). Full content on invocation only.
- **Subagents** = isolated context. Exploration in a separate window; only a summary returns.
- **Agent Teams** = parallel isolated contexts. Each teammate has its own window.
- **Compaction** preserves essentials. Tell Claude what to keep (see Compaction section above).
- `/clear` between unrelated tasks. Clean session with good prompt beats long session with accumulated corrections.
- **Course-correct early.** After 2 failed corrections, `/clear` and start fresh.
