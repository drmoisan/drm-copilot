# Isolation: Fresh Single-Process Run over tests/scripts (Issue #1080, remediation cycle 3, P2-T7)

Timestamp: 2026-11-06T13-31
Task: P2-T7
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r3-p2t7.log -1 tests/scripts (one fresh PowerShell 7 process from the worktree root; coverage and JUnit disabled, PassThru enabled, no shuffle; run in the background)
EXIT_CODE: 0
Output Summary: tests/scripts single-process run: 14404 tests, 14394 passed, 0 failed, 10 skipped, 509 containers, no failing container; both change-set suites and FileSizePolicy.RepoGate.Tests.ps1 failed=0; failure profile empty, matching the 12-26 reference.

## Result

TOTAL Tests=14404 Passed=14394 Failed=0 Skipped=10 NotRun=0

- FILE lines: 509 containers.
- FILE lines with failed above 0: none.
- CONTAINER-ERROR lines: none.
- TEST (failure) lines: 0.

Required containers:

- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=74 failed=0
- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=32 failed=0
- FILE tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 tests=5 failed=0

## Comparison with the P0-T2 reference

The P0-T2 reference `evidence/regression-testing/isolation-fresh-tests-scripts.2026-11-06T12-26.md` recorded 14397 tests over 509 containers with an empty failure profile. This run has 14404 tests (+7, the seven tests added to the Logic suite in this cycle, which moved from 67 to 74) over the same 509 containers, and its failure profile is also empty, so no container has more failures than the reference. `git status --porcelain` printed nothing after the run.
