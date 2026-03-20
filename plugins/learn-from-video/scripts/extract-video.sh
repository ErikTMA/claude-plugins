#!/usr/bin/env bash
set -euo pipefail

# Download video and extract keyframes via scene detection
# Usage: extract-video.sh <url-or-path> <output-dir> [--threshold <float>] [--sample-only]
# Exit codes: 0=success, 1=download failed, 2=scene detection failed, 3=Docker unavailable

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

INPUT="$1"
OUTPUT_DIR="$2"
shift 2

THRESHOLD="0.15"
SAMPLE_ONLY="false"
RESOLUTION="720"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="$2"; shift 2 ;;
    --sample-only) SAMPLE_ONLY="true"; shift ;;
    --resolution) RESOLUTION="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR/keyframes" "$OUTPUT_DIR/samples"

# Check Docker
if ! docker info &>/dev/null; then
  echo '{"error": "Docker is not available"}' >&2
  exit 3
fi

# Build light image if needed
if ! docker image inspect learn-from-video:light &>/dev/null; then
  echo "Building learn-from-video:light image..." >&2
  docker build -t learn-from-video:light -f "$PLUGIN_DIR/docker/Dockerfile.light" "$PLUGIN_DIR/docker" >&2
fi

# Determine if input is a local file or URL
IS_LOCAL="false"
if [ -f "$INPUT" ]; then
  IS_LOCAL="true"
fi

# Create a temporary working directory
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

if [ "$IS_LOCAL" = "true" ]; then
  # Copy local file into work dir (symlinks don't work across Docker bind mounts)
  cp "$(realpath "$INPUT")" "$WORK_DIR/video.mp4"
else
  # Download video via yt-dlp inside Docker
  echo "Downloading video..." >&2
  docker run --rm \
    -v "$WORK_DIR:/work" \
    learn-from-video:light \
    -c "yt-dlp -f 'bestvideo[height<=${RESOLUTION}][vcodec!*=av01]+bestaudio/best[height<=${RESOLUTION}]' \
        -S 'vcodec:h264' \
        --merge-output-format mp4 \
        -o '/work/video.mp4' \
        '$INPUT'" || { echo '{"error": "Download failed"}' >&2; exit 1; }
fi

# Get video duration for sample frame extraction
DURATION=$(docker run --rm \
  -v "$WORK_DIR:/work:ro" \
  learn-from-video:light \
  -c "python3 -c \"
import subprocess, json
r = subprocess.run(['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', '/work/video.mp4'], capture_output=True, text=True)
d = json.loads(r.stdout)
print(d['format']['duration'])
\"")

echo "Video duration: ${DURATION}s" >&2

# Extract 10 evenly-spaced sample frames
echo "Extracting sample frames..." >&2
docker run --rm \
  -v "$WORK_DIR:/work:ro" \
  -v "$OUTPUT_DIR/samples:/out" \
  learn-from-video:light \
  -c "python3 -c \"
import subprocess
duration = float('$DURATION')
for i in range(10):
    t = duration * (0.05 + 0.1 * i)
    ts = f'{int(t//60):02d}m{int(t%60):02d}s'
    subprocess.run([
        'ffmpeg', '-ss', str(t), '-i', '/work/video.mp4',
        '-frames:v', '1', '-q:v', '2',
        f'/out/sample_{i+1:02d}_{ts}.png'
    ], capture_output=True)
print('Extracted 10 sample frames')
\""

if [ "$SAMPLE_ONLY" = "true" ]; then
  echo '{"stage": "samples", "sample_count": 10, "duration": '"$DURATION"'}'
  exit 0
fi

# Full scene detection with pyscenedetect
echo "Running scene detection (threshold=$THRESHOLD)..." >&2
docker run --rm \
  -v "$WORK_DIR:/work:ro" \
  -v "$OUTPUT_DIR/keyframes:/out" \
  learn-from-video:light \
  -c "python3 << 'PYEOF'
import json
from scenedetect import open_video, SceneManager
from scenedetect.detectors import ContentDetector
from PIL import Image
import imagehash
import os
import subprocess

video = open_video('/work/video.mp4')
scene_manager = SceneManager()
scene_manager.add_detector(ContentDetector(threshold=float('$THRESHOLD')))
scene_manager.detect_scenes(video)

scenes = scene_manager.get_scene_list()
keyframes = []
prev_hash = None

for i, (start, end) in enumerate(scenes):
    t = start.get_seconds()
    ts = f'{int(t//60):02d}m{int(t%60):02d}s'
    fname = f'frame_{i+1:03d}_{ts}.png'
    outpath = f'/out/{fname}'

    # Extract frame at scene start
    subprocess.run([
        'ffmpeg', '-ss', str(t), '-i', '/work/video.mp4',
        '-frames:v', '1', '-q:v', '2', outpath
    ], capture_output=True)

    if not os.path.exists(outpath):
        continue

    # Dedup via perceptual hash (Hamming distance <= 3)
    img = Image.open(outpath)
    h = imagehash.phash(img)
    if prev_hash is not None and (h - prev_hash) <= 3:
        os.remove(outpath)
        continue

    prev_hash = h
    keyframes.append({'timestamp': round(t, 2), 'file': fname})

with open('/out/keyframes.json', 'w') as f:
    json.dump(keyframes, f, indent=2)

print(f'Extracted {len(keyframes)} keyframes from {len(scenes)} scenes')
PYEOF
" || { echo '{"error": "Scene detection failed"}' >&2; exit 2; }

# Move keyframes.json from keyframes/ to output dir root
if [ -f "$OUTPUT_DIR/keyframes/keyframes.json" ]; then
  mv "$OUTPUT_DIR/keyframes/keyframes.json" "$OUTPUT_DIR/keyframes.json"
fi

# Also try to extract subtitles from the video file (for local files with embedded subs)
echo "Checking for embedded subtitles..." >&2
docker run --rm \
  -v "$WORK_DIR:/work:ro" \
  -v "$OUTPUT_DIR:/out" \
  learn-from-video:light \
  -c "ffmpeg -i /work/video.mp4 -map 0:s:0 /out/embedded_subs.srt 2>/dev/null && echo 'Found embedded subtitles' || echo 'No embedded subtitles'" >&2

# Try yt-dlp auto-subs for URLs
if [ "$IS_LOCAL" = "false" ]; then
  echo "Checking for auto-subtitles via yt-dlp..." >&2
  docker run --rm \
    -v "$OUTPUT_DIR:/out" \
    learn-from-video:light \
    -c "yt-dlp --write-auto-sub --sub-lang en --skip-download \
        --sub-format vtt -o '/out/autosub' '$INPUT' 2>/dev/null \
        && echo 'Found auto-subtitles' || echo 'No auto-subtitles'" >&2
fi

KEYFRAME_COUNT=$(docker run --rm -v "$OUTPUT_DIR:/data:ro" learn-from-video:light -c \
  "python3 -c \"import json; print(len(json.load(open('/data/keyframes.json'))))\"" 2>/dev/null || echo "0")

cat <<EOF
{"stage": "complete", "keyframe_count": $KEYFRAME_COUNT, "duration": $DURATION, "has_embedded_subs": $([ -f "$OUTPUT_DIR/embedded_subs.srt" ] && echo "true" || echo "false"), "has_auto_subs": $([ -f "$OUTPUT_DIR/autosub.en.vtt" ] && echo "true" || echo "false")}
EOF
