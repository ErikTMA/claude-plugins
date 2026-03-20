---
name: learn-from-video
description: "Use when the user provides a video URL (YouTube, Vimeo, Loom, or any yt-dlp-supported site) or local video file path and wants to extract knowledge from it. Triggers: 'learn from this video', 'watch this', 'what does this video teach', any YouTube/Vimeo/Loom URL with a learning intent, local .mp4/.mkv/.webm file paths with learning intent. Also triggers on /learn-from-video slash command. Do NOT use for: playing videos, downloading videos without learning intent, or audio-only files."
---

# Learn From Video

Extract knowledge from any video by combining transcript analysis with visual keyframe inspection. Supports any yt-dlp-compatible URL or local video file.

## Prerequisites

- Docker must be installed and running
- **Plugin root resolution:** Before running any script, resolve the plugin install path. Run this ONCE at the start and reuse `$PLUGIN_ROOT` for all subsequent commands:
  ```bash
  PLUGIN_ROOT=$(find ~/.claude/plugins/cache -path "*/learn-from-video/*/scripts/check-deps.sh" 2>/dev/null | sort -V | tail -1 | xargs dirname | xargs dirname)
  ```
  If `$PLUGIN_ROOT` is empty, report: "learn-from-video plugin not found. Install with: `claude plugin install learn-from-video@etma-tools`" and stop.
- Scripts are at `$PLUGIN_ROOT/scripts/`
- Docker build context is at `$PLUGIN_ROOT/docker/`
- Detailed script I/O docs: `$PLUGIN_ROOT/references/script-interfaces.md`

## Input Parsing

The user provides: `<url-or-path> [intent description] [flags]`

**Flags:**
- `--force` — re-process a video that was already learned
- `--sensitivity low|medium|high` — keyframe detection sensitivity (default: medium)
- `--type terminal|slides|talking_head|screen_recording` — override video type detection
- `--skip-verify` — skip currency verification of mentioned tools/packages
- `--force-whisper` — skip captions/subtitles, always use Whisper for transcription (higher quality but slower)
- `--whisper-model <model>` — override whisper model (default: auto-selected based on available VRAM)

**Intent:** Free-form text describing what the video contains. If not provided, do a quick transcript scan and ask the user.

## Workflow

### Step 0: Check Configuration

Check if `~/.claude/learned/.config.json` exists. If it does, read it and apply saved preferences.

If it does NOT exist (first run), run Step 1 (check-deps) FIRST to detect hardware, then present the user with personalized time estimates.

**Detect hardware for estimates:**
- If `nvidia_runtime` is true, probe VRAM:
  ```bash
  VRAM_MB=$(docker run --rm --gpus all learn-from-video:full -c \
    "python3 -c 'import torch; print(torch.cuda.get_device_properties(0).total_memory // 1048576)'" 2>/dev/null || echo "0")
  GPU_NAME=$(docker run --rm --gpus all learn-from-video:full -c \
    "python3 -c 'import torch; print(torch.cuda.get_device_properties(0).name)'" 2>/dev/null || echo "Unknown")
  ```
- Select the whisper model that would be used (same logic as transcribe.sh):
  - 10+ GB → large-v3, 5-10 GB → medium, 2-5 GB → small, <2 GB → base
- Calculate time estimates per model:
  - large-v3 GPU: ~3 min per 10-min video
  - medium GPU: ~2 min per 10-min video
  - small GPU: ~1 min per 10-min video
  - base GPU: ~30s per 10-min video
  - medium CPU: ~10-15 min per 10-min video

**Then ask the user with their specific estimates:**

> "This is your first time using learn-from-video. One quick preference:
>
> **Transcription method:**
> Whisper (local AI) produces significantly better transcripts than YouTube's auto-captions — proper sentences, correct technical terms, no duplicates.
>
> Your hardware: [GPU_NAME] ([VRAM_MB]MB VRAM) / or "No GPU detected (CPU only)"
> Whisper model: [selected model]
>
> Estimated transcription times on your hardware:
> | Video Length | Whisper | YouTube captions |
> |-------------|---------|-----------------|
> | 5 min       | ~[X]    | instant         |
> | 10 min      | ~[X]    | instant         |
> | 30 min      | ~[X]    | instant         |
> | 60 min      | ~[X]    | instant         |
>
> Always use Whisper for best quality? (y/n)"

Fill in [X] with calculated estimates based on detected hardware and model.

Save their choice to `~/.claude/learned/.config.json`:
```json
{
  "always_whisper": true,
  "gpu_name": "NVIDIA GeForce RTX 3090",
  "vram_mb": 24123,
  "whisper_model": "large-v3",
  "created_at": "2026-03-20T01:00:00Z"
}
```

If `always_whisper` is `true`, treat it the same as `--force-whisper` for all future runs (user can still override per-run behavior with the flag or by editing the config).

### Step 1: Check Dependencies

Run: `bash $PLUGIN_ROOT/scripts/check-deps.sh`

Parse the JSON output. If exit code is non-zero, report the error and stop.
Note the `nvidia_runtime` and image availability for later steps.

