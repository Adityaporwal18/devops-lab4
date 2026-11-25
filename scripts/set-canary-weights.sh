#!/usr/bin/env bash
set -euo pipefail
blue="${1:?usage: set-canary-weights.sh <blue_weight> <green_weight>}"
green="${2:?usage: set-canary-weights.sh <blue_weight> <green_weight>}"
cd "$(dirname "$0")/../canary"
{
  echo "upstream application {"
  if [ "$blue" -gt 0 ]; then echo "    server blue:5004 weight=${blue};"; fi
  if [ "$green" -gt 0 ]; then echo "    server green:5004 weight=${green};"; fi
  echo "}"
  echo
  echo "server {"
  echo "    listen 80;"
  echo
  echo "    location / {"
  echo "        proxy_pass http://application;"
  echo "    }"
  echo "}"
} > conf.d/app.conf
docker compose exec -T nginx nginx -t < /dev/null
docker compose exec -T nginx nginx -s reload < /dev/null
echo "canary weights now: blue(v1)=${blue} green(v2)=${green}"
