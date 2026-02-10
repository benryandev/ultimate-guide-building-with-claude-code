<!-- Template -- based on established patterns but not yet validated against a production monorepo. Adapt to your specific workspace structure. -->

# Acme Platform Monorepo

Monorepo with shared packages for the Acme Platform -- web app, API server, and shared libraries.

## Commands

- `pnpm dev --filter @acme/web` -- Start web app dev server
- `pnpm dev --filter @acme/api` -- Start API server
- `pnpm build --filter @acme/web` -- Build web app
- `pnpm build` -- Build all packages (respects dependency order)
- `pnpm lint` -- Lint all packages
- `pnpm test` -- Run tests across all packages
- `pnpm test --filter @acme/shared` -- Test a specific package

## Tech Stack

- pnpm workspaces (monorepo management)
- TypeScript (strict, project references)
- Next.js 15 (web app)
- Express (API server)
- Vitest (testing)

## Architecture

### Workspace Structure

```
packages/
  web/           -- Next.js frontend (@acme/web)
  api/           -- Express API server (@acme/api)
  shared/        -- Shared types, utils, constants (@acme/shared)
  ui/            -- Shared UI component library (@acme/ui)
  config/        -- Shared ESLint, TypeScript, Tailwind configs (@acme/config)
```

### Child Directory CLAUDE.md

Each package can have its own CLAUDE.md loaded on demand when Claude reads files in that directory. Use this for package-specific conventions:

```
packages/web/CLAUDE.md      -- Next.js-specific rules, route structure
packages/api/CLAUDE.md      -- API conventions, endpoint patterns
packages/shared/CLAUDE.md   -- Export rules, versioning policy
```

These files are NOT loaded every session -- only when Claude works in that package.

## Code Conventions

- Import shared code via workspace alias: `import { User } from "@acme/shared"`
- Never import directly between `web` and `api` -- use `shared` as the bridge
- Default exports for React components, named exports for everything else
- Each package owns its own tests in a `__tests__/` directory
- Types shared across packages live in `@acme/shared/types/`

## Package Boundaries

- `@acme/shared` has ZERO dependencies on other workspace packages
- `@acme/ui` depends only on `@acme/shared`
- `@acme/web` and `@acme/api` can depend on `@acme/shared` and `@acme/ui`
- Circular dependencies between packages are forbidden

## Compaction

When compacting, always preserve:
- Which package(s) are being modified
- Current task or project phase
- Test/build commands and last results
- Cross-package changes and their impact
- Architectural decisions made this session
