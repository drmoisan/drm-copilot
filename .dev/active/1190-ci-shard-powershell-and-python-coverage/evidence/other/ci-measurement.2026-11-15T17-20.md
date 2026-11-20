Timestamp: 2026-11-15T17-20
Command: gh run view 43736520255 --json conclusion,jobs (per-job startedAt and completedAt)
EXIT_CODE: 0
Output Summary: workflow_dispatch run 43736520255 of ci.yml on branch head 5e8085e4b concluded success; every job succeeded, including CI Required Gate. Durations below are computed from the recorded job startedAt and completedAt values.

Run: https://github.com/drmoisan/drm-copilot/actions/runs/43736520255

## PowerShell (windows-latest shards)

| Job | Duration | Baseline (3 shards) |
|---|---|---|
| PowerShell QC shard 1 | 7.4 min (starts 29 s after the others) | 13.3 / 16.7 / 16.9 min |
| PowerShell QC shard 2 | 13.6 min | |
| PowerShell QC shard 3 | 10.9 min | |
| PowerShell QC shard 4 | 12.5 min | |
| PowerShell QC shard 5 | 9.1 min | |
| PowerShell QC shard 6 | 9.9 min | |
| PowerShell QC static | 4.7 min | |
| PowerShell hook suites (Linux) | 8.9 min | |
| PowerShell QC (aggregator: completeness + coverage merge) | 1.8 min, starts after the slowest shard | |

Longest shard: 13.6 min against a baseline longest of 16.9 min. Spread between shards is 7.4 to 13.6 min.

## Python 3.13

| Job | Duration | Baseline |
|---|---|---|
| Python 3.13 static | 1.9 min | 16.4 min total job, pytest with coverage 13.6 min |
| Python 3.13 coverage shard 1 | 6.0 min | |
| Python 3.13 coverage shard 2 | 9.4 min | |
| Code Quality & Tests (3.13) combine job | 1.8 min | |

Python 3.13 critical path (start to combine end): 11.3 min against 16.4 min. The combine job kept the required context name `quality-checks7 / Code Quality & Tests (3.13)`, and the first-run risks (COVERAGE_FILE under xdist, hidden-file upload, combine path match, Linux module loading of PoshQC.Shard.psm1) all passed.

## Run wall clock

Run start 16:37:49Z; PowerShell aggregator ended 16:53:16Z; CI Required Gate ended 16:53:33Z. Wall clock is about 15.7 min. The critical path is now the PowerShell shard 2 (13.6 min) plus the aggregator (1.8 min).

## Runner-queue trade-off

The run uses 6 windows-latest PowerShell shards (up from 3) and 2 Python coverage shards plus a combine job (up from 1 job), which is 9 more concurrent runner jobs per full run and about 2 extra runner start-ups per leg. Queue wait was 0 to 3 s in this run (shard 1 started 29 s late), so no queue delay appears at this load. Total billed minutes rise because each shard repeats setup and the aggregator and combine jobs are new. Under concurrent PRs the queue could lengthen the wall clock, since the required legs now need more simultaneous runners.

## Shard balance

Shards are balanced by test-file byte size, not by time. Measured spread (7.4 to 13.6 min) exceeds the 20 percent threshold stated in the plan, so the weights file `config/poshqc-shard-weights.json` is the tuning point; this is recorded for the review to classify.
