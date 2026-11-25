#!/usr/bin/env bash
set -uo pipefail
url="${1:?usage: request-stream.sh <url> [requests] [interval_seconds]}"
total="${2:-40}"
interval="${3:-0.25}"
body="$(mktemp)"
trap 'rm -f "$body"' EXIT
for i in $(seq 1 "$total"); do
  : > "$body"
  code="$(curl -s --max-time 3 -o "$body" -w '%{http_code}' "$url")"
  version="$(grep -o '"version":"[^"]*"' "$body" | cut -d'"' -f4)"
  printf '%s  request %02d  HTTP %s  version %s\n' "$(date +%H:%M:%S.%3N)" "$i" "$code" "${version:--}"
  sleep "$interval"
done
