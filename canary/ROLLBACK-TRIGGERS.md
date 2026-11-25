# Canary rollback triggers

These triggers were written down before the trigger test was run. They are checked by
`scripts/canary-check.sh` over 100 requests to the public endpoint.

| Metric | Rollback trigger | Why |
|---|---|---|
| Error rate (responses that are not HTTP 200) | more than 1% | A healthy release returned 0 errors in every earlier measurement |
| Average response time | more than 200 ms | Healthy measurements were below 10 ms, so 200 ms means something is badly wrong |

If either trigger is breached, the script sets the weights to v1 = 1, v2 = 0 and reloads nginx,
so all traffic returns to the stable version. If no trigger is breached, the rollout may continue
to the next step (10% -> 30% -> ...).
