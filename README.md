# The Ultimate Guide to Building with Claude Code -- Companion Repo

[The Ultimate Guide to Building with Claude Code](https://benryan.com.au/blog/ultimate-guide-building-with-claude-code)

## What This Is

This repo is the companion to [The Ultimate Guide to Building with Claude Code](https://benryan.com.au/blog/ultimate-guide-building-with-claude-code). It contains real-world configuration files and deep-dive documentation drawn from production projects with hands-on experience across 17 phases and 74 plans of a Next.js site build, a content generation pipeline, and the meta-configuration of Claude Code itself.

Everything here is designed to be copied, adapted, and used in your own projects.

## Quick Start

1. **Browse the examples** -- Find configs relevant to your project type in `examples/`
2. **Read the deep dives** -- Understand the "why" behind each configuration in `docs/`
3. **Copy to your `.claude/`** -- Adapt the examples and drop them into your own project

## Structure

| Directory | Contents |
|-----------|----------|
| `docs/` | Deep-dive guides on memory hierarchy, skills, agent teams, design loops, and context engineering |
| `examples/claude-md/` | Example `CLAUDE.md` files for different project types (Next.js, content pipeline, monorepo) |
| `examples/global-config/` | Example global `~/.claude/CLAUDE.md` and `settings.json` |
| `examples/skills/` | Example skills: Next.js conventions, visual design review, animation guide, Tailwind design system |
| `examples/agents/` | Example sub-agents: design reviewer, responsive tester, accessibility auditor |
| `examples/rules/` | Example path-scoped rules: Next.js, Tailwind, Git, animations |
| `examples/mcp-configs/` | MCP server configurations: Playwright Plus, full-stack (Playwright + Supabase) |
| `.claude/` | Meta-demo -- this repo itself uses Claude Code with its own CLAUDE.md and skills |

## Deep Dives

| Guide | Topic |
|-------|-------|
| [Memory Hierarchy](docs/memory-hierarchy.md) | The 8-layer memory system, cost implications, and the 7 golden rules of CLAUDE.md |
| [Skills Strategy](docs/skills-strategy.md) | When to use skills vs CLAUDE.md, sizing guidelines, and the composition pattern |
| [Agent Teams Guide](docs/agent-teams-guide.md) | Team patterns, model selection strategy, and sub-agent best practices |
| [Visual Design Loop](docs/visual-design-loop.md) | The screenshot-review-fix cycle, Playwright Plus setup, and cycle limits |
| [Context Engineering](docs/context-engineering.md) | Managing context as a finite resource, the 7 practical rules, and long-horizon strategies |

## Examples to Article Mapping

| Article Section | Example Files |
|----------------|---------------|
| CLAUDE.md Architecture | [examples/claude-md/](examples/claude-md/), [examples/global-config/global-claude.md](examples/global-config/global-claude.md) |
| Memory Hierarchy | [docs/memory-hierarchy.md](docs/memory-hierarchy.md), [examples/rules/](examples/rules/) |
| Skills Strategy | [examples/skills/](examples/skills/), [docs/skills-strategy.md](docs/skills-strategy.md) |
| Agent Teams | [examples/agents/](examples/agents/), [docs/agent-teams-guide.md](docs/agent-teams-guide.md) |
| Visual Design Loop | [examples/skills/visual-design-review/SKILL.md](examples/skills/visual-design-review/SKILL.md), [docs/visual-design-loop.md](docs/visual-design-loop.md) |
| MCP Configuration | [examples/mcp-configs/](examples/mcp-configs/) |
| Context Engineering | [docs/context-engineering.md](docs/context-engineering.md) |
| Global Configuration | [examples/global-config/settings.json](examples/global-config/settings.json) |

## License

MIT -- see [LICENSE](LICENSE).

## Author

**Ben Ryan** -- [benryan.com.au](https://benryan.com.au)