### Step 2: Check for Existing Slug

Generate slug from URL/path:
- For URLs: extract video title AND channel name (run in light container):
  ```bash
  VIDEO_TITLE=$(docker run --rm learn-from-video:light -c "yt-dlp --get-title '<url>'" 2>/dev/null)
  VIDEO_CHANNEL=$(docker run --rm learn-from-video:light -c "yt-dlp --print channel '<url>'" 2>/dev/null)
  ```
  Store both for use in metadata.json later.
- For local files: use the filename without extension, channel is "local"
- Slugify: lowercase, replace non-alphanumeric with hyphens, truncate to 60 chars
- Fallback: truncated SHA256 of the input

Check if `~/.claude/learned/<slug>/` exists:
- If exists and no `--force`: inform user "Already learned this video. Use --force to re-process." and stop.
- If exists and `--force`: proceed (will overwrite).
- If not exists: proceed.

Create the output directory: `mkdir -p ~/.claude/learned/<slug>/keyframes`

### Step 3: Extract Transcript (3-tier fallback)

**If `--force-whisper` is set OR `always_whisper` is `true` in `~/.claude/learned/.config.json`:** skip tiers 1 and 2 entirely, go straight to tier 3. Note: whisper needs the video file. Download it first if not local:
```bash
docker run --rm -v "$OUTPUT_DIR:/out" learn-from-video:light -c \
  "yt-dlp -f 'bestvideo[height<=720][vcodec!*=av01]+bestaudio/best[height<=720]' -S 'vcodec:h264' --merge-output-format mp4 -o '/out/video.mp4' '<url>'"
```
Then pass `$OUTPUT_DIR/video.mp4` to transcribe.sh. Clean up the video file after transcription completes.

**Tier 1 — YouTube Transcript MCP:**
- Only for URLs (not local files)
- Call `mcp__plugin_learn-from-video_youtube-transcript__get_transcript` with the URL
- If successful, convert to unified format and save to `~/.claude/learned/<slug>/transcript.json`
- If failed, continue to tier 2

**Tier 2 — Embedded/auto subtitles:**
- These are extracted as a side effect of the full `extract-video.sh` run in Step 4 Phase D
- After Phase D completes, check if `embedded_subs.srt` or `autosub.en.vtt` exists in the output dir
- If found, parse into unified JSON using this Python snippet in the light Docker container:
  ```bash
  docker run --rm -v "$OUTPUT_DIR:/data" learn-from-video:light -c "python3 << 'PYEOF'
  import json, re, os
  segments = []
  for subfile in ['/data/embedded_subs.srt', '/data/autosub.en.vtt']:
      if not os.path.exists(subfile): continue
      text = open(subfile).read()
      source = 'embedded-subs' if 'embedded' in subfile else 'yt-dlp-autosub'
      # Parse SRT/VTT timestamps: 00:01:23,456 or 00:01:23.456
      for m in re.finditer(r'(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*\n(.+?)(?:\n\n|\Z)', text, re.DOTALL):
          start = int(m[1])*3600 + int(m[2])*60 + int(m[3]) + int(m[4])/1000
          end = int(m[5])*3600 + int(m[6])*60 + int(m[7]) + int(m[8])/1000
          txt = re.sub(r'<[^>]+>', '', m[9]).strip()
          if txt: segments.append({'start': round(start,2), 'end': round(end,2), 'text': txt})
      if segments: break
  if segments:
      json.dump({'source': source, 'language': 'en', 'segments': segments}, open('/data/transcript.json','w'), indent=2)
      print(f'Parsed {len(segments)} segments')
  else:
      print('No parseable segments found')
  PYEOF"
  ```
- If transcript.json was created, Tier 2 succeeded — skip Tier 3
- If no subtitles found or parsing produced nothing, continue to tier 3

**Tier 3 — Whisper local transcription:**
- Warn if video is >60 minutes: "This video is [X] minutes long. Whisper transcription may take a while. Continue?"
- If user provided `--whisper-model`, pass it as `--model` to the script
- Run: `bash $PLUGIN_ROOT/scripts/transcribe.sh <video-path> ~/.claude/learned/<slug>/ --device auto [--model <whisper-model>]`
- Note: the user-facing flag is `--whisper-model`, the script flag is `--model`
- **VRAM-based auto-selection** (when no `--whisper-model` specified):
  - 10+ GB VRAM → `large-v3` (best quality, ~3 min per 10 min video)
  - 5-10 GB VRAM → `medium` (good quality, ~2 min per 10 min video)
  - 2-5 GB VRAM → `small` (decent quality, ~1 min per 10 min video)
  - <2 GB VRAM → `base` (basic quality, fastest)
  - No GPU → `medium` on CPU (~10-15 min per 10 min video)
- The script writes progress to `~/.claude/learned/<slug>/transcribe_progress.json` — for long videos (>20 min on CPU), use Bash `run_in_background` and poll this file periodically

**Unified transcript format** (all tiers produce this):
```json
{
  "source": "youtube-captions|embedded-subs|yt-dlp-autosub|whisper",
  "language": "en",
  "segments": [
    {"start": 0.0, "end": 3.5, "text": "..."}
  ]
}
```

