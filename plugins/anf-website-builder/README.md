# anf-website-builder

A Claude Code plugin that builds professional websites using real designer components instead of generating generic AI-looking output.

## The Problem

Every AI-generated website looks the same: Inter font, purple gradient, three-column grid, rounded cards on white. Users can spot "AI-made" instantly.

## The Solution: ANF Framework

Instead of describing what you want (which produces generic output), you give Claude actual components built by real designers:

1. **Assemble** — Pick pre-built components from open-source libraries (shadcn/ui, Magic UI, Aceternity UI, etc.) and combine them into a page
2. **Normalize** — Unify all components into one cohesive design with consistent fonts, colors, and spacing
3. **Fill** — Research the actual topic and populate every section with realistic content

The result looks designer-made because the components ARE designer-made.

## Install

```bash
claude plugin marketplace add ErikTMA/claude-plugins
claude plugin install anf-website-builder@etma-plugins
```

## Usage

```bash
# Interactive — Claude asks what you need
/anf-website-builder

# With description
/anf-website-builder Landing page for a SaaS analytics product called Metrix
```

## Component Libraries Used

All free, open-source, MIT licensed, commercial use OK:

| Library | Components | Best For |
|---------|-----------|----------|
| [shadcn/ui](https://ui.shadcn.com) | 50+ foundation | Nav, forms, pricing, FAQ, footer |
| [Magic UI](https://magicui.design) | 50+ animated | Hero sections, bento grids, marquees |
| [Aceternity UI](https://ui.aceternity.com) | 36 free animated | Parallax, 3D cards, spotlights, background effects |
| [Origin UI](https://originui.com) | Clean minimal | SaaS dashboards, professional look |
| [Cult UI](https://cult-ui.com) | Animated elements | Interactive sections |

## What It Avoids

- Tailwind's default indigo-500 (the #1 AI tell)
- Inter as the only font
- Purple gradients everywhere
- Generic three-column grids
- Stock placeholder text
- Identical card sizes with identical padding

## Tech Stack

- Next.js 14+ (App Router)
- Tailwind CSS v4+
- Framer Motion
- TypeScript

## Credits

Inspired by the ANF Framework from [Ed Hill | AI Automation](https://www.youtube.com/@edhill).

## License

MIT
