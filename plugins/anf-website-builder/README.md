# anf-website-builder

A Claude Code plugin that builds professional websites using real designer components, real photography, and autoresearch-validated design patterns. The result looks designer-made because the components ARE designer-made.

## The Problem

Every AI-generated website looks the same: Inter font, indigo gradient, three-column grid, rounded cards, "Lorem ipsum" placeholder text. Users spot "AI-made" in seconds.

## The Solution: ANIF Framework

Instead of hand-writing CSS, you assemble real components from open-source design libraries, add real photography, and populate with researched content:

1. **A**ssemble — Install pre-built components from shadcn/ui, Magic UI, and Aceternity UI
2. **N**ormalize — Unify all components into one cohesive design (fonts, colors, spacing)
3. **I**llustrate — Download real photos from Unsplash and SVG illustrations from free libraries. Per-page, not per-site.
4. **F**ill — Research the actual product/industry and populate with specific, realistic content

## What Makes This Different

This skill was developed through **12 iterations of automated scoring** (mechanical checks + Lighthouse audits + AI design critic). Each iteration tested a different approach and kept what scored higher.

Key findings baked into the skill:
- **Real Unsplash photos as section backgrounds** score significantly higher than flat SVG illustrations or CSS-only decoration
- **Glassmorphism + gradient blobs** add atmospheric depth that flat designs lack
- **Compact bento layouts** score better than long alternating left/right sections
- **BlurFade with `inView`** and **NumberTicker** break in screenshots — the skill avoids them
- **Warm brand colors** (amber, emerald, coral) score better than cool monotones
- **Specific numbers** ("14,283 subscribers", "47ms response") beat generic claims ("fast", "thousands of users")

## Install

```bash
claude plugin marketplace add ErikTMA/claude-plugins
claude plugin install anf-website-builder@etma-plugins
```

## Usage

The skill triggers automatically when you ask Claude to build a website, landing page, or marketing page. You can also invoke it explicitly:

```
Build me a landing page for a SaaS analytics product called Metricly
```

```
Create a website for my hosting company. Here's the current site: https://example.com
```

Claude will:
1. Ask clarifying questions (product, sections, design preference)
2. Scaffold a Next.js project with component libraries
3. Download relevant photos from Unsplash
4. Build the full page with real components
5. Screenshot the result with Playwright and fix issues

## Component Libraries

All free, open-source, MIT licensed:

| Library | Install | Best For |
|---------|---------|----------|
| [shadcn/ui](https://ui.shadcn.com) | `npx shadcn@latest add` | Cards, buttons, accordion, nav, pricing |
| [Magic UI](https://magicui.design) | `npx shadcn@latest add "https://magicui.design/r/..."` | Bento grid, marquee, particles, shimmer buttons |
| [Aceternity UI](https://ui.aceternity.com) | Copy from website | Spotlight, 3D cards, background effects |

## Image Sources (30+)

The skill includes a comprehensive reference doc with free, commercial-use sources:

| Category | Top Sources |
|----------|------------|
| **Photos** | Unsplash, Pexels, Reshot (free download, no attribution) |
| **SVG Illustrations** | unDraw, DrawKit, ManyPixels, Blush Design |
| **3D Illustrations** | Shapefest, Khagwal 3D |
| **Animated Icons** | LottieFiles, Lordicon |
| **SVG Generators** | fffuel (50+ tools), getwaves.io, Haikei, blobmaker.app |
| **Gradients** | WebGradients, Gradient.page |
| **Textures** | AmbientCG, Poly Haven (CC0) |
| **Device Mockups** | Device Shots, Shotframe |
| **Video Backgrounds** | Coverr, Mixkit |

## Anti-AI-Tell Patterns

The skill actively avoids common AI design tells:

- No Tailwind indigo/purple as primary color
- No Inter as the only font — always a heading + body pair
- No identical three-column grids for every section
- No round numbers ("1,000+") — uses specific ones ("1,247")
- No generic headline words ("Powerful", "Seamless", "Revolutionary")
- No `NumberTicker` (shows 0 in screenshots)
- No `BlurFade inView` (invisible in static renders)
- No `bg-white/5` glass cards on dark backgrounds (too low contrast)

## Tech Stack

- Next.js 14+ (App Router)
- Tailwind CSS v4+
- Framer Motion
- TypeScript
- shadcn/ui + Magic UI component registry

## Scoring Results (from autoresearch)

Best iteration scored **80.4/100** using:
- Mechanical checks (build, components, fonts, content): 39/45
- Lighthouse (performance, accessibility, SEO): 8.4/10
- AI design critic (first impression, hierarchy, coherence, richness, content): 33/45

## Works Well With

- **[superpowers:brainstorming](https://github.com/anthropics/claude-code-superpowers)** — Run the brainstorming skill first to explore the user's intent, requirements, and design preferences before building. The brainstorming output feeds directly into the ANF skill's "Understand the Project" step.

## Credits

Inspired by the ANF Framework concept from [Ed Hill](https://www.youtube.com/@edhill). Extended with the Illustrate step, autoresearch scoring loop, and 30+ free image sources through iterative testing.

## License

MIT
