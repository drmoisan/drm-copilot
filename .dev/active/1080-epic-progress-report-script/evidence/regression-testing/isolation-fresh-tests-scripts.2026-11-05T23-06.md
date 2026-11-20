# Isolation: Fresh Single-Process Run over tests/scripts (Issue #1080, P2-T8)

Timestamp: 2026-11-05T23-06
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p2t8.log -1 tests/scripts (SCRATCH/issue-1080-run-pester.ps1 in one fresh PowerShell 7 process from the worktree root; coverage and JUnit disabled, PassThru enabled, no shuffle)
EXIT_CODE: 0

## Host

This run executed on a Windows 11 host with PowerShell 7.6.9. The P0-T4 reference ran on the Linux Codespace before the work moved. The run script was recreated in SCRATCH from the plan's run-script contract, because the earlier SCRATCH copy did not survive the move. The branch head includes the merge of origin/main.

## Result

TOTAL Tests=14387 Passed=14377 Failed=0 Skipped=10 NotRun=0

- FILE lines: 509 containers (P0-T4: 507; the difference is the two new suites).
- FILE lines with failed above 0: none.
- CONTAINER-ERROR lines: none.
- TEST (failure) lines: 0.

Required containers:

- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=60 failed=0
- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=29 failed=0
- FILE tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 tests=5 failed=0

## Comparison with P0-T4

The P0-T4 per-container failure profile is empty. This run is also empty, so no container has more failures than in P0-T4. No host-specific failure was observed. The worktree was clean after the run (`git status --porcelain` printed nothing).

Output Summary: tests/scripts single-process run on the Windows host: 14387 tests, 14377 passed, 0 failed, 10 skipped, 509 containers, no failing container; both new suites and FileSizePolicy.RepoGate.Tests.ps1 failed=0 (AC1).
