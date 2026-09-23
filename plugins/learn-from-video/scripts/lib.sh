#!/bin/bash
# Shared helpers for learn-from-video scripts. Source it; do not execute it.

# ensure_image light|full
# Keeps learn-from-video:<flavor> current. The stamp tag holds a hash of the Dockerfile (a changed
# Dockerfile means rebuild), and for light also the ISO week, so yt-dlp is re-resolved weekly;
# YouTube breaks old yt-dlp within weeks. The plain :<flavor> tag always points at the current
# stamp, so every `docker run learn-from-video:<flavor>` picks it up.
ensure_image() {
  local flavor="$1" plugin_dir dockerfile hash stamp refresh=""
  plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  dockerfile="$plugin_dir/docker/Dockerfile.$flavor"
  hash=$(sha256sum "$dockerfile" | cut -c1-12)
  stamp="learn-from-video:$flavor-$hash"
  if [ "$flavor" = "light" ]; then
    refresh=$(date -u +%G-W%V)
    stamp="$stamp-$refresh"
  fi
  if ! docker image inspect "$stamp" &>/dev/null; then
    echo "Building $stamp ..." >&2
    docker build --build-arg "YTDLP_REFRESH=$refresh" -t "$stamp" -f "$dockerfile" "$plugin_dir/docker" >&2 || return 1
  fi
  docker tag "$stamp" "learn-from-video:$flavor"
  # Drop superseded stamps (weekly light builds are several hundred MB each).
  docker images --format '{{.Repository}}:{{.Tag}}' "learn-from-video" \
    | grep "^learn-from-video:$flavor-" | grep -vx "$stamp" \
    | xargs -r docker rmi >/dev/null 2>&1 || true
}
