# Script Interfaces

Reference for all scripts in the learn-from-video plugin. The SKILL.md references this document.

## check-deps.sh

```
Usage: check-deps.sh
Exit codes:
  0 — all dependencies met
  1 — Docker not installed or not running
  2 — insufficient disk space (<5GB free for light, <15GB for full)
Stdout: JSON status report
  {
    "docker": true|false,
    "nvidia_runtime": true|false,
    "disk_free_gb": <number>,
    "light_image": true|false,
    "full_image": true|false,
    "error": "<message>"          ← only present on failure
  }
```

## extract-video.sh

```
Usage: extract-video.sh <url-or-path> <output-dir> [flags]
Flags:
  --threshold <float>    Scene detection threshold (default: 0.15)
  --sample-only          Only extract 10 sample frames, skip full scene detection
  --resolution <int>     Max video height in pixels (default: 720)

Exit codes:
  0 — success
  1 — download failed
  2 — scene detection failed
  3 — Docker not available

Output (<output-dir>/):
  samples/                    ← 10 evenly-spaced sample frames (always produced)
    sample_01_00m15s.png
    sample_02_01m30s.png
    ...
  keyframes/                  ← scene-detected frames (skipped if --sample-only)
    frame_001_00m12s.png
    frame_002_01m45s.png
    ...
  keyframes.json              ← [{timestamp: 12.3, file: "frame_001_00m12s.png"}, ...]
  embedded_subs.srt           ← if video has embedded subtitle tracks
  autosub.en.vtt              ← if yt-dlp found auto-generated subtitles

Stdout: JSON status
  {
    "stage": "samples"|"complete",
    "keyframe_count": <number>,
    "duration": <seconds>,
    "has_embedded_subs": true|false,
    "has_auto_subs": true|false
  }
```

## transcribe.sh

```
Usage: transcribe.sh <video-or-audio-path> <output-dir> [flags]
Flags:
  --device cuda|cpu|auto     GPU mode (default: auto — detects GPU)
  --model <whisper-model>    Whisper model (default: large-v3 on GPU, medium on CPU)

Exit codes:
  0 — success
  1 — transcription failed
  2 — Docker not available
  3 — full image not available and build failed

Output (<output-dir>/):
  transcript.json             ← unified format:
    {
      "source": "whisper",
      "language": "en",
      "segments": [
        {"start": 0.0, "end": 3.5, "text": "..."},
        ...
      ]
    }

Stdout: JSON status
  {"status": "ok", "segments": <count>, "model": "<model>", "device": "cuda|cpu"}
```
