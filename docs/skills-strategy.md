# Skills Strategy: When to Use Skills vs CLAUDE.md

Skills are Claude Code's on-demand knowledge system. Unlike CLAUDE.md (which loads every session), skills load their **description** at session start so Claude knows they exist, and their **full content** only when invoked. This makes them ideal for detailed reference material that should not consume context every session.

## How Skills Work

A skill is a Markdown file at `.claude/skills/<name>/SKILL.md` with YAML frontmatter and a body containing domain knowledge, workflows, or reference material.

```markdown
---
name: my-skill
description: One-line description of what this skill provides.
---

# Full Skill Content

Detailed knowledge, workflows, code examples, reference tables...
```

**At session start:** Claude reads the `description` field from every skill in the project. This costs roughly one line of tokens per skill.

**On invocation:** When Claude determines it needs a skill (based on the description matching the current task), it reads the full SKILL.md content. This is when the full token cost is incurred.

## Context Cost Comparison

Understanding the token cost of each layer is essential for efficient configuration:

| Layer | Token Cost | When Charged |
|-------|-----------|--------------|
| CLAUDE.md line | Every session | Always -- even when irrelevant |
| Skill description | Every session | ~1 line per skill |
| Skill full content | On invocation only | Only when Claude determines it is needed |
| Supporting file | On explicit read only | Only when Claude reads the file |

**The implication:** A 200-line section in CLAUDE.md costs 200 lines every session. That same content as a skill costs ~1 line per session plus 200 lines only when invoked. If Claude invokes that skill in 30% of sessions, you have saved 140 lines of context in 70% of sessions.

## The Decision Criteria

Use this rule of thumb:

> **If a section is longer than 50 lines and only relevant some of the time, it belongs in a skill.**

More specifically:

| Content Type | Where It Belongs | Why |
|-------------|------------------|-----|
| Build commands | CLAUDE.md | Needed every session |
| "Don't assume -- ask" | CLAUDE.md | Applies to every interaction |
| Route structure | CLAUDE.md | Frequently referenced |
| Design system tokens | Skill | 200+ lines, only needed during styling |
| Animation guide | Skill | 100+ lines, only needed during animation work |
| API conventions | Skill | 50+ lines, only needed during API work |
| Deployment workflow | Skill | Multi-step process, infrequent |

## Skill Composition Pattern

The most powerful pattern is **orchestrator skills** that invoke other skills and delegate to sub-agents:

```
generate-article (orchestrator skill)
  |-- Invokes: article-writer skill (multi-stage pipeline)
  |   +-- Delegates to sub-agents via Task tool
  |-- Invokes: svg-generator skill
  +-- Invokes: seo-validator skill
```

This pattern keeps each skill focused while the orchestrator handles sequencing and data flow. Each sub-skill can be tested and refined independently.

## Skill + Sub-agent Integration

Skills and sub-agents complement each other in three key patterns:

| Pattern | How It Works | When to Use |
|---------|-------------|-------------|
| Skill with `context: fork` | Skill runs in an isolated sub-agent context | Tasks that produce large output you do not need in the main context |
| Sub-agent with `skills:` field | Sub-agent preloads skill content at startup | Specialised workers that need domain knowledge |
| Skill invoking Task tool | Skill delegates specific steps to named sub-agents | Multi-step pipelines where each step has a specialist |

**Highest-leverage improvement:** When spawning sub-agents, always review available skills and preload relevant ones via the `skills:` field. A sub-agent with the right skills preloaded performs dramatically better than one without.

## Sizing Guidelines

| Size | Lines | Appropriate Use |
|------|-------|----------------|
| Micro | <50 | Single convention or pattern (e.g., `api-conventions`) |
| Standard | 50--300 | Workflow or domain reference (e.g., `animation-guide`) |
| Large | 300--500 | Complex orchestrator or comprehensive guide (e.g., `article-writer`) |
| **Too big** | >500 | Split into skill + supporting files. Keep SKILL.md as an overview and move detail to reference files in the same directory. |

When a skill exceeds 500 lines, Claude's ability to follow its instructions degrades -- the same problem as an oversized CLAUDE.md. Split the content:

```
.claude/skills/design-system/
  SKILL.md           (overview, decision logic, key rules -- ~150 lines)
  colour-tokens.md   (full token reference -- loaded on demand)
  typography.md      (type scale and usage -- loaded on demand)
  components.md      (component patterns -- loaded on demand)
```

The SKILL.md references the supporting files, and Claude reads them as needed.

## Where to Put Skills

```
Global skills (available to all projects):
  ~/.claude/skills/<name>/SKILL.md

Project skills (available to this project only):
  .claude/skills/<name>/SKILL.md
```

**Important:** Claude Code auto-discovers skills from `.claude/skills/`. The `.claude-code/` directory is **not** auto-discovered. If you have skills in `.claude-code/skills/`, migrate them to `.claude/skills/`.

**Global vs project?** If the skill applies to multiple projects (e.g., a Next.js conventions guide), make it global. If it is specific to one codebase (e.g., a project's design system), make it a project skill.

## Practical Tips

1. **Write descriptions that match task intent.** Claude selects skills based on description relevance. "Design system tokens and typography scale for Tailwind projects" is better than "design system."

2. **Keep the description under one sentence.** Longer descriptions waste tokens every session.

3. **Include examples in skills.** Skills are educational content -- code examples, decision trees, and step-by-step workflows are more useful than bare reference tables.

4. **Test skill invocation.** Ask Claude to do a task that should trigger the skill. If it does not invoke, the description may not match the task intent well enough.

5. **Audit periodically.** Remove skills that are never invoked. Merge skills that are always invoked together. Promote frequently-invoked skills to CLAUDE.md if they are short enough.

## Further Reading

- See `examples/skills/` for complete skill examples across different domains
- See `docs/memory-hierarchy.md` for the full 8-layer memory system
- See `docs/context-engineering.md` for broader context management principles
