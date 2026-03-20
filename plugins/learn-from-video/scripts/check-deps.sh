#!/usr/bin/env bash
set -euo pipefail

# Check Docker availability and GPU/disk/image status
# Exit codes: 0=all deps met, 1=Docker missing, 2=insufficient disk
# Stdout: JSON status report

check_docker() {
  if ! command -v docker &>/dev/null; then
    echo "false"
    return
  fi
  if ! docker info &>/dev/null; then
    echo "false"
    return
  fi
  echo "true"
}

check_nvidia_runtime() {
  # Check if nvidia runtime is registered in Docker
  local runtime_check
  runtime_check=$(docker info 2>/dev/null | grep -c "nvidia" || true)
  if [ "$runtime_check" -gt 0 ]; then
    echo "true"
  else
    echo "false"
  fi
}

check_disk_free() {
  df -BG --output=avail "$HOME" 2>/dev/null | tail -1 | tr -d ' G'
}

check_image_exists() {
  local image="$1"
  if docker image inspect "$image" &>/dev/null; then
    echo "true"
  else
    echo "false"
  fi
}

# Main
DOCKER_OK=$(check_docker)

if [ "$DOCKER_OK" = "false" ]; then
  cat <<EOF
{"docker": false, "nvidia_runtime": false, "disk_free_gb": 0, "light_image": false, "full_image": false, "error": "Docker is not installed or not running"}
EOF
  exit 1
fi

NVIDIA_OK=$(check_nvidia_runtime)
DISK_FREE=$(check_disk_free)
LIGHT_OK=$(check_image_exists "learn-from-video:light")
FULL_OK=$(check_image_exists "learn-from-video:full")

# Check minimum disk space
MIN_DISK=5
if [ "$LIGHT_OK" = "false" ] && [ "$FULL_OK" = "false" ]; then
  MIN_DISK=15
fi

if [ "$DISK_FREE" -lt "$MIN_DISK" ]; then
  cat <<EOF
{"docker": true, "nvidia_runtime": $NVIDIA_OK, "disk_free_gb": $DISK_FREE, "light_image": $LIGHT_OK, "full_image": $FULL_OK, "error": "Insufficient disk space: ${DISK_FREE}GB free, need ${MIN_DISK}GB"}
EOF
  exit 2
fi

cat <<EOF
{"docker": true, "nvidia_runtime": $NVIDIA_OK, "disk_free_gb": $DISK_FREE, "light_image": $LIGHT_OK, "full_image": $FULL_OK}
EOF
exit 0
