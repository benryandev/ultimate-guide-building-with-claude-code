---
paths:
  - "**/*.tsx"
  - "**/*.css"
---

# Animation Rules

## Library Selection
- **GSAP**: Complex timelines, ScrollTrigger, text splitting (SplitText), SVG morphing, stagger animations. Primary animation library.
- **Lenis**: Smooth scroll only. Integrated at layout level, never instantiate per-component.
- **Framer Motion**: React layout animations, AnimatePresence for mount/unmount, shared layout transitions, spring physics. Use only when React state drives the animation.
- **Three.js / React Three Fiber**: 3D scenes only. Never use for 2D effects that GSAP can handle.

## Best Practices
- Always wrap GSAP in `useGSAP` hook (from `@gsap/react`) -- handles cleanup automatically
- Use `SplitText.create()` with `autoSplit: true` for responsive text animations
- All scroll-driven animations must use `ScrollTrigger` with proper `start`/`end` markers
- Respect `prefers-reduced-motion`: disable complex animations, keep essential transitions
- Kill Lenis scroll during modals/overlays: `lenis.stop()` / `lenis.start()`
- Never mix animation libraries on the same element -- one library owns each element's animation lifecycle
