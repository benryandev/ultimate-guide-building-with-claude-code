# Understanding Claude Code's Memory Hierarchy

Claude Code loads memory in layers. Each layer has different scope, visibility, and context cost. Understanding this hierarchy is the single most impactful thing you can do to improve Claude's performance across your projects.

## The 8 Layers

Claude Code's memory system has eight distinct layers, ordered from broadest scope to narrowest:

| Layer | Location | When Loaded | Audience | Use For |
|-------|----------|-------------|----------|---------|
| **Global** | `~/.claude/CLAUDE.md` | Every session, every project | You only | Personal identity, cross-project preferences, model preferences |
| **Global Rules** | `~/.claude/rules/*.md` | Every session, every project | You only | Modular cross-project rules (e.g., `nextjs.md`, `git.md`) |
| **Project** | `./CLAUDE.md` or `.claude/CLAUDE.md` | Every session in this project | Team (git) | Project-specific stack, commands, architecture, conventions |
| **Project Rules** | `.claude/rules/*.md` | Every session in this project | Team (git) | File-type-specific rules scoped via frontmatter |
| **Project Local** | `./CLAUDE.local.md` | Every session in this project | You only (.gitignored) | Personal overrides, sandbox URLs, environment notes |
| **Child Directory** | `./packages/foo/CLAUDE.md` | On demand (when Claude reads files in that directory) | Team (git) | Package-specific rules in monorepos |
| **Auto Memory** | `~/.claude/projects/<id>/memory/` | First 200 lines per session | Auto (Claude writes) | Claude's own notes, debugging insights, pattern learnings |
| **Skills** | `.claude/skills/<name>/SKILL.md` | Description at session start; full content on invocation | Team (git) | On-demand domain knowledge, workflows, reference material |

## Cost Implications

The critical distinction is between **always-on** and **on-demand** context:

- **Always-on layers** (Global, Global Rules, Project, Project Rules, Project Local) load every session. Every line consumes tokens whether Claude needs it or not.
- **On-demand layers** (Child Directory, Skills) load only when triggered. A skill description costs roughly one line per session -- the full content loads only when invoked.
- **Auto Memory** is a hybrid: the first 200 lines load automatically, but Claude controls what goes there.

This means a 100-line CLAUDE.md costs 100 lines of context every single session. A 100-line skill costs approximately one line per session plus the full 100 lines only when invoked. For reference material that Claude needs occasionally, skills are dramatically more efficient.

## The 7 Golden Rules of CLAUDE.md

These rules apply to any CLAUDE.md file but are most critical for global and project-level files since they load every session.

### 1. Keep it under 500 lines

Bloated CLAUDE.md files cause Claude to lose focus on your instructions. If Claude keeps doing something you have a rule against, the file is probably too long. Shorter files mean each instruction gets more attention.

### 2. Only include what Claude cannot infer from code

Do not document standard language conventions, obvious project structure, or things Claude already knows. Do document build commands, unusual patterns, and project-specific decisions that would otherwise require guessing.

### 3. Use `@path/to/file` imports for shared docs

Do not paste your README into CLAUDE.md. Instead, use imports: `See @README.md for project overview`. This keeps CLAUDE.md focused and avoids duplication.

### 4. Move domain knowledge to skills

If a section is longer than 50 lines and only relevant some of the time, it belongs in a skill. Domain knowledge, reference tables, and multi-step workflows are ideal candidates.

### 5. Add compaction instructions

Tell Claude what to preserve during auto-compaction:

```
## Compaction
When compacting, always preserve:
- List of all modified files and their purpose
- Current task or project phase
- Test/build commands and their last results
- Design review feedback and scores
```

### 6. Keep it current

If a component is deleted, remove it from CLAUDE.md. If routes change, update them. Stale CLAUDE.md is worse than no CLAUDE.md -- it teaches Claude incorrect things. Treat it like code: review it when things go wrong.

### 7. Test with behaviour

Ask yourself: "Would removing this line cause Claude to make a mistake?" If not, cut it. Ask: "Does Claude keep asking me something answered here?" If yes, rephrase it more clearly.

## Decision Framework

Use this flowchart to decide where any new instruction belongs:

```
Does this apply to EVERY project?
├── Yes → Does it apply to specific file types?
│   ├── Yes → ~/.claude/rules/<filetype>.md (Global Rule)
│   └── No  → ~/.claude/CLAUDE.md (Global)
└── No  → Does it apply to a specific project?
    ├── Yes → Is it >50 lines and only sometimes needed?
    │   ├── Yes → .claude/skills/<name>/SKILL.md (Project Skill)
    │   └── No  → Does it apply to specific file types?
    │       ├── Yes → .claude/rules/<filetype>.md (Project Rule)
    │       └── No  → ./CLAUDE.md (Project)
    └── No  → Is it personal (not shared with team)?
        ├── Yes → ./CLAUDE.local.md (Project Local)
        └── No  → Reconsider -- it probably fits one of the above
```

**Key decision points:**

- **Global vs Project?** Would this instruction help in a different project? If yes, make it global.
- **CLAUDE.md vs Skill?** Is this always needed, or only sometimes? Always-needed goes in CLAUDE.md. Sometimes-needed goes in a skill.
- **CLAUDE.md vs Rule?** Is this tied to specific file types? File-type rules go in `.claude/rules/` with path-scoped frontmatter.
- **Shared vs Personal?** Team conventions go in committed files. Personal preferences go in `.local.md` (gitignored) or global config.

## Practical Example: Layered Configuration

Here is how a Next.js project might use multiple layers together:

```
~/.claude/CLAUDE.md              → "Prefer pnpm. Private repos by default."
~/.claude/rules/nextjs.md        → "Server Components by default. Use App Router."
~/.claude/rules/git.md           → "feat:, fix:, refactor: commit prefixes."
./CLAUDE.md                      → "This is Acme Corp's marketing site. pnpm dev to start."
.claude/rules/animations.md      → "GSAP for scroll, Framer Motion for layout transitions."
.claude/skills/design-system/    → Full colour tokens, typography scale, spacing system.
./CLAUDE.local.md                → "My staging URL: https://staging-abc.vercel.app"
```

Each layer adds specificity without bloating any single file. The design system skill might be 200 lines but only loads when Claude is working on styling. The CLAUDE.md stays focused at under 100 lines.

## Common Mistakes

1. **Putting everything in CLAUDE.md** -- This is the most common mistake. Move reference material to skills.
2. **Duplicating global rules in project files** -- Use global rules for cross-project conventions. Do not repeat them per-project.
3. **Ignoring compaction** -- Without compaction instructions, Claude loses critical context during long sessions.
4. **Stale instructions** -- Outdated CLAUDE.md actively harms Claude's output. Review it regularly.
5. **Skipping `.local.md`** -- Personal notes, sandbox URLs, and API keys should not be in committed files.

## Further Reading

- See `examples/global-config/` for a complete global configuration example
- See `examples/claude-md/` for project CLAUDE.md templates across different project types
- See `examples/rules/` for path-scoped rule examples
