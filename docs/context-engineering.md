# Context Engineering: Managing Context as a Finite Resource

Context engineering is the discipline of curating the information an AI agent receives to maximise the quality of its output. For Claude Code, this means deliberately managing what loads into each session, what stays on demand, and how to handle long-running tasks without context degradation.

## Core Philosophy

> **Context is a finite resource with diminishing returns.** The goal is to find the smallest possible set of high-signal tokens that maximise the likelihood of the desired outcome.

Every token matters. A bloated context does not just waste money -- it actively degrades performance. As context fills, Claude loses focus on earlier instructions, makes more mistakes, and becomes more likely to ignore rules. The relationship between context size and output quality is not linear: there is a point where adding more context makes things worse, not better.

## The 7 Practical Rules

### 1. CLAUDE.md is always-on context

Only put things here that must apply to every single interaction. Everything else goes in skills (on-demand) or sub-agents (isolated context). A 200-line CLAUDE.md costs 200 lines of context even when Claude is doing a simple git operation.

### 2. Skills are on-demand context

Skill descriptions load every session (~1 line each). Full content loads only when invoked. Use skills for reference material, domain knowledge, and workflows. This is the most efficient way to give Claude access to detailed knowledge without paying the always-on cost.

### 3. Sub-agents are isolated context

When you need to read many files, run tests, or do research, use a sub-agent. The exploration happens in a separate context window and only a summary returns to your main conversation. This keeps your main context clean and focused.

### 4. Agent Teams are parallel isolated contexts

Each teammate has its own context window. Use Agent Teams when multiple investigation or implementation streams can run independently. The lead coordinates with a high-level plan while teammates do deep work in their own context.

### 5. Compaction preserves the essentials

When auto-compaction triggers (~95% context capacity), Claude summarises history and keeps the most important context. Tell Claude what to preserve by adding compaction instructions to your CLAUDE.md. Without guidance, Claude might discard information you need.

### 6. Clear between unrelated tasks

Do not let context accumulate across unrelated work. A clean session with a good prompt beats a long session with accumulated corrections and tangential context. Use `/clear` between tasks.

### 7. Course-correct early

If Claude is going in the wrong direction, stop it immediately. After 2 failed correction attempts, clear the session and start fresh with a better prompt. The cost of a clean restart is always lower than the cost of a polluted context where Claude has accumulated incorrect assumptions.

## Long-Horizon Task Strategies

For tasks spanning many turns -- large features, multi-step workflows, or extended project work:

### Structured note-taking

Claude can maintain notes outside the context window. Use STATE.md files, plan documents, or other structured files as external memory. Claude reads them when needed rather than keeping everything in the conversation.

### Compaction management

Auto-compaction triggers at approximately 95% context capacity. You can configure earlier compaction if needed. The key is ensuring your compaction instructions tell Claude what to preserve -- file lists, task progress, key decisions, and test results.

### Sub-agent architectures

The main agent coordinates with a high-level plan while sub-agents do deep technical work and return condensed summaries (typically 1,000--2,000 tokens). This pattern lets you tackle large codebases without overwhelming a single context window.

```
Main Agent (high-level plan, coordination)
  |-- Sub-agent A: Reads 50 files, returns 500-token summary
  |-- Sub-agent B: Runs test suite, returns pass/fail + failures
  +-- Sub-agent C: Researches library options, returns recommendation
```

## Tool Design Principles

When building custom tools, skills, and agents, follow these principles from Anthropic's guidance:

1. **Self-contained** -- Each tool should do one thing well with clear inputs and outputs. If a human cannot decide which tool to use for a given task, neither can Claude.

2. **Minimal overlap** -- Avoid tools with similar descriptions or overlapping functionality. Ambiguity in tool selection leads to inconsistent behaviour.

3. **Give room to think** -- Let Claude reason before committing to a tool call. Prompts that force immediate action lead to worse decisions.

4. **Poka-yoke (error-proof)** -- Design tool arguments to make mistakes harder. Use enums instead of free-text where possible. Validate inputs early.

5. **Invest in documentation** -- Put as much effort into tool and skill documentation as into the code itself. Claude's ability to use a tool correctly depends entirely on how well it understands what the tool does.

## Practical Tips

**Measure your context usage:** If Claude starts forgetting instructions or making mistakes it did not make earlier in the session, you have likely hit context saturation. Clear and restart.

**Front-load critical instructions:** The most important rules should be near the top of CLAUDE.md. Context attention is not uniform -- earlier content gets slightly more weight.

**Prefer fewer, richer tools over many thin ones:** Five well-documented tools outperform twenty poorly documented ones. Each additional tool description costs context tokens.

**Use `@imports` strategically:** The `@path/to/file` syntax in CLAUDE.md lets you reference files without embedding them. Claude reads the referenced file when it determines it is relevant.

**Audit your global rules:** Global rules load every session across every project. If a rule only applies to one project type, it should be a project rule instead. Minimise what loads globally.

## The Context Budget Mental Model

Think of your context as a budget:

```
Total context budget: 100%
  - CLAUDE.md (global + project): ~5-15%
  - Rules (global + project): ~3-8%
  - Skill descriptions: ~1-3%
  - Conversation history: ~50-70%
  - Tool results + file reads: ~15-30%
```

The conversation history grows over time and eventually triggers compaction. Your goal is to keep the fixed costs (CLAUDE.md, rules, skill descriptions) as small as possible so more budget is available for the actual work.

## Further Reading

- See `docs/memory-hierarchy.md` for the 8-layer memory system
- See `docs/skills-strategy.md` for skills as on-demand context
- See `docs/agent-teams-guide.md` for parallel isolated contexts
