# Image & Illustration Sources

Free, commercial-use visual assets for the ANF Framework. All downloadable — never hotlink.

## SVG Illustration Libraries

Use these for hero visuals, feature section illustrations, and decorative elements.

### unDraw (undraw.co)
- **License:** MIT — free for commercial use, no attribution
- **Style:** Flat, modern, customizable brand color
- **Best for:** Hero illustrations, feature visuals, empty states
- **How to use:** Browse → pick illustration → set brand color → download SVG → save to `public/images/`
- **Search via:** WebSearch for `site:undraw.co/illustrations <keyword>`

### DrawKit (drawkit.com)
- **License:** Free tier — MIT, commercial OK
- **Style:** Clean line art, isometric, colorful
- **Best for:** SaaS/tech product illustrations, feature icons
- **Packs:** Classic, Grape (isometric), Peach (3D)
- **How to use:** Browse free packs → download SVGs → save to `public/images/`

### ManyPixels (manypixels.co/gallery)
- **License:** MIT — free for commercial use
- **Style:** Flat, isometric, varied
- **Best for:** Generic business/tech illustrations
- **How to use:** Search gallery → download SVG → customize color in SVG source

### Storyset (storyset.com)
- **License:** Free with Freepik attribution (or paid for no attribution)
- **Style:** Animated illustrations, multiple art styles
- **Best for:** Hero sections, about pages
- **Note:** Attribution required on free tier

### SVGRepo (svgrepo.com)
- **License:** Mixed — filter by MIT/CC0
- **Best for:** Icons, small illustrations, logos
- **How to use:** Search → filter license → download SVG
- **Caution:** Check license per-SVG, not all are free

### Lucide (lucide.dev) — already installed
- **License:** ISC (MIT-like)
- **Best for:** UI icons (nav, buttons, feature lists)
- **Note:** Already in the stack. Use for small icons, NOT for section illustrations.

## Colorful Feature Icons (larger than standard icons)

When you need icons bigger and more detailed than Lucide (like the shield+server icons on Vertisky):

- **Phosphor Icons** (phosphoricons.com) — 6,000+, MIT, 6 weights including `duotone` (two-tone colored)
- Install: `npm install @phosphor-icons/react`
- These are more visually substantial than Lucide at larger sizes

## CSS Background Generators

Generate SVGs for section dividers, backgrounds, and decorative shapes. Download the SVG output, save to `public/images/` or inline as JSX.

### Waves & Dividers
- **getwaves.io** — SVG wave section dividers
- **shapedivider.app** — More divider shapes (curves, triangles, tilts)
- Generate → copy SVG → save as `public/images/wave-divider.svg` or inline between sections

### Blobs & Shapes
- **blobmaker.app** — Random blob SVGs
- **Haikei** (haikei.app) — Layered waves, blobs, gradient meshes, stacked waves, circle scatter
- Generate → download SVG → use as section background

### Patterns
- Already using Magic UI's DotPattern, GridPattern, RetroGrid as components
- For custom patterns: **heropatterns.com** (SVG patterns, CC BY 4.0)

## Photo Sources (when illustrations aren't enough)

### Unsplash (unsplash.com)
- **License:** Unsplash License — free commercial use, no attribution required
- **How to download:**
  ```bash
  # Search on unsplash.com, get photo ID from URL, download:
  curl -L "https://images.unsplash.com/<photo-id>?w=800&h=500&fit=crop&q=80" -o public/images/hero-photo.jpg
  ```
- **Best for:** People, environments, lifestyle shots, backgrounds

### Pexels (pexels.com)
- **License:** Pexels License — free commercial use
- **Similar to Unsplash** but different photo selection

## Usage Pattern

```bash
# Create images directory
mkdir -p public/images

# Download illustrations (example)
# After finding the right SVG on unDraw/DrawKit/ManyPixels:
curl -L "<svg-url>" -o public/images/hero-illustration.svg
curl -L "<svg-url>" -o public/images/feature-security.svg
curl -L "<svg-url>" -o public/images/feature-speed.svg

# Generate wave divider at getwaves.io, save output:
# (copy SVG content into a file)
```

