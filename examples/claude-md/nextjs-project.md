# Acme Corp Website

Marketing website and SaaS landing page built with Next.js App Router.

## Commands

- `pnpm dev` -- Start development server (localhost:3000)
- `pnpm build` -- Production build
- `pnpm lint` -- ESLint check
- `pnpm test` -- Run Vitest suite

## Tech Stack

- Next.js 15 (App Router)
- React 19
- TypeScript (strict)
- Tailwind CSS v4
- GSAP + Lenis (animation)

## Architecture

App Router with route groups for layout segmentation. Server components by default -- add `"use client"` only when hooks, event handlers, or browser APIs are needed.

### Route Structure

- `/` -- Home (hero, features, testimonials, CTA)
- `/pricing` -- Pricing tiers
- `/blog` -- Blog listing (MDX)
- `/blog/[slug]` -- Individual post
- `/contact` -- Contact form
- `/dashboard` -- Authenticated area (separate layout)

### Component Pattern

```
ComponentName/
  ComponentName.tsx   (default export)
  ComponentName.css   (scoped styles, optional)
```

## Code Conventions

- Default exports for page and layout components
- Named exports for utility functions and hooks
- `@/*` path alias for all imports
- Import SVGs as components: `import Logo from "@/components/svg/Logo.svg"`
- Never inline SVGs in JSX
- Interfaces over types for object shapes
- Server wrapper + client child pattern for interactive sections

## Responsive Design

Test all pages at: 375, 768, 1024, 1280, 1440, 1920px.
Mobile-first -- write base styles for 375px, use Tailwind breakpoints (`md:`, `lg:`, `xl:`, `2xl:`) to scale up.

## Animation Rules

- GSAP for scroll-triggered reveals and timeline sequences
- Lenis for smooth scroll (integrated in client layout)
- Framer Motion ONLY for mount/unmount and layout animations
- All animations must respect `prefers-reduced-motion`

## Compaction

When compacting, always preserve:
- All modified files and their purpose
- Current task or project phase
- Test/build commands and last results
- Design review feedback and scores
- Architectural decisions made this session
