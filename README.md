# The Ultimate Guide to Building with Claude Code -- Companion Repo

Companion repo for [Claude Code Best Practices: The Ultimate 2026 Guide](https://benryan.com.au/blog/ultimate-guide-building-with-claude-code).

**Last verified against Claude Code v2.1.311 (October 2026).** See the October entry in [CHANGELOG.md](CHANGELOG.md) for what changed since August, including six claims that were wrong when written.

## What This Is

Real-world configuration files and deep-dive documentation drawn from production
work: **115 phases and nearly 500 plans** across two projects (77 phases and 418 plans on a Next.js site build, and a 38-phase content
generation pipeline with 26 orchestrated skills and 76 plans), and the meta-configuration of
Claude Code itself.

Everything here is designed to be copied, adapted, and used in your own projects.

## Quick Start

1. **Browse the examples** -- find configs relevant to your project type in `examples/`
2. **Read the deep dives** -- understand the "why" behind each configuration in `docs/`
3. **Copy to your `.claude/`** -- adapt the examples and drop them into your own project

If you only read one thing, make it [docs/memory-hierarchy.md](docs/memory-hierarchy.md).
If you only fix one thing, read [docs/hooks.md](docs/hooks.md) and convert your most
frequently-ignored CLAUDE.md rule into a hook.

## Structure

| Directory | Contents |
|-----------|----------|
| `docs/` | Deep-dive guides on memory, skills, plugins, hooks, teams, workflows, design loops, and context engineering |
| `examples/claude-md/` | Example `CLAUDE.md` files for different project types (Next.js, content pipeline, monorepo) |
| `examples/global-config/` | Example global `~/.claude/CLAUDE.md` and `settings.json` |
| `examples/skills/` | Example skills: Next.js conventions, visual design review, animation guide, Tailwind design system, Claude Code reference |
| `examples/agents/` | Example subagents: design reviewer, responsive tester, accessibility auditor |
| `examples/rules/` | Example path-scoped rules: Next.js, Tailwind, Git, animations |
| `examples/hooks/` | Runnable hook configs: destructive-command guard, auto-formatter, session bootstrap |
| `examples/mcp-configs/` | MCP server configurations: Playwright Plus, full-stack (Playwright + Supabase) |
| `.claude/` | Meta-demo -- this repo uses Claude Code with its own CLAUDE.md and skills |

## Deep Dives

| Guide | Topic |
|-------|-------|
| [Memory Hierarchy](docs/memory-hierarchy.md) | The 10-layer memory system, cost implications, the rules gotchas, and the 7 golden rules of CLAUDE.md |
| [Skills Strategy](docs/skills-strategy.md) | Skills vs CLAUDE.md, sizing guidelines, and the composition pattern |
| [Plugins](docs/plugins.md) | Packaging and distributing skills, marketplaces, and when to build vs install |
| [Hooks](docs/hooks.md) | Enforcement instead of suggestion: events, exit code 2, and worked examples |
| [Agent Teams Guide](docs/agent-teams-guide.md) | Enabling teams, display modes, model selection, patterns, and limitations |
| [Subagents & Workflows](docs/subagents-and-workflows.md) | Choosing a parallelism primitive: subagents, forks, teams, and dynamic workflows |
| [Visual Design Loop](docs/visual-design-loop.md) | The screenshot-review-fix cycle, Playwright setup, and cycle limits |
| [Context Engineering](docs/context-engineering.md) | Context as a finite resource, the 9 practical rules, effort levels, and long-horizon strategies |

## Examples to Article Mapping

| Article Section | Example Files |
|----------------|---------------|
| Memory Hierarchy | [docs/memory-hierarchy.md](docs/memory-hierarchy.md), [examples/rules/](examples/rules/) |
| CLAUDE.md Architecture | [examples/claude-md/](examples/claude-md/), [examples/global-config/global-claude.md](examples/global-config/global-claude.md) |
| Skills, Commands and Plugins | [examples/skills/](examples/skills/), [docs/skills-strategy.md](docs/skills-strategy.md), [docs/plugins.md](docs/plugins.md) |
| Hooks | [examples/hooks/](examples/hooks/), [docs/hooks.md](docs/hooks.md) |
| Agent Teams | [examples/agents/](examples/agents/), [docs/agent-teams-guide.md](docs/agent-teams-guide.md) |
| Subagents, Forks and Workflows | [docs/subagents-and-workflows.md](docs/subagents-and-workflows.md) |
| Visual Design Loop | [examples/skills/visual-design-review/SKILL.md](examples/skills/visual-design-review/SKILL.md), [docs/visual-design-loop.md](docs/visual-design-loop.md) |
| Context Engineering | [docs/context-engineering.md](docs/context-engineering.md), [examples/skills/claude-code-reference/SKILL.md](examples/skills/claude-code-reference/SKILL.md) |
| Global Configuration | [examples/global-config/settings.json](examples/global-config/settings.json) |
| MCP Configuration | [examples/mcp-configs/](examples/mcp-configs/) |

## A Note on Accuracy

Claude Code moves quickly, and configuration guidance rots faster than code does.
Every document here carries what it was verified against. If you are reading this
long after October 2026, check the current
[Claude Code docs](https://code.claude.com/docs) before trusting a specific flag,
default, or price.

The February version of this repo confidently documented a feature that never
existed, recommended a script that is now obsolete, and understated one loading
behaviour badly enough to mislead. Those are written up in the
[CHANGELOG](CHANGELOG.md) rather than quietly deleted.

## License

MIT -- see [LICENSE](LICENSE).

## Author

**Ben Ryan** -- [benryan.com.au](https://benryan.com.au)