```tsx
// Use in Next.js
import Image from "next/image";

// SVG illustrations
<Image src="/images/hero-illustration.svg" alt="Product illustration" width={500} height={400} />

// Or inline SVG for color customization
// (import SVG content as React component)
```

## Best Practice: Photos > SVGs for Visual Richness

Testing shows that **real photography** (Unsplash/Pexels) consistently scores higher on visual richness than flat SVG illustrations. Use photos as:
- **Hero backgrounds** with gradient overlays (`bg-gradient-to-r from-background via-background/95 to-background/70`)
- **Bento card backgrounds** at low opacity (`opacity-20`) with gradient fade from bottom
- **CTA section backgrounds** with blur overlay (`bg-background/90 backdrop-blur-sm`)

Photos add atmospheric depth that CSS and SVGs cannot match. Download 3-5 relevant photos per page.

### Unsplash Direct Download (no API key needed)

```bash
# Pattern: https://images.unsplash.com/photo-{ID}?w={width}&h={height}&fit=crop&q=80
curl -L "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&h=600&fit=crop&q=80" -o public/images/hero.jpg
```

To find photo IDs: search on unsplash.com, the ID is in the URL after `/photo-`.

## Selection Guide

| Section | Best Source | Type |
|---------|-----------|------|
| Hero (main visual) | **Unsplash photo** as background + gradient overlay | Full-width photo (800px+) |
| Feature cards | **Unsplash photo** at 15-20% opacity OR unDraw SVG | Background photo or illustration |
| How it works | DrawKit, ManyPixels | Step illustrations |
| Background | Haikei, getwaves.io | SVG patterns, waves, blobs |
| Section dividers | getwaves.io, shapedivider.app | Wave/curve SVGs |
| Testimonial avatars | CSS circles with initials | No image needed |
| CTA background | Haikei gradient mesh | Full-width SVG background |
| Small icons | Lucide (already installed) | Inline icons |

## Additional Free Sources (discovered via research)

### 3D Illustrations
- **Shapefest** (shapefest.com) — 100,000+ 3D shapes, free at 512px. Commercial OK.
- **Khagwal 3D** (3d.khagwal.com) — CC0, 3D illustration packs. No attribution.

### People Illustrations
- **Humaaans** (humaaans.com) — CC0, mix-and-match human figures. SVG/Figma.
- **Open Peeps** (openpeeps.com) — CC0, sketchy human figures. SVG download.
- **Blush Design** (blush.design) — Free plan, 50+ customizable collections. SVG/PNG export.

### Animated Icons
- **LottieFiles** (lottiefiles.com) — 800K+ Lottie animations, free commercial use. JSON/GIF.
- **Lordicon** (lordicon.com) — 42K+ animated icons. Free with attribution.
- **Useanimations** (useanimations.com) — Micro-animation icons as Lottie JSON.

### Extra SVG Generators
- **fffuel** (fffuel.co) — 50+ SVG generators (noise, fluid gradients, mesh, blobs, grains). All free commercial.
- **CSS Pattern** (css-pattern.com) — Pure CSS geometric patterns, no images needed.

### Gradient Collections
- **WebGradients** (webgradients.com) — 180 curated gradients as CSS/PNG. Free.
- **Gradient.page** (gradient.page) — 542 UI gradients with CSS code.

### Device Mockups
- **Device Shots** (deviceshots.com) — Free device frame mockups, no account.
- **Shotframe** (shotframe.app) — Free, no watermark, pixel-perfect device frames.

### Extra Photo Sources
- **Reshot** (reshot.com) — Free commercial photos, curated.
- **Coverr** (coverr.co) — Free looping video backgrounds for hero sections.
- **Mixkit** (mixkit.co) — Free video backgrounds and stock footage.

### Textures
- **AmbientCG** (ambientcg.com) — CC0, 1,300+ PBR textures up to 8K.
- **Poly Haven** (polyhaven.com/textures) — CC0, ultra-high-res textures.
