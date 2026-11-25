#!/usr/bin/env bash
set -euo pipefail
url="${1:?usage: count-versions.sh <url> [requests]}"
total="${2:-100}"
v1=0
v2=0
errors=0
for _ in $(seq 1 "$total"); do
  body="$(curl -s --max-time 5 "$url" || true)"
  case "$body" in
    *'"version":"v1"'*) v1=$((v1 + 1)) ;;
    *'"version":"v2"'*) v2=$((v2 + 1)) ;;
    *) errors=$((errors + 1)) ;;
  esac
done
echo "requests: $total"
echo "v1: $v1"
echo "v2: $v2"
echo "errors: $errors"