### Step 4: Extract Keyframes

**Phase A — Sample frames for classification:**

Run: `bash $PLUGIN_ROOT/scripts/extract-video.sh <url-or-path> ~/.claude/learned/<slug>/ --sample-only`

This produces 10 evenly-spaced frames in `samples/`.

**Phase B — Classify video type:**

If user provided `--type`, use that. Otherwise, view all 10 sample images and classify each frame as one of:
- `terminal` — dark background, monospace text, CLI output
- `slides` — presentation slides, large text, uniform backgrounds
- `talking_head` — person on camera, webcam-style
- `screen_recording` — browser, IDE, mixed UI elements

Note transition points (e.g., "frames 1-2 are talking_head, frames 3-10 are terminal").
Determine the dominant type and any transitions.

**Phase C — Select threshold:**

Apply sensitivity setting (default: medium) to the threshold matrix:

|                  | low  | medium | high |
|------------------|------|--------|------|
| terminal         | 0.15 | 0.08   | 0.04 |
| slides           | 0.40 | 0.25   | 0.15 |
| talking_head     | 0.50 | 0.35   | 0.25 |
| screen_recording | 0.25 | 0.15   | 0.08 |

For mixed-type videos: use the lowest applicable threshold (catches everything, may produce extra frames — acceptable, dedup handles it).

**Phase D — Full extraction:**

Run: `bash $PLUGIN_ROOT/scripts/extract-video.sh <url-or-path> ~/.claude/learned/<slug>/ --threshold <selected>`

The script handles scene detection, deduplication (phash, Hamming distance ≤3), and outputs keyframes + `keyframes.json`.

### Step 5: Merge Timeline

Read `keyframes.json` and `transcript.json`. For each keyframe, find the transcript segment with the closest start timestamp. Present the merged view as you analyze:

```
[00:12] frame_001_00m12s.png + "so first we open settings.json"
[01:45] frame_002_01m45s.png + "and add this hook configuration"
```

### Step 6: Analyze Content

Read the full transcript text. View ALL keyframe images. With the user's intent in mind:

1. **Strip narrative fluff** — remove filler ("hey guys", "so basically", "as you can see")
2. **Extract structured knowledge:**
   - Commands shown/spoken
   - Config snippets visible in keyframes or dictated
   - Workflows and processes described step-by-step
   - Tips, gotchas, and warnings
   - Tools, packages, and versions referenced
3. **Verify currency** (unless `--skip-verify`):
   - For each tool/package mentioned, check if still current via Context7 or WebSearch
   - Flag anything outdated with the current alternative
4. **Write knowledge.md** to `~/.claude/learned/<slug>/knowledge.md` — structured document with sections for each knowledge area
5. **Write metadata.json** to `~/.claude/learned/<slug>/metadata.json`:

```json
{
  "url": "<original-url-or-path>",
  "title": "<video-title>",
  "channel": "<channel-name>",
  "duration_seconds": 600,
  "intent": "<user-provided-intent>",
  "video_type": "terminal",
  "processed_at": "2026-03-19T12:00:00Z",
  "transcript_source": "youtube-captions",
  "keyframe_count": 25,
  "slug": "<slug>"
}
```

6. **Store in qdrant memory** — call qdrant-store with a summary of the learned knowledge for future recall

### Step 7: Present Results and Ask

Report what was learned:

```
Learned and saved to ~/.claude/learned/<slug>/. Here's a summary:

[concise summary of extracted knowledge]

Want me to do anything with this?
- Generate skill(s)
- Add CLAUDE.md rules
- Create agent definition
- Apply config changes
- Nothing, I just needed to understand it
```

Wait for user response. If they want artifacts:

- **Skills:** Generate SKILL.md files in `~/.claude/learned/<slug>/artifacts/`, using proper YAML frontmatter. Ask "Install to etma-tools?" before copying anywhere.
- **CLAUDE.md rules:** Generate rules in `~/.claude/learned/<slug>/artifacts/claude-md-rules.md`. Ask "Append to global or project CLAUDE.md?"
- **Agent definition:** Generate agent .md in `~/.claude/learned/<slug>/artifacts/`. Ask "Install to etma-agents?"
- **Config changes:** Generate config snippets in `~/.claude/learned/<slug>/artifacts/config-changes.md`. Ask "Apply these changes?"

**Never auto-install.** Always ask before modifying anything outside `~/.claude/learned/`.

## Error Handling

| Scenario | Action |
|----------|--------|
| Docker not running | Report error, suggest starting Docker |
| Download fails | Report "Couldn't download from this URL. Check the URL is valid and accessible." |
| No transcript (all tiers fail) | Report "Couldn't extract transcript." Offer visual-only analysis from keyframes (reduced quality). |
| Video requires auth | Report "Video requires authentication. Try providing cookies via yt-dlp." |
| Video >60 min | Warn about processing time, ask to confirm |
| Slug already exists | Report existing content, offer `--force` |
| Disk space low | Report available space, suggest cleanup |
