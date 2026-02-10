# The Iterative Visual Design Loop

The iterative design loop is a structured process for achieving high-quality, responsive designs with Claude Code. It uses Playwright to capture screenshots at multiple breakpoints, AI skills to review the designs, and targeted fixes based on review feedback. This guide covers the full cycle, tooling setup, and practical limits.

## The Cycle

```
+---------------+    +----------------+    +----------------+    +-----------+
|  Build / Fix  |--->|  Screenshot    |--->|  Review &      |--->|  Adjust   |
|  Component    |    |  (Playwright)  |    |  Analyse       |    |  Design   |
+---------------+    +----------------+    +----------------+    +-----+-----+
       ^                                                               |
       +---------------------------------------------------------------+
                           Repeat 3-5 cycles
```

Each cycle narrows the gap between current state and production quality. The first cycle catches major issues; subsequent cycles refine spacing, typography, and polish.

## Playwright Plus MCP Setup

Use **Playwright Plus MCP** instead of the standard Playwright MCP. It provides project-level session isolation, allowing parallel browser sessions without conflicts -- critical when using Agent Teams for design reviews.

**Configuration** (in your project `.mcp.json`):

```json
{
  "mcpServers": {
    "playwright-plus": {
      "command": "npx",
      "args": [
        "-y",
        "@ai-coding-labs/playwright-mcp-plus@latest",
        "--project-isolation",
        "--caps=vision"
      ]
    }
  }
}
```

- `--caps=vision` enables screenshot capture for visual review
- `--project-isolation` ensures each project gets its own browser session

**Why Plus over standard?** The standard Playwright MCP shares a single browser session. If two agents try to navigate simultaneously (common with Agent Teams), they interfere with each other. Playwright Plus MCP isolates sessions per project, making parallel capture reliable.

## Breakpoint Table

Capture screenshots at these widths for comprehensive responsive coverage:

| Breakpoint | Width x Height | Represents |
|------------|---------------|------------|
| Mobile | 375 x 812 | iPhone SE / small phones |
| Tablet | 768 x 1024 | iPad Mini / standard tablets |
| Small Desktop | 1024 x 768 | iPad Pro landscape / small laptops |
| Desktop | 1280 x 800 | Standard laptops |
| Large Desktop | 1440 x 900 | Large monitors |
| Ultrawide | 1920 x 1080 | Full HD monitors |

**For most reviews, 4 breakpoints are sufficient:** 375, 768, 1280, and 1920. Use all 6 for final quality gates before launch.

## The ScrollTrigger Screenshot Caveat

**Problem:** Full-page screenshots of pages with scroll-triggered animations (GSAP ScrollTrigger, Intersection Observer, etc.) do not render correctly. Scroll-triggered elements remain in their initial state -- often `opacity: 0` or `transform: translateY(50px)` -- because the scroll events have not fired.

**Solutions:**

### 1. Force-visible CSS injection (recommended for screenshot passes)

Inject CSS before capture that overrides hidden states:

```javascript
await page.addStyleTag({
  content: `
    [style*="opacity: 0"], .gsap-hidden, [data-scroll] {
      opacity: 1 !important;
      transform: none !important;
      clip-path: none !important;
    }
  `
});
```

### 2. Viewport-height increments

Instead of one full-page screenshot, capture multiple viewport-height screenshots at key scroll positions (0%, 25%, 50%, 75%, 100% of page height).

### 3. Programmatic scroll trigger

Scroll the page programmatically to trigger all animation instances before capturing:

```javascript
await page.evaluate(() => {
  window.scrollTo(0, document.body.scrollHeight);
});
await page.waitForTimeout(2000); // Wait for animations to complete
await page.evaluate(() => {
  window.scrollTo(0, 0);
});
```

**Recommendation:** Use force-visible CSS (solution 1) for screenshot review passes. Use manual testing or programmatic scroll for verifying actual animation behaviour.

## Review Tools and Scoring

After capturing screenshots, Claude analyses them using design review skills. The review evaluates four dimensions:

| Dimension | What It Measures | Target |
|-----------|-----------------|--------|
| **Design** | Visual quality, spacing, typography, colour usage | 9+/10 |
| **Usability** | Navigation clarity, CTA prominence, information hierarchy | 9+/10 |
| **Creativity** | Unique elements, animation quality, brand personality | 8+/10 |
| **Content** | Copy quality, readability, value proposition clarity | 8+/10 |

**Review process:**
1. Capture screenshots at target breakpoints
2. Run design analysis on each screenshot set
3. Score each dimension and identify specific issues
4. Categorise issues by severity: critical (layout broken), major (noticeable quality gap), minor (polish)
5. Prioritise fixes by severity, then by impact on scores

## Agent Teams for Parallel Design Review

This is where Agent Teams excel. The lead can coordinate parallel capture and review across multiple pages:

```
Lead (Opus, Delegate Mode):
  1. Assigns pages/sections to teammates
  2. Each teammate captures screenshots via Playwright Plus MCP
  3. Each teammate runs design analysis
  4. Lead collates all feedback
  5. Lead identifies cross-page consistency issues
  6. Lead assigns fix tasks by priority
  7. After fixes, repeat from step 2

Teammate A (Sonnet): Homepage + Services pages
Teammate B (Sonnet): About + Contact pages
Teammate C (Sonnet): Blog + Dashboard pages
```

**Advantages of parallel review:**
- Parallel screenshot capture (each teammate has an isolated Playwright session)
- Multiple perspectives on design issues
- The lead ensures design consistency across all pages
- Fix distribution based on teammate availability

## Cycle Limits

Diminishing returns are real. Know when to stop.

| Cycle | Focus | Expected Improvement |
|-------|-------|---------------------|
| 1 | Major layout issues, responsiveness breaks, obvious visual problems | +1.0--2.0 points |
| 2 | Spacing, typography, colour refinements | +0.3--0.5 points |
| 3 | Polish: micro-interactions, hover states, edge cases | +0.1--0.2 points |
| 4--5 | Only if scores are still below target | +0.05--0.1 points |
| >5 | Stop. Further iteration yields negligible improvement. | <0.05 points |

**Real-world metric:** On a production project, 3 rounds moved design scores from 8.1 to 8.2 to 8.3, with 28 total CSS fixes applied. The first round caught 18 issues; the third round caught only 4. Further iteration would have yielded diminishing returns.

## Practical Tips

1. **Start with mobile.** Mobile layouts expose spacing and hierarchy issues that are hidden on desktop. Fix mobile first, then verify desktop.

2. **Fix all critical issues before moving to the next cycle.** Addressing minor issues while critical layout problems remain wastes review cycles.

3. **Compare before/after screenshots.** Keep the previous cycle's screenshots for comparison. Regression detection is as important as improvement.

4. **Document your thresholds.** Define "good enough" before starting. Without a target, you will over-iterate on diminishing improvements.

5. **Use dark mode screenshots too.** If your project supports dark mode, capture both variants. Dark mode often reveals contrast issues invisible in light mode.

## Further Reading

- See `examples/agents/design-reviewer.md` for a complete design review sub-agent
- See `examples/agents/responsive-tester.md` for a responsive testing sub-agent
- See `examples/skills/visual-design-review/` for the full design review skill
- See `docs/agent-teams-guide.md` for team coordination patterns
