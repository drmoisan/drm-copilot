# CI Run on the Pushed Head (P3-T5)

Timestamp: 2026-11-16T02-02
Command: git push origin bug/gate-wrapped-shell-test-commands; gh workflow run CI --ref bug/gate-wrapped-shell-test-commands; polled with gh run view 43788266034 --json status,conclusion,headSha,event and --json jobs (SCRATCH/issue-1195-ci-poll.sh, 30-second interval)
EXIT_CODE: 0
Output Summary:
- Run id: 43788266034, workflow CI, event workflow_dispatch, created 2026-11-16T01:47:02Z, completed 2026-11-16T02:01:59Z, conclusion success.
- Head commit: c1729bf54fd6cce7d3ccb86b3c9b5cd5ab45b4c5 (the pushed head of bug/gate-wrapped-shell-test-commands at dispatch).
- CI Required Gate: success.
- poshqc / PowerShell QC: success.
- poshqc / PowerShell hook suites (Linux): success.
- All 29 jobs of the run concluded success (0 failures, 0 cancelled).
- No pull request exists for the branch yet; the run is the manual dispatch the plan names.
