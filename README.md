# ETMA Plugins for Claude Code

A collection of open-source plugins for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's official CLI for AI-assisted software engineering.

## Plugins

### [learn-from-video](plugins/learn-from-video/)

**Extract knowledge from any video — YouTube, Vimeo, Loom, or local files.**

Give Claude Code a video URL and it "watches" it for you: extracts the transcript, detects scene changes to capture keyframes, and analyzes both text and visuals to produce structured knowledge you can recall later.

**Features:**

- **Any video source** — YouTube, Vimeo, Loom, or any site [yt-dlp](https://github.com/yt-dlp/yt-dlp) supports, plus local `.mp4`/`.mkv`/`.webm` files
- **3-tier transcript fallback** — YouTube captions API → yt-dlp auto-subtitles → local Whisper AI transcription
- **Scene-change keyframe extraction** — detects visual changes using [PySceneDetect](https://github.com/Breakthrough/PySceneDetect), extracts key frames, deduplicates with perceptual hashing
- **Video type classification** — samples frames across the video, classifies content type (terminal, slides, talking head, screen recording), adjusts detection sensitivity per type
- **GPU-accelerated Whisper** — auto-detects NVIDIA GPU and VRAM, selects the best Whisper model for your hardware (large-v3 for 10+ GB, medium for 5-10 GB, small for 2-5 GB, CPU fallback)
- **Docker-based** — zero host dependencies beyond Docker. Two images: `light` (~500 MB) for download and keyframes, `full` (~8 GB) for Whisper + CUDA
- **Persistent knowledge** — saves transcripts, keyframes, and structured knowledge docs to `~/.claude/learned/`, stores summaries in vector memory for future recall
- **Smart output** — after learning, optionally generate skills, CLAUDE.md rules, agent definitions, or config changes based on what the video teaches

**Quick start:**

```bash
# Install
claude plugin marketplace add ErikTMA/claude-plugins
claude plugin install learn-from-video@etma-plugins

# Use
/learn-from-video https://www.youtube.com/watch?v=...
/learn-from-video https://www.youtube.com/watch?v=... "3 tricks for Claude Code hooks"
/learn-from-video ~/Downloads/tutorial.mp4 "kubernetes deployment walkthrough"
```

**Flags:**

| Flag | Description |
|------|-------------|
| `--force` | Re-process a video that was already learned |
| `--force-whisper` | Skip captions, always use Whisper (best quality) |
| `--sensitivity low\|medium\|high` | Keyframe detection sensitivity |
| `--type terminal\|slides\|talking_head\|screen_recording` | Override video type auto-detection |
| `--whisper-model <model>` | Override Whisper model selection |
| `--skip-verify` | Skip currency verification of mentioned tools |

**Requirements:**

- [Docker](https://docs.docker.com/get-docker/) (required)
- NVIDIA GPU + [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) (optional, for GPU-accelerated Whisper)

**How it works:**

```
Video URL or local file
    │
    ├──▶ Transcript (3-tier fallback)
    │    YouTube captions → yt-dlp auto-subs → Whisper (GPU/CPU)
    │
    ├──▶ Keyframes (scene detection)
    │    Sample 10 frames → classify video type → detect scenes
    │    → extract frames → deduplicate (perceptual hash)
    │
    ▼
Claude reads transcript + views keyframes
    → extracts structured knowledge
    → saves to ~/.claude/learned/<slug>/
    → stores in vector memory
    → optionally generates skills, rules, configs
```

## Installation

### As a marketplace

Register the marketplace and install individual plugins:

```bash
claude plugin marketplace add ErikTMA/claude-plugins
claude plugin install learn-from-video@etma-plugins
```

### Manual

Clone and copy the skill files directly:

```bash
git clone https://github.com/ErikTMA/claude-plugins.git
cp -r claude-plugins/plugins/learn-from-video ~/.claude/plugins/learn-from-video
```

## Contributing

Contributions welcome. Each plugin lives in `plugins/<name>/` and follows the [Claude Code plugin structure](https://docs.anthropic.com/en/docs/claude-code/plugins):

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── .mcp.json                # MCP server configs (optional)
├── skills/
│   └── <name>/
│       └── SKILL.md         # Skill instructions
├── commands/
│   └── <name>.md            # Slash command entry point
├── scripts/                 # Supporting scripts
├── docker/                  # Dockerfiles (if needed)
└── references/              # Documentation
```

## License

MIT
