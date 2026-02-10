# Content Generation Pipeline

Automated content pipeline using Claude Code skills to generate, validate, and publish articles.

## Commands

- `pnpm generate -- --topic "Topic Name"` -- Generate a new article
- `pnpm validate` -- Validate all articles against quality rules
- `pnpm publish -- --file content/drafts/article.md` -- Publish to CMS
- `pnpm lint` -- Lint Markdown and frontmatter

## Architecture

Skills-based orchestration pipeline. A top-level orchestrator skill delegates to specialist sub-skills for each stage (research, outline, draft, review, SEO, formatting).

### Pipeline Stages

1. **Research** -- Gather topic context and source material
2. **Outline** -- Structure article with headings and key points
3. **Draft** -- Write full article content
4. **Review** -- Quality check against style guide
5. **SEO** -- Optimize meta, headings, and keyword density
6. **Format** -- Apply frontmatter and Markdown conventions

### Directory Structure

```
content/
  drafts/       -- Work-in-progress articles
  published/    -- Final articles ready for CMS
  templates/    -- Article templates and style guide
```

## Constraints

- DO NOT modify files outside `content/` -- pipeline has no business touching source code
- DO NOT publish without passing validation (`pnpm validate` must exit 0)
- All articles must have complete frontmatter (title, date, author, tags, description)
- Target reading time: 5-15 minutes (1200-3600 words)
- One article per generation run -- no batch mode

## Code Conventions

- All content files use Markdown with YAML frontmatter
- Skill files follow `.claude/skills/<name>/SKILL.md` structure
- Use `@path/to/file` references in skills for supporting documents
- Log each pipeline stage to `content/logs/` for debugging

## Compaction

When compacting, always preserve:
- Current pipeline stage and article being processed
- Validation results from last run
- Any quality review feedback
- Files created or modified this session
