#!/usr/bin/env bash
set -euo pipefail
url="${1:-http://localhost:8087/}"
total="${2:-100}"
max_error_percent="${MAX_ERROR_PERCENT:-1}"
max_avg_ms="${MAX_AVG_MS:-200}"
ok=0
failed=0
v1=0
v2=0
total_us=0
body="$(mktemp)"
trap 'rm -f "$body"' EXIT
for _ in $(seq 1 "$total"); do
  : > "$body"
  read -r code seconds < <(curl -s --max-time 5 -o "$body" -w '%{http_code} %{time_total}\n' "$url" || echo "000 0")
  total_us=$(( total_us + $(awk -v s="$seconds" 'BEGIN { printf "%d", s * 1000000 }') ))
  if [ "$code" = "200" ]; then ok=$((ok + 1)); else failed=$((failed + 1)); fi
  if grep -q '"version":"v1"' "$body"; then
    v1=$((v1 + 1))
  elif grep -q '"version":"v2"' "$body"; then
    v2=$((v2 + 1))
  fi
done
error_percent="$(awk -v f="$failed" -v n="$total" 'BEGIN { printf "%.1f", f * 100 / n }')"
avg_ms="$(awk -v us="$total_us" -v n="$total" 'BEGIN { printf "%.1f", us / n / 1000 }')"
echo "requests: $total | answered by v1: $v1 | answered by v2: $v2"
echo "HTTP 200: $ok | failed: $failed | error rate: ${error_percent}% (trigger: more than ${max_error_percent}%)"
echo "average response time: ${avg_ms} ms (trigger: more than ${max_avg_ms} ms)"
breached="$(awk -v e="$error_percent" -v me="$max_error_percent" -v a="$avg_ms" -v ma="$max_avg_ms" 'BEGIN { print (e > me || a > ma) ? "yes" : "no" }')"
if [ "$breached" = "yes" ]; then
  echo "DECISION: ROLLBACK - a rollback trigger was breached"
  "$(dirname "$0")/set-canary-weights.sh" 1 0
  exit 1
fi
echo "DECISION: CONTINUE - no rollback trigger breached"
