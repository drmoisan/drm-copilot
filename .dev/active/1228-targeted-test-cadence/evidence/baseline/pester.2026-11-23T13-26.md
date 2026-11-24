# Phase 0 Baseline - Pester Gate - Issue #1228 ([P0-T3])

Timestamp: 2026-11-23T13-26
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (absolute launcher path of the item worktree, through SCRATCH/issue-1228-suite.sh, which retries on exit 75); one `Invoke-PoshQCParallelTest` run with coverage, no `-TestPath`
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=707.83s; exit code=0; all 8 shards exited 0; merged JUnit and coverage written under `artifacts/pester/` (JUnit LastWriteTimeUtc 2026-11-23T13:25:53Z).
- Pass/fail from `artifacts/pester/pester-junit.xml`: 29157 tests in 863 test suites; 0 failures; 0 errors; 18 skipped; passed 29139.
- Repo-wide line coverage from `artifacts/pester/powershell-coverage.xml` (LINE counter): 47285 covered, 1542 missed = 96.84%.
- In-scope production files: none (the plan changes Markdown, TOML, and two Pester test files only), so no per-file production figure applies.
- Queue timeouts (not failures): the first launcher call (2026-11-23T13-05) and attempts 1 to 4 (2026-11-23T13-07 to 2026-11-23T13-13) exited 75 with TEST_EXECUTION_QUEUE_TIMEOUT while the machine lock was held by a Pester suite of another worktree and then by a pytest suite of another repository; attempt 5 started 2026-11-23T13-13-58 and ended 2026-11-23T13-25-53 with exit 0.
- Report copies kept as SCRATCH/issue-1228-pester-p0-junit.xml and SCRATCH/issue-1228-pester-p0-coverage.xml for the final comparison.
