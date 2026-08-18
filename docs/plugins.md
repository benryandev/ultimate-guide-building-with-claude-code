# Plugins: The Skills You Don't Have to Maintain

A plugin bundles skills, agents, hooks, MCP servers and LSP configs into one
installable, versioned unit. Where a skill is something you wrote for yourself, a
plugin is something you install, or ship to a team.

This document did not exist in the February version of this repo, because the
distribution layer it describes did not matter yet. It does now.

## Standalone vs Plugin

| Approach | Skill invocation | Best for |
|----------|-----------------|----------|
| **Standalone** (`.claude/`) | `/hello` | Personal workflows, project-specific customisations, quick experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, community distribution, versioned releases, reuse across projects |

Start standalone in `.claude/` for fast iteration. Convert to a plugin when you want
to share it or version it.

## Plugin Structure

Only `plugin.json` goes inside `.claude-plugin/`. Everything else sits at the plugin
root -- this is the single most common mistake when authoring one.

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json      # manifest: name, description, version, author
├── skills/
│   └── review/SKILL.md  # becomes /my-plugin:review
├── agents/              # custom subagent definitions
├── hooks/hooks.json     # event handlers
├── workflows/           # dynamic workflow scripts
├── .mcp.json            # MCP server configs
├── .lsp.json            # LSP server configs
├── monitors/            # background monitors
├── bin/                 # executables added to the Bash PATH
└── settings.json        # default settings when enabled
```

The manifest is minimal:

```json
{
  "name": "my-plugin",
  "description": "What this plugin does, shown in the plugin manager",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

`name` is also the skill namespace. A skill folder called `review` inside a plugin
called `my-plugin` is invoked as `/my-plugin:review`. Namespacing is mandatory and
prevents collisions between plugins that ship same-named skills.

## Marketplaces

Anthropic maintains two public marketplaces:

- **`claude-plugins-official`** -- curated by Anthropic, registered automatically on first interactive launch.
- **`claude-community`** -- third-party submissions after review. Add it with `/plugin marketplace add anthropics/claude-plugins-community`.

Plugins are enabled per-user in `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "playwright@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true
  }
}
```

For team distribution, host a marketplace in a private repository.

## Fast Path: Develop In Place

`claude plugin init my-tool` scaffolds a plugin into `~/.claude/skills/my-tool/`
with a manifest and starter `SKILL.md`. It auto-loads on the next session as
`my-tool@skills-dir` with no marketplace or install step. This is the quickest way
to go from "a skill I wrote" to "a thing with a version number".

For iterating on a plugin elsewhere on disk, launch with `--plugin-dir ./my-plugin`
and run `/reload-plugins` after changes.

## Build or Install?

The honest split from my own setup: **31 installed plugins alongside 24 hand-built
pipeline skills.**

Everything generic is an installed plugin I don't maintain -- Playwright, frontend
design, LSP servers, security scanning, CI templates. Everything specific to how I
write and validate articles is a skill I wrote.

That is the line:

- **If it encodes something true about a *tool*, someone has probably already shipped it.** Install it.
- **If it encodes something true about your *business*, build it.** Nobody else can.

The failure mode is building a mediocre in-house version of a plugin that already
exists, then maintaining it forever. The opposite failure mode is installing 31
plugins and never auditing them -- each one's skill descriptions cost context every
session, so periodically disable what you don't use.

## Custom Commands Are Now Skills

Worth knowing if you have older configuration: **custom commands have been merged
into skills.** A file at `.claude/commands/deploy.md` and a skill at
`.claude/skills/deploy/SKILL.md` both create `/deploy` and behave identically.

Existing `commands/` files keep working, so there is no migration to do. Use the
`skills/` layout for anything new -- it supports a directory of supporting files and
frontmatter that controls whether you or Claude invokes the skill.

## Further Reading

- See `docs/skills-strategy.md` for skill authoring and sizing
- See `docs/hooks.md` for the hooks a plugin can bundle
- See `examples/skills/` for skills ready to be packaged
