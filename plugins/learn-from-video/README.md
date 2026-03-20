# learn-from-video

A Claude Code plugin that lets Claude "watch" videos and extract structured knowledge from them.

Give it a URL or local file — it grabs the transcript, captures keyframes at every scene change, and Claude analyzes both to produce knowledge you can recall in future conversations.

## Why

YouTube tutorials, conference talks, and screen recordings contain knowledge that's trapped in video format. Claude can't watch videos, but it can read transcripts and view images. This plugin bridges the gap:

1. **Extracts the transcript** using a 3-tier fallback (YouTube captions → auto-subtitles → local Whisper AI)
2. **Captures keyframes** at every visual change (new code on screen, slide transition, UI switch)
3. **Feeds both to Claude** for analysis — transcript text + keyframe images together
4. **Saves structured knowledge** for future recall via vector memory

A 10-minute tutorial becomes searchable knowledge in ~5 minutes.

## Install

```bash
claude plugin marketplace add ErikTMA/claude-plugins
claude plugin install learn-from-video@etma-plugins
```

## Usage

```bash
# Basic — Claude auto-detects what the video is about
/learn-from-video https://www.youtube.com/watch?v=...

# With intent — tell Claude what to focus on
/learn-from-video https://www.youtube.com/watch?v=... "3 tricks for Claude Code hooks"

# Local file
/learn-from-video ~/Downloads/tutorial.mp4 "kubernetes deployment walkthrough"

# Force best quality transcription (Whisper, slower)
/learn-from-video --force-whisper https://www.youtube.com/watch?v=...

# Re-process a video you've already learned
/learn-from-video --force https://www.youtube.com/watch?v=...
```

On first run, the plugin asks whether you want to always use Whisper for transcription. It detects your GPU and shows personalized time estimates so you can decide.

## How It Works

```
Video URL or local file
    │
    ├── Transcript (3-tier fallback)
    │   1. YouTube captions MCP (instant)
    │   2. yt-dlp auto-subtitles (seconds)
    │   3. Whisper local transcription (minutes, GPU-accelerated)
    │
    ├── Keyframes (scene detection)
    │   1. Sample 10 frames across the video
    │   2. Claude classifies video type (terminal, slides, talking head, etc.)
    │   3. Full scene detection with type-appropriate sensitivity
    │   4. Perceptual hash deduplication
    │
    ▼
Claude reads transcript + views all keyframes
    → Extracts structured knowledge
    → Verifies mentioned tools/packages are still current
    → Saves to ~/.claude/learned/<video-slug>/
    → Stores summary in vector memory for future recall
```

### After learning

Claude presents a summary and asks what you want to do:

- **Generate skill(s)** — turn a workflow from the video into a reusable Claude Code skill
- **Add CLAUDE.md rules** — extract tips and add them to your project instructions
- **Create agent definition** — build a specialized agent based on the video's expertise
- **Apply config changes** — install tools or MCP servers mentioned in the video
- **Nothing** — the knowledge is saved regardless, searchable in future conversations

## Transcript Tiers

| Tier | Source | Speed | Quality | When |
|------|--------|-------|---------|------|
| 1 | YouTube captions MCP | Instant | Varies | YouTube URLs with captions available |
| 2 | yt-dlp auto-subtitles | Seconds | OK | YouTube auto-generated or embedded subs |
| 3 | Whisper (local) | Minutes | Best | No captions, local files, or `--force-whisper` |

### Whisper GPU auto-selection

When Whisper is needed, the plugin detects your GPU and picks the best model:

| VRAM | Model | Speed (10-min video) |
|------|-------|---------------------|
| 10+ GB | large-v3 | ~3 min |
| 5–10 GB | medium | ~2 min |
| 2–5 GB | small | ~1 min |
| < 2 GB | base | ~30s |
| No GPU | medium (CPU) | ~10–15 min |

Override with `--whisper-model <model>` if needed.

## Keyframe Detection

The plugin samples frames across the full video to classify the content type, then applies appropriate scene detection thresholds:

| Content Type | Low | Medium | High |
|-------------|-----|--------|------|
| Terminal/code | 0.15 | 0.08 | 0.04 |
| Slides | 0.40 | 0.25 | 0.15 |
| Talking head | 0.50 | 0.35 | 0.25 |
| Screen recording | 0.25 | 0.15 | 0.08 |

Override with `--sensitivity` or `--type`.

## Output

Everything is saved to `~/.claude/learned/<video-slug>/`:

```
~/.claude/learned/<video-slug>/
├── metadata.json       # URL, title, channel, duration, processing info
├── transcript.json     # Timestamped transcript (unified format)
├── keyframes/          # Scene-change keyframe images
│   ├── frame_001_00m12s.png
│   ├── frame_002_01m45s.png
│   └── ...
├── knowledge.md        # Structured knowledge document
└── artifacts/          # Optional: generated skills, rules, configs
```

## Flags

| Flag | Description |
|------|-------------|
| `--force` | Re-process a video that was already learned |
| `--force-whisper` | Skip captions, always use Whisper |
| `--sensitivity low\|medium\|high` | Keyframe detection sensitivity (default: medium) |
| `--type terminal\|slides\|talking_head\|screen_recording` | Override video type detection |
| `--whisper-model <model>` | Override Whisper model (tiny/base/small/medium/large-v3) |
| `--skip-verify` | Skip verification of mentioned tools/packages |

## Configuration

Stored at `~/.claude/learned/.config.json` (created on first run):

```json
{
  "always_whisper": true,
  "gpu_name": "NVIDIA GeForce RTX 3090",
  "vram_mb": 24123,
  "whisper_model": "large-v3"
}
```

Edit this file to change your default transcription preference.

## Requirements

- **Docker** — all heavy tools (yt-dlp, ffmpeg, Whisper, PySceneDetect) run inside containers
- **NVIDIA GPU + Container Toolkit** — optional, for GPU-accelerated Whisper. Without it, Whisper runs on CPU (slower but works)

The plugin builds two Docker images on first use:
- `learn-from-video:light` (~500 MB) — yt-dlp, ffmpeg, PySceneDetect, imagehash
- `learn-from-video:full` (~8 GB) — adds Whisper + PyTorch + CUDA (only pulled when needed)

## Supported Sources

Any URL that [yt-dlp supports](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md) (1000+ sites), including:

- YouTube (videos, shorts)
- Vimeo
- Loom
- Twitch (VODs, clips)
- Dailymotion
- Local files (.mp4, .mkv, .webm, .mov, .avi)

## License

MIT
