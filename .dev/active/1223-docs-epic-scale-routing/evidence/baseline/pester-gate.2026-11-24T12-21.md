# Phase 0 baseline: parallel Pester gate (P0-T2)

Timestamp: 2026-11-24T12-21
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, 8 workers, full suite, integration and golden lanes excluded by the launcher), on the unedited tree
EXIT_CODE: 0
Output Summary:
- `Invoke-PoshQCParallelTest: workers=8; wall-clock=801.55s; exit code=0`. The machine test-suite lock was held by another worktree for several launcher attempts (exit 75, queue timeout, not a failure); the run recorded here is the first attempt that acquired the lock.
- Merged `artifacts/pester/pester-junit.xml`: `testsuites tests="29936" errors="0" failures="0" disabled="22"`; `<testcase>` elements 29932, `<skipped>` elements 18, `<failure>` elements 0. Passing testcase elements: 29914 (29932 less 18 skipped). The 18 skipped testcases and 22 disabled count are pre-existing and are the comparison base for the final gate.
- Coverage: no production .ps1 file changed by this feature, so no per-file coverage comparison applies.
