Timestamp: 2026-11-15T19-10
Command: gh run view 43749104502 --json conclusion,headSha,jobs (per-job startedAt and completedAt)
EXIT_CODE: 0
Output Summary: workflow_dispatch run 43749104502 of ci.yml on branch head 26217c890 (regenerated shard weights) concluded success; every job succeeded, including CI Required Gate. Durations are computed from the recorded job startedAt and completedAt values. This file is a second measurement; ci-measurement.2026-11-15T17-20.md is unchanged.

Run: https://github.com/drmoisan/drm-copilot/actions/runs/43749104502

## PowerShell shards after weights regeneration (six shards)

| Job | Run 43749104502 | Run 43736520255 (before) |
|---|---|---|
| PowerShell QC shard 1 | 12.7 min | 7.4 min |
| PowerShell QC shard 2 | 10.2 min | 13.6 min |
| PowerShell QC shard 3 | 10.0 min | 10.9 min |
| PowerShell QC shard 4 | 8.4 min | 12.5 min |
| PowerShell QC shard 5 | 9.9 min | 9.1 min |
| PowerShell QC shard 6 | 10.4 min | 9.9 min |
| PowerShell QC static | 6.2 min | 4.7 min |
| PowerShell hook suites (Linux) | 11.4 min | 8.9 min |
| PowerShell QC aggregator | 1.8 min | 1.8 min |

Longest shard: 12.7 min (before 13.6; baseline longest 16.9). Spread: 8.4 to 12.7 min, narrower than 7.4 to 13.6 but not yet within 20 percent. Shard 1 now holds the longest time, so one regeneration moved the imbalance rather than removing it; the residual spread is recorded here and the criterion text is unchanged.

## Python 3.13

| Job | Run 43749104502 |
|---|---|
| Python 3.13 static | 2.5 min |
| Python 3.13 coverage shard 1 | 5.6 min |
| Python 3.13 coverage shard 2 | 8.4 min |
| Code Quality & Tests (3.13) combine | 2.1 min |

Python 3.13 path (start to combine end): 10.5 min against 16.4 min baseline.

## Run wall clock

Start 18:51:34Z; PowerShell aggregator ended 19:06:25Z; CI Required Gate ended 19:07:01Z. Wall clock is about 15.5 min. The critical path is PowerShell shard 1 (12.7 min) plus the aggregator, with runner start-up variance between runs of about 1 to 3 min.

## Runner-queue trade-off

Unchanged from the earlier measurement: the run uses 6 windows-latest PowerShell shards (up from 3) and 2 Python coverage shards plus a combine job, with queue waits of 0 to a few seconds at this load. Total billed minutes rise with the repeated per-shard setup and the new aggregator and combine jobs.
