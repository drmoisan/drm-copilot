# CI duration baseline (#1048)

Timestamp: 2026-10-31T18-13
Command: gh run list --workflow ci.yml --branch main --limit 15 --json databaseId,conclusion,event,headSha,createdAt,status; gh run view 41209645365 --json jobs (durations computed from startedAt and completedAt by SCRATCH/issue-1048-ci-jobs.py)
EXIT_CODE: 0
Output Summary:
- Run: 41209645365 (`ci.yml`, push to `main`, created 2026-10-31T14:20:09Z), the newest `main` run; its `CI full run` job concluded `success` (3 s), so it is a full run.
- The run's overall conclusion is `failure` only because `NPM Audit Gate / npm audit (extensions/drm-copilot)` and `NPM Audit Gate / npm audit (.)` failed (the glob and minimatch advisories recorded in a separate promoted item); every job measured below concluded `success`.
- `quality-checks7 / Code Quality & Tests (3.13)`: 862 s.
- `poshqc / PowerShell QC static`: 212 s.
- `poshqc / PowerShell QC shard 1`: 639 s.
- `poshqc / PowerShell QC shard 2`: 268 s.
- `poshqc / PowerShell QC shard 3`: 381 s.
- `poshqc / PowerShell hook suites (Linux)`: 377 s.
- `poshqc / PowerShell QC` (aggregator): 69 s.
- Shard spread (longest minus shortest shard): 639 - 268 = 371 s.
