# Ultimate Guide: Building with Claude Code - Companion Repo

Companion repository for "Claude Code Best Practices: The Ultimate 2026 Guide".

## Purpose
This repo contains example configurations, skills, agents, rules, hooks, and
documentation for Claude Code best practices. All examples are drawn from real
production projects.

## Structure
- `examples/` -- Copy-paste-ready configuration examples
- `docs/` -- Deep-dive documentation on key topics
- `.claude/` -- This directory demonstrates the practices documented here

## Conventions
- All Markdown files use standard GitHub-flavored Markdown
- Example files should be self-contained and ready to copy
- JSON examples must pass `jq empty`; shell examples must pass `bash -n`

## Accuracy Rules
- **Cite the version.** The README states the Claude Code version everything was
  verified against. Update it whenever facts are re-checked.
- **Verify before asserting.** Check claims against the official docs at
  code.claude.com and the anthropics/claude-code CHANGELOG. Do not restate a
  feature, flag, default, or price from memory.
- **Correct in the open.** When something here turns out to be wrong, record it in
  CHANGELOG.md rather than silently editing it. Readers who followed the old advice
  need to know it changed.
- **Distinguish "changed" from "was wrong".** These are different failures and the
  CHANGELOG separates them.
