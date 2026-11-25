#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
backup="disaster-recovery/backups/record.txt"
pod="lab4-dr-pod"
start="$(date +%s%3N)"
kubectl cp "$backup" "${pod}:/data/record.txt" < /dev/null
end="$(date +%s%3N)"
echo "restore took: $(( end - start )) ms"
local_sum="$(sha256sum "$backup" | awk '{print $1}')"
pod_sum="$(kubectl exec "$pod" -- sha256sum /data/record.txt < /dev/null | awk '{print $1}')"
echo "backup   sha256: $local_sum"
echo "restored sha256: $pod_sum"
if [ "$local_sum" = "$pod_sum" ]; then echo "checksums match"; else echo "CHECKSUM MISMATCH"; exit 1; fi
