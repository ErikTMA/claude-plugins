---
name: anf-website-builder
description: "Build professional websites that don't look AI-generated using the ANF Framework (Assemble, Normalize, Fill). Use when the user wants to create a website, landing page, or marketing page that looks designer-made. Triggers: 'build me a website', 'create a landing page', 'make a professional site', 'ANF framework', or any request for a polished web page that should not look like typical AI output. Also use when the user complains about generic/ugly AI-generated websites. Do NOT use for: dashboards, admin panels, web apps with complex state, or internal tools — those need different patterns."
---

# ANF Website Builder

Build websites that look designer-made by using ACTUAL designer-made components and REAL illustrations. Never hand-write sections from scratch. Never ship a page without visual assets.

**The rule:** If a component exists in a library, use it. If an illustration exists for free, download it.

## The Framework

**A**ssemble — install real components from libraries
**N**ormalize — unify into one cohesive design
**I**llustrate — source and add real visuals to every page
**F**ill — research topic, populate with real content

## Workflow

### Step 1: Understand the Project

Ask the user (if not already clear):
- What is the product/service/company?
- What sections? (hero, features, pricing, testimonials, FAQ, etc.)
- Design preferences? (dark/light, minimal/bold)
- Reference sites?

### Step 2: Assemble — Install and Use Real Components

**CRITICAL: Actually install components from libraries. Do NOT hand-write sections.**

Read `references/component-libraries.md` for the full component library list.

**Init project:**
```bash
npx --yes create-next-app@latest <name> --typescript --tailwind --app --src-dir --no-eslint --no-import-alias --use-npm --turbopack --yes
cd <name>
npx --yes shadcn@latest init -d
npm install framer-motion lucide-react
mkdir -p public/images
```

**For each section, install the actual component:**

#### Hero Section
```bash
npx --yes shadcn@latest add "https://magicui.design/r/animated-gradient-text"
npx --yes shadcn@latest add "https://magicui.design/r/shimmer-button"
npx --yes shadcn@latest add "https://magicui.design/r/particles"
```

#### Features
```bash
npx --yes shadcn@latest add "https://magicui.design/r/bento-grid"
# OR
npx --yes shadcn@latest add "https://magicui.design/r/magic-card"
```

#### Social Proof / Testimonials
```bash
npx --yes shadcn@latest add "https://magicui.design/r/marquee"
```

#### Pricing / FAQ / Navigation
```bash
npx --yes shadcn@latest add card button accordion navigation-menu badge separator
```

#### Animated Elements
```bash
npx --yes shadcn@latest add "https://magicui.design/r/word-rotate"
npx --yes shadcn@latest add "https://magicui.design/r/blur-fade"
```

#### Background Effects
```bash
npx --yes shadcn@latest add "https://magicui.design/r/dot-pattern"
npx --yes shadcn@latest add "https://magicui.design/r/retro-grid"
```

**All components install to `src/components/ui/`.** Import from there:
```tsx
import { BentoGrid, BentoCard } from "@/components/ui/bento-grid";
import { BlurFade } from "@/components/ui/blur-fade";  // named export, NOT default
```

**Stats/metrics:** Use plain `<span>` with specific numbers. Do NOT use NumberTicker — it shows 0 on static renders.

### Step 3: Normalize — Unify the Design

1. **Typography** — Pick ONE font pairing via `next/font/google`. Never use Inter alone.
2. **Color palette** — NOT indigo/purple/violet. Update CSS variables in `globals.css`.
3. **Light or dark mode** — Match the brand. Customize `:root` or `.dark` CSS variables.
4. **Spacing** — `py-20` or `py-24` sections, `max-w-6xl mx-auto px-6` containers.
5. **Visual rhythm** — At least 3 different background treatments across sections.
6. **Remove AI tells** — No identical grids, no generic words, no round numbers, no default gray palette.

### Step 4: Illustrate — Source Visuals for Every Page

**This step runs PER PAGE.** For each page, analyze every section and determine what visual assets would enhance it. Then find, download, and integrate them.

Read `references/image-sources.md` for the full source list.

**PREFER REAL PHOTOS over flat SVG illustrations.** Testing shows Unsplash photos score significantly higher on visual richness than generic SVGs. Photos add atmospheric depth that CSS cannot match.

**The process:**

