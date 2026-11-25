#!/usr/bin/env bash
set -euo pipefail
url="${1:?usage: count-versions.sh <url> [requests]}"
total="${2:-100}"
v1=0
v2=0
errors=0
total_ms=0
body="$(mktemp)"
trap 'rm -f "$body"' EXIT
for _ in $(seq 1 "$total"); do
  : > "$body"
  seconds="$(curl -s --max-time 5 -o "$body" -w '%{time_total}' "$url" || echo 0)"
  total_ms=$(( total_ms + $(awk -v s="$seconds" 'BEGIN { printf "%d", s * 1000000 }') ))
  if grep -q '"version":"v1"' "$body"; then
    v1=$((v1 + 1))
  elif grep -q '"version":"v2"' "$body"; then
    v2=$((v2 + 1))
  else
    errors=$((errors + 1))
  fi
done
echo "requests: $total"
echo "v1: $v1"
echo "v2: $v2"
echo "errors: $errors"
awk -v us="$total_ms" -v n="$total" 'BEGIN { printf "average response time: %.1f ms\n", us / n / 1000 }'
