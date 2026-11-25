#!/usr/bin/env bash
set -euo pipefail
target="${1:?usage: switch-bluegreen.sh <blue|green>}"
cd "$(dirname "$0")/../bluegreen"
sed -i -E "s/server (blue|green):5004;/server ${target}:5004;/" conf.d/app.conf
docker compose exec -T nginx nginx -t < /dev/null
docker compose exec -T nginx nginx -s reload < /dev/null
echo "nginx now sends all traffic to: ${target}"
