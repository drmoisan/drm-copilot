# Pester Baseline: tests/scripts/dev-tools (Issue #1080, P0-T3)

Timestamp: 2026-11-04T20-24
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p0t3.log -1 tests/scripts/dev-tools (runs SCRATCH/issue-1080-run-pester.ps1 in one fresh PowerShell 7 process from the worktree root; coverage and JUnit disabled, PassThru enabled, no shuffle)
EXIT_CODE: 0

## Run script

`SCRATCH/issue-1080-run-pester.ps1` follows the plan's run-script contract: it discovers `*.Tests.ps1` under each given path (ordinal FullName order), optionally applies a `[System.Random]` Fisher-Yates shuffle with a seed, runs Invoke-Pester once with `CodeCoverage.Enabled = $false`, `TestResult.Enabled = $false`, and `Run.PassThru = $true`, then prints the `TOTAL` line, the `SEED`/`ORDER` lines when shuffled, one `FILE <path> tests=N failed=N` line per container, and one `TEST <file> | <full name> | FAILED` line per failure. It exits 1 when Failed is above 0 (or a container errors without a failed test), otherwise 0.

## Result

TOTAL Tests=722 Passed=720 Failed=0 Skipped=2 NotRun=0

- FILE lines: 39 containers; the per-file test counts sum to 722.
- FILE lines with failed above 0: none.
- CONTAINER-ERROR lines: none.

Output Summary: tests/scripts/dev-tools baseline at the branch head (before any code change): 722 tests, 720 passed, 0 failed, 2 skipped, 39 containers, none with failures. The worktree was clean after the run.
