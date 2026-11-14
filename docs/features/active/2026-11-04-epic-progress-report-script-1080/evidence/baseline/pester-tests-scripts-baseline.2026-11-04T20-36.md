# Pester Baseline: tests/scripts (Issue #1080, P0-T4)

Timestamp: 2026-11-04T20-36
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p0t4.log -1 tests/scripts (SCRATCH/issue-1080-run-pester.ps1 in one fresh PowerShell 7 process from the worktree root; coverage and JUnit disabled, PassThru enabled, no shuffle)
EXIT_CODE: 0

## Result

TOTAL Tests=14298 Passed=14288 Failed=0 Skipped=10 NotRun=0

- FILE lines: 507 containers.
- FILE lines with failed above 0: none.
- CONTAINER-ERROR lines: none.
- TEST (failure) lines: 0.

## Reference profile for P2-T8 and P2-T9

The per-container failure profile at the branch head before any code change is empty: every one of the 507 containers reports `failed=0`. P2-T8 and P2-T9 compare against this profile (any failing container other than the two new suites must have a count no greater than here, which is 0).

Output Summary: tests/scripts single-process baseline at the branch head: 14298 tests, 14288 passed, 0 failed, 10 skipped, 507 containers, no failing container. The worktree was clean after the run.
