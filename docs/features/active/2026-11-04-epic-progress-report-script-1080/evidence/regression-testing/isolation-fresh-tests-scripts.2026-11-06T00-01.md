# Isolation: Fresh Single-Process Run over tests/scripts (Issue #1080, remediation cycle 1, P2-T7)

Timestamp: 2026-11-06T00-01
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r1-p2t7.log -1 tests/scripts (one fresh PowerShell 7 process from the worktree root; coverage and JUnit disabled, PassThru enabled, no shuffle)
EXIT_CODE: 0

## Result

TOTAL Tests=14394 Passed=14384 Failed=0 Skipped=10 NotRun=0

- FILE lines: 509 containers.
- FILE lines with failed above 0: none.
- CONTAINER-ERROR lines: none.
- TEST (failure) lines: 0.

Required containers:

- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=64 failed=0
- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=32 failed=0
- FILE tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 tests=5 failed=0

## Comparison with the earlier reference

The reference `evidence/regression-testing/isolation-fresh-tests-scripts.2026-11-05T23-06.md` recorded 14387 tests over 509 containers with an empty failure profile. This run has 14394 tests (+7, the seven tests added in this cycle) over the same 509 containers, and its failure profile is also empty, so no container has more failures than the reference. `git status --porcelain` printed nothing after the run.

Output Summary: tests/scripts single-process run: 14394 tests, 14384 passed, 0 failed, 10 skipped, 509 containers, no failing container; both change-set suites and FileSizePolicy.RepoGate.Tests.ps1 failed=0; failure profile empty, matching the 23-06 reference.
