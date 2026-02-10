---
paths:
  - "**/*.tsx"
  - "**/*.css"
  - "**/tailwind.config.*"
---

# Tailwind CSS Rules

- Mobile-first responsive design: write base styles for mobile, add breakpoint modifiers for larger screens
- Standard breakpoints: sm(640) md(768) lg(1024) xl(1280) 2xl(1536)
- Use design system tokens over arbitrary values when possible
- Use `clsx` or `cn` utility for conditional classes
- Component-scoped CSS files for complex animations or styles that don't map well to utility classes
- Never use `@apply` in component CSS -- use direct Tailwind classes or raw CSS properties
