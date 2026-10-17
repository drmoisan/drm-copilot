# CI coverage headlines for the full run of the branch head (re-audit input for B-1 to B-4)

Timestamp: 2026-10-17T01-21
Command: gh run view 38988542731 --repo drmoisan/drm-copilot --json jobs; gh run view --repo drmoisan/drm-copilot --job <id> --log for jobs 117268802152, 117265576321, 117265576262
EXIT_CODE: 0
Output Summary: run 38988542731 (workflow_dispatch, head 0f0d95c2d) ran every heavy job in full; 22 of 23 jobs succeeded; security-scan failed on 101 pre-existing safety findings (remediation cycle 1). PowerShell merged line coverage 92.15%; Python TOTAL 93% with the threshold step passing; Bash line coverage 95.2% meeting the new 85% minimum.

- `poshqc / PowerShell QC` (job 117268802152, success): "Shard completeness verified: 3 shards, 402 test files, shard tests 3755 + 3894 + 3480 = discovery 11129." and "Merged PowerShell line coverage: 17499 of 18990 lines (92.15%), 1491 missed."
- `quality-checks7 / Code Quality & Tests (3.13)` (job 117265576321, success): "TOTAL 17731 1070 6398 475 93%", "7278 passed, 6 skipped", step `Enforce Python coverage thresholds` succeeded.
- `shell-coverage / Shell Coverage (Bats + kcov)` (job 117265576262, success): TAP plan "1..733", "Bash coverage (lines): 95.2%", "Bash coverage 95.2% meets the minimum line coverage of 85%."
- `security-scan / Security Scanning` (job 117265576360, failure): see `evidence/regression-testing/ci-security-scan.2026-10-17T01-18.md`.
