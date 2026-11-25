#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
log="${1:-/tmp/failover-stream.log}"
detection_wait="${2:-5}"
stamp() { printf '%s  %s\n' "$(date +%H:%M:%S.%3N)" "$1"; }
scripts/request-stream.sh http://localhost:8086/ 90 0.25 > "$log" 2>&1 &
stream=$!
sleep 3
stamp "killing blue (simulated failure)"
docker compose -f bluegreen/compose.yaml kill blue < /dev/null
stamp "blue is down; waiting ${detection_wait}s (simulated detection time)"
sleep "$detection_wait"
stamp "switching traffic to green"
scripts/switch-bluegreen.sh green
stamp "switch finished"
wait "$stream"
scripts/outage-summary.sh "$log"
