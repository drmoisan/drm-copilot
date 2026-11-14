# CI timing with -n auto (P9-T1)

- Run: `ci.yml` run 41243409383 on PR #1053, head `6e5a0c249da783a3c4fba52bdcb4201f6e1af76f` (the final branch head).
- Job: `quality-checks7 / Code Quality & Tests (3.13)` (job 124661860550): 492 s, success.
- xdist worker count read from that job's log: `created: 4/4 workers` and `4 workers [16066 items]` (pytest-xdist 3.8.0).
- Pytest step `Run tests with Pytest`: success, 389 s; log line `16060 passed, 6 skipped in 385.25s`.
- Steps `Verify poetry.lock is in sync` and `Enforce Python coverage thresholds`: success.
- Other matrix legs on the same run: 3.10 527 s, 3.11 606 s, 3.12 498 s, all success. The baseline recorded only the 3.13 leg, so no before and after is claimed for the others.
- Pester shards on the same run: shard 1 417 s, shard 2 497 s, shard 3 372 s; `PowerShell QC static` 220 s; `PowerShell hook suites (Linux)` 351 s; aggregate `poshqc / PowerShell QC` 84 s. All success.
- Baseline (`evidence/baseline/ci-durations.2026-10-31T18-13.md`, main run 41209645365): 3.13 leg 862 s. After: 492 s, a reduction of 370 s (43%).
- Observation: the log shows an upload error line from Codecov (token required for a tokenless upload); the step concluded success and is not related to this change.