1. **Audit the page** — For each section, determine the visual type needed.
2. **Download photos from Unsplash/Pexels** (free, no API key):
   ```bash
   # Search unsplash.com, get photo ID from URL, download:
   curl -L "https://images.unsplash.com/photo-{ID}?w=800&h=600&fit=crop&q=80" -o public/images/hero.jpg
   ```
   Download 3-5 photos per page matching the product/industry.
3. **Use photos as backgrounds with overlays**, not as standalone images:
   ```tsx
   {/* Hero: full-width photo + gradient overlay */}
   <div className="absolute inset-0">
     <Image src="/images/hero.jpg" alt="" fill className="object-cover" />
     <div className="absolute inset-0 bg-gradient-to-r from-background via-background/95 to-background/70" />
   </div>

   {/* Bento card: photo at low opacity + gradient fade */}
   background: (
     <div className="absolute inset-0 overflow-hidden rounded-xl">
       <Image src="/images/feature.jpg" alt="" fill className="object-cover opacity-20" />
       <div className="absolute inset-0 bg-gradient-to-t from-card via-card/80 to-transparent" />
     </div>
   )
   ```
4. **Supplement with SVGs** from unDraw/DrawKit for specific illustrations where photos don't fit.
5. **Generate CSS backgrounds** — Use gradient blobs (`blur-[120px]`), DotPattern, RetroGrid for section variety.

**Visual requirements per section type:**

| Section | Must Have | Source |
|---------|----------|--------|
| Hero | Large illustration OR detailed product mockup | unDraw, DrawKit, or CSS mockup |
| Features | One illustration per feature (or per large card) | unDraw, DrawKit, ManyPixels |
| How it works | Step illustrations or large numbered icons | DrawKit, unDraw |
| Section dividers | Wave or curve SVG between at least 2 sections | getwaves.io, shapedivider.app |
| CTA section | Background pattern or gradient mesh | Haikei, heropatterns.com |
| Testimonials | Colored avatar initials (CSS, no download needed) | CSS |

**What NOT to do:**
- Don't skip this step — text-only pages score 5/10 on visual richness regardless of copy quality
- Don't use tiny Lucide icons as section illustrations — they're for buttons and lists, not visual focal points
- Don't hotlink to external URLs — always download to `public/images/`
- Don't use the same illustration twice on one page

### Step 5: Fill — Research and Populate

**Research** the product/industry with WebSearch. Identify realistic features, pricing, testimonials, FAQs, stats.

**Content quality rules:**
- Headlines: benefit-driven and specific. Bad: "Everything your app should be." Good: "Ship 3x faster with zero YAML."
- Stats: precise numbers — "14,283" not "14,000+", "2.3s" not "fast"
- Testimonials: include specific claims — "Lost 23kg in 6 months", "integration took 23 minutes"
- FAQ answers: include technical details (encryption type, API name, percentage)
- Banned headline words: "Powerful", "Seamless", "Revolutionary", "Game-changing", "Next-gen", "Cutting-edge"

### Step 6: Review and Polish

Run `npm run dev` and use Playwright to screenshot the result. Check:
- Every section has a visual element (illustration, pattern, or mockup)
- No plain text-on-background sections
- Section backgrounds vary (at least 3 different treatments)
- Features and How-it-works use different component types
- Wave/curve dividers separate at least 2 sections
- No overflow or rendering issues

## Important Rules

1. **ALWAYS install components from libraries** — never hand-write what a library provides.
2. **ALWAYS illustrate** — every page needs real photos (Unsplash) or SVGs. Text-only = AI-looking.
3. **Never use Tailwind's default indigo/purple** — pick a unique brand color.
4. **Never use Inter as the only font** — always add a heading font.
5. **Test by viewing the result** — use Playwright to screenshot, don't guess.
6. **Per-page illustration** — run the Illustrate step for every page, not just once per site.
7. **Never use `BlurFade` with `inView` prop** — it uses IntersectionObserver which causes sections to be invisible in screenshots and static renders. Use `BlurFade` with `delay` only.
8. **Never use `NumberTicker`** — it animates from 0 and shows 0 in screenshots. Use plain text spans.
9. **Card contrast on dark themes** — use solid `bg-card` not transparent `bg-white/5`. Glass effects need at least 8-10% opacity to be visible.
