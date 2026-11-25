#!/usr/bin/env bash
set -euo pipefail
log="${1:?usage: outage-summary.sh <request-stream log>}"
echo "runs of identical responses (count, status, version):"
awk '{print $5, $6, $7, $8}' "$log" | uniq -c
first_fail="$(grep -v 'HTTP 200' "$log" | head -n 1 | awk '{print $1}')"
if [ -z "$first_fail" ]; then
  echo "no failed requests"
  exit 0
fi
recovered="$(awk -v t="$first_fail" '$1 > t && /HTTP 200/ {print $1; exit}' "$log")"
echo "first failed request          : $first_fail"
echo "first good request afterwards : ${recovered:-none}"
if [ -n "$recovered" ]; then
  ms=$(( $(date -d "$recovered" +%s%3N) - $(date -d "$first_fail" +%s%3N) ))
  echo "measured outage               : ${ms} ms"
fi
