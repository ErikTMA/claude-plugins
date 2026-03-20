# Component Libraries

Free, open-source component libraries for the ANF Framework. All MIT licensed, commercial use OK.

## Primary Libraries

### shadcn/ui
- **URL:** https://ui.shadcn.com
- **License:** MIT
- **Components:** 50+ foundation components (buttons, cards, dialogs, forms, tables, etc.)
- **Stack:** React, Tailwind CSS, Radix UI primitives
- **Install:** `npx shadcn@latest init` then `npx shadcn@latest add <component>`
- **Best for:** Foundation layer — forms, navigation, layout structure
- **Note:** Copy-paste model, not npm dependency. Components become your code.

### Magic UI
- **URL:** https://magicui.design
- **License:** MIT
- **Components:** 50+ animated landing page components
- **Stack:** React, Next.js, Tailwind CSS, Framer Motion
- **Install:** `npx shadcn@latest add "https://magicui.design/r/<component>"`
- **Best for:** Hero sections, animated text, marquees, particle effects, bento grids
- **Highlights:** Globe, dock, orbiting circles, animated beam, shimmer button, number ticker

### Aceternity UI
- **URL:** https://ui.aceternity.com
- **License:** Free tier (36+ animated components), Pro tier (paid)
- **Components:** Hero parallax, 3D cards, spotlight, sparkles, background effects, meteor showers
- **Stack:** React, Next.js, Tailwind CSS, Framer Motion
- **Install:** Copy-paste from website
- **Best for:** Hero sections with "wow factor", background effects, interactive cards
- **Note:** Free components are sufficient for most sites. Only use free-tier components.

### Origin UI
- **URL:** https://originui.com
- **License:** MIT
- **Components:** Clean, minimal components
- **Stack:** React, Tailwind CSS
- **Best for:** Clean professional look, SaaS dashboards

### Cult UI
- **URL:** https://cult-ui.com
- **License:** MIT
- **Components:** Animated UI components
- **Stack:** React, Tailwind CSS, Framer Motion
- **Best for:** Interactive elements, animated sections

## Component Selection Guide

Match components to website sections:

| Section | Primary Source | Alternative |
|---------|--------------|-------------|
| Navigation / Header | shadcn/ui | Origin UI |
| Hero | Magic UI, Aceternity UI | Cult UI |
| Features grid | Magic UI (bento grid) | shadcn/ui cards |
| Testimonials | Magic UI (marquee) | Aceternity UI |
| Pricing | shadcn/ui | Origin UI |
| FAQ / Accordion | shadcn/ui | Origin UI |
| CTA sections | Magic UI | Aceternity UI |
| Footer | shadcn/ui | Origin UI |
| Background effects | Aceternity UI | Magic UI |
| Animated text | Magic UI | Aceternity UI |

## Tech Stack

All libraries converge on:
- **Framework:** Next.js 14+ (App Router)
- **Styling:** Tailwind CSS v4+
- **Animation:** Framer Motion
- **Types:** TypeScript
- **Init:** `npx create-next-app@latest`

## Anti-Patterns to Avoid

- Tailwind default indigo-500 (the #1 AI-generated tell)
- Inter font as the only font
- Purple gradients
- Generic 3-column grid for everything
- Rounded cards on white background with drop shadows
- Stock placeholder text ("Lorem ipsum")
- Identical card heights with identical padding
