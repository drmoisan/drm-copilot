# Pester Gate Baseline — Issue #1106

Timestamp: 2026-11-07T14-58
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <worktree>; exit $r.ExitCode (pwsh 7 via SCRATCH/issue-1106-pester.sh baseline; cwd worktree root; run started 2026-11-07T14-52 UTC, before any change)
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest: workers=8; wall-clock=324.33s; returned ExitCode 0. All 8 shards exited 0 and the merged JUnit and coverage reports were written. JUnit: 15553 tests, 0 failed, 10 skipped. Line coverage 94.01% (24046 covered, 1532 missed).

## Counts (artifacts/pester/pester-junit.xml)

- Returned ExitCode: 0
- Total: 15553
- Failed: 0 (root `failures="0" errors="0"`)
- Skipped: 10 (root `disabled="10"`)
- Failing tests: none

## Coverage (artifacts/pester/powershell-coverage.xml)

- Report-level LINE counter: covered 24046, missed 1532; total line coverage 94.01%.

## Copies

- `SCRATCH/baseline/pester-junit.xml`
- `SCRATCH/baseline/powershell-coverage.xml`
