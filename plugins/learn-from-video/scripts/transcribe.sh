#!/usr/bin/env bash
set -euo pipefail

# Transcribe video/audio using Whisper inside Docker full container
# Usage: transcribe.sh <video-or-audio-path> <output-dir> [--device cuda|cpu|auto] [--model <model>]
# Exit codes: 0=success, 1=transcription failed, 2=Docker unavailable, 3=full image unavailable

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

INPUT="$1"
OUTPUT_DIR="$2"
shift 2

DEVICE="auto"
MODEL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) DEVICE="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    *) shift ;;
  esac
done

mkdir -p "$OUTPUT_DIR"

# Check Docker
if ! docker info &>/dev/null; then
  echo '{"error": "Docker is not available"}' >&2
  exit 2
fi

# Build full image if needed
if ! docker image inspect learn-from-video:full &>/dev/null; then
  echo "Building learn-from-video:full image (this may take several minutes)..." >&2
  docker build -t learn-from-video:full -f "$PLUGIN_DIR/docker/Dockerfile.full" "$PLUGIN_DIR/docker" >&2 || {
    echo '{"error": "Failed to build full image"}' >&2
    exit 3
  }
fi

# Detect GPU if auto
GPU_FLAG=""
if [ "$DEVICE" = "auto" ]; then
  if docker info 2>/dev/null | grep -q "nvidia" && docker run --rm --gpus all learn-from-video:full -c "python3 -c 'import torch; assert torch.cuda.is_available()'" &>/dev/null 2>&1; then
    DEVICE="cuda"
    GPU_FLAG="--gpus all"
  else
    DEVICE="cpu"
  fi
elif [ "$DEVICE" = "cuda" ]; then
  GPU_FLAG="--gpus all"
fi

# Select model based on device and available VRAM if not specified
if [ -z "$MODEL" ]; then
  if [ "$DEVICE" = "cuda" ]; then
    # Auto-select based on VRAM: large-v3 ~10GB, medium ~5GB, small ~2GB, base ~1GB
    VRAM_MB=$(docker run --rm --gpus all learn-from-video:full -c \
      "python3 -c 'import torch; print(torch.cuda.get_device_properties(0).total_memory // 1048576)'" 2>/dev/null || echo "0")
    if [ "$VRAM_MB" -ge 10240 ]; then
      MODEL="large-v3"
    elif [ "$VRAM_MB" -ge 5120 ]; then
      MODEL="medium"
    elif [ "$VRAM_MB" -ge 2048 ]; then
      MODEL="small"
    else
      MODEL="base"
    fi
    echo "Detected ${VRAM_MB}MB VRAM, selected model: $MODEL" >&2
  else
    MODEL="medium"
  fi
fi

echo "Transcribing with whisper (model=$MODEL, device=$DEVICE)..." >&2

INPUT_REALPATH="$(realpath "$INPUT")"
INPUT_DIR="$(dirname "$INPUT_REALPATH")"
INPUT_FILE="$(basename "$INPUT_REALPATH")"

# Progress file for long-running transcriptions (Claude polls this)
PROGRESS_FILE="$OUTPUT_DIR/transcribe_progress.json"
echo '{"status": "starting", "percent": 0}' > "$PROGRESS_FILE"

# Run whisper inside Docker in background, write progress to mounted file
CONTAINER_NAME="lfv-whisper-$$-$(date +%s)"
docker run --rm --name "$CONTAINER_NAME" ${GPU_FLAG:+$GPU_FLAG} \
  -v "$INPUT_DIR:/input:ro" \
  -v "$OUTPUT_DIR:/output" \
  learn-from-video:full \
  -c "
    echo '{\"status\": \"extracting_audio\", \"percent\": 5}' > /output/transcribe_progress.json

    # Extract audio if video
    ffmpeg -i '/input/$INPUT_FILE' -ar 16000 -ac 1 -y /tmp/audio.wav 2>/dev/null

    echo '{\"status\": \"transcribing\", \"percent\": 10}' > /output/transcribe_progress.json

    # Run whisper with verbose output to track progress
    whisper /tmp/audio.wav \
      --model '$MODEL' \
      --device '$DEVICE' \
      --output_dir /output \
      --output_format json \
      --language en \
      2>&1 | while IFS= read -r line; do
        # Whisper prints progress like '[00:30.000 --> 00:35.000]' — extract percentage
        if echo \"\$line\" | grep -qP '^\['; then
          echo '{\"status\": \"transcribing\", \"percent\": 50, \"detail\": \"'\"\$line\"'\"}' > /output/transcribe_progress.json
        fi
      done

    echo '{\"status\": \"converting\", \"percent\": 90}' > /output/transcribe_progress.json

    # Convert whisper JSON to unified format
    python3 -c \"
import json, sys
with open('/output/audio.json') as f:
    data = json.load(f)
segments = [{'start': round(s['start'], 2), 'end': round(s['end'], 2), 'text': s['text'].strip()} for s in data.get('segments', [])]
unified = {'source': 'whisper', 'language': data.get('language', 'en'), 'segments': segments}
with open('/output/transcript.json', 'w') as f:
    json.dump(unified, f, indent=2)
print(json.dumps({'status': 'ok', 'segments': len(segments), 'model': '$MODEL', 'device': '$DEVICE'}))
\"

    echo '{\"status\": \"complete\", \"percent\": 100}' > /output/transcribe_progress.json
  " &

DOCKER_PID=$!

# Poll progress — allows Claude to call this script with run_in_background
# and check $PROGRESS_FILE, or wait synchronously for short videos
set +e
wait $DOCKER_PID
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -ne 0 ]; then
  echo '{"status": "failed", "percent": 0}' > "$PROGRESS_FILE"
  echo '{"error": "Transcription failed"}' >&2
  exit 1
fi

# Verify transcript was produced
if [ ! -f "$OUTPUT_DIR/transcript.json" ]; then
  echo '{"error": "Transcription produced no output"}' >&2
  exit 1
fi

# Clean up intermediate whisper files and progress file
rm -f "$OUTPUT_DIR/audio.json" "$OUTPUT_DIR/audio.txt" "$OUTPUT_DIR/audio.vtt" \
      "$OUTPUT_DIR/audio.srt" "$OUTPUT_DIR/audio.tsv" "$PROGRESS_FILE" 2>/dev/null

exit 0
