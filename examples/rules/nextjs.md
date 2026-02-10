---
paths:
  - "**/*.tsx"
  - "**/*.ts"
  - "**/next.config.*"
  - "**/app/**"
---

# Next.js Rules

- Use App Router patterns (not Pages Router)
- Server Components by default; add "use client" only when hooks, event handlers, or browser APIs are needed
- Use `next/image` for all images with explicit width/height or fill
- Use `next/link` for all internal navigation
- Metadata: export `generateMetadata` function for dynamic, or `metadata` object for static
- Route handlers in `app/api/` with proper HTTP method exports
- Loading states via `loading.tsx`, error boundaries via `error.tsx`
- Server Actions for form submissions and mutations
- Use `@/*` path alias (configured in tsconfig.json)
