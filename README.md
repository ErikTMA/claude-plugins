# ETMA Plugins for Claude Code

A collection of open-source plugins for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's official CLI for AI-assisted software engineering.

## Plugins

### [anf-website-builder](plugins/anf-website-builder/)

**Build professional websites that don't look AI-generated.**

Uses the ANIF Framework (Assemble, Normalize, Illustrate, Fill) to build landing pages from real designer components, real Unsplash photography, and autoresearch-validated design patterns. Developed through 12 iterations of automated scoring.

**Features:**

- **Real components** — shadcn/ui, Magic UI, and Aceternity UI instead of hand-written Tailwind
- **Real photography** — Downloads Unsplash photos as atmospheric section backgrounds (free, no API key)
- **30+ free image sources** — Illustrations, 3D assets, animations, textures, gradients, device mockups
- **Anti-AI-tell patterns** — No default indigo, no Inter-only fonts, no round numbers, no generic headlines
- **Per-page illustration** — Automatically determines what visuals each section needs and sources them
- **Content quality rules** — Specific numbers, benefit-driven headlines, realistic testimonials
- **Works with brainstorming** — Pairs well with the superpowers:brainstorming skill for requirements gathering

**Quick start:**

```bash
claude plugin marketplace add ErikTMA/claude-plugins
claude plugin install anf-website-builder@etma-plugins
```

Then ask Claude to build a website:

```
Build me a landing page for my SaaS product
Create a website for a coffee subscription service
Scrape example.com and rebuild it with modern design
```

---

### [learn-from-video](plugins/learn-from-video/)

**Extract knowledge from any video — YouTube, Vimeo, Loom, or local files.**

Give Claude Code a video URL and it "watches" it for you: extracts the transcript, detects scene changes to capture keyframes, and analyzes both text and visuals to produce structured knowledge you can recall later.

**Features:**

- **Any video source** — YouTube, Vimeo, Loom, or any site [yt-dlp](https://github.com/yt-dlp/yt-dlp) supports, plus local `.mp4`/`.mkv`/`.webm` files
- **3-tier transcript fallback** — YouTube captions API → yt-dlp auto-subtitles → local Whisper AI transcription
- **Scene-change keyframe extraction** — detects visual changes using [PySceneDetect](https://github.com/Breakthrough/PySceneDetect), extracts key frames, deduplicates with perceptual hashing
- **Video type classification** — samples frames across the video, classifies content type (terminal, slides, talking head, screen recording), adjusts detection sensitivity per type
- **GPU-accelerated Whisper** — auto-detects NVIDIA GPU and VRAM, selects the best Whisper model for your hardware
- **Docker-based** — zero host dependencies beyond Docker. Two images: `light` (~500 MB) for download and keyframes, `full` (~8 GB) for Whisper + CUDA
- **Persistent knowledge** — saves transcripts, keyframes, and structured knowledge docs to `~/.claude/learned/`, stores summaries in vector memory for future recall

**Quick start:**

```bash
claude plugin marketplace add ErikTMA/claude-plugins
claude plugin install learn-from-video@etma-plugins

/learn-from-video https://www.youtube.com/watch?v=...
```

**Requirements:**

- [Docker](https://docs.docker.com/get-docker/) (required)
- NVIDIA GPU + [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) (optional, for GPU-accelerated Whisper)

## Installation

### As a marketplace

Register the marketplace and install individual plugins:

```bash
claude plugin marketplace add ErikTMA/claude-plugins
claude plugin install anf-website-builder@etma-plugins
claude plugin install learn-from-video@etma-plugins
```

### Manual

Clone and copy plugin files directly:

```bash
git clone https://github.com/ErikTMA/claude-plugins.git
cp -r claude-plugins/plugins/anf-website-builder ~/.claude/plugins/anf-website-builder
```

## Contributing

Contributions welcome. Each plugin lives in `plugins/<name>/` and follows the [Claude Code plugin structure](https://docs.anthropic.com/en/docs/claude-code/plugins):

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── skills/
│   └── <name>/
│       └── SKILL.md         # Skill instructions
├── references/              # Supporting documentation
├── commands/                # Slash commands (optional)
├── scripts/                 # Supporting scripts (optional)
└── README.md
```

## License

MIT
