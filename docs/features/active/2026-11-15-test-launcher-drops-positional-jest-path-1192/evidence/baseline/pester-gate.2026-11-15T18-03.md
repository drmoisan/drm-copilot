# Phase 0 baseline, Pester gate (P0-T2)

Timestamp: 2026-11-15T18-03
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (launcher `pester` suite, one `Invoke-PoshQCParallelTest` run, integration and golden lanes excluded), run through `sh SCRATCH/issue-1192-run.sh` from the worktree root; coverage and counts read by `SCRATCH/issue-1192-report.ps1` from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`.
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8, wall-clock 750.42 s, exit code 0.
- Pass and fail counts (merged JUnit): tests 26852, failures 0, errors 0, disabled 22. Passed = 26852 - 22 disabled = 26830.
- Repo-wide line coverage: 96.01 percent (44275 of 46114 lines).
- `.claude/hooks/test-execution-policy.ps1` line coverage: 100.00 percent (170 of 170); the `.codex/hooks` copy is also 170 of 170.
- Queue note: the first attempts exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT, lock held by a sibling worktree's pester suite); the gate was re-run after the holder finished. Those are queue timeouts, not failures.
- Jest and Python baselines are not applicable: the only TypeScript change is a comment and no Python is touched.
