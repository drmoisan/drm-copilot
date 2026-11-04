# Isolation: Concurrent-Shard Run with Invoke-PoshQCParallelTest (P6-T13)

Timestamp: 2026-11-04T15-15
Command: sh SCRATCH/issue-1067-parallel.sh (pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-parallel.ps1: Import-Module scripts/powershell/PoshQC/PoshQC.psd1, then Invoke-PoshQCParallelTest -Root <worktree> -WorkerCount (Get-PoshQCParallelWorkerCount); each artifacts/pester/parallel/shard-<i>/pester-junit.xml read afterwards)
EXIT_CODE: 0
Output Summary:
- Worker count: 8 (Get-PoshQCParallelWorkerCount on 16 logical processors). Wall clock 477.25 s; Invoke-PoshQCParallelTest exit code 0; merged JUnit and coverage written.
- Shard exit codes: shard 1 = 0, shard 2 = 0, shard 3 = 0, shard 4 = 0, shard 5 = 0, shard 6 = 0, shard 7 = 0, shard 8 = 0.
- shard-1: suites=1 tests=439 failures=0 errors=0 (in-scope suites 0)
- shard-2: suites=67 tests=1525 failures=0 errors=0 (in-scope suites 4, failures 0)
- shard-3: suites=71 tests=2495 failures=0 errors=0 (in-scope suites 4, failures 0)
- shard-4: suites=72 tests=1668 failures=0 errors=0 (in-scope suites 1, failures 0)
- shard-5: suites=73 tests=2043 failures=0 errors=0 (in-scope suites 1, failures 0)
- shard-6: suites=73 tests=2132 failures=0 errors=0 (in-scope suites 1, failures 0)
- shard-7: suites=73 tests=2129 failures=0 errors=0 (in-scope suites 3, failures 0)
- shard-8: suites=73 tests=1722 failures=0 errors=0 (in-scope suites 3, failures 0)
- Totals: 503 suites, 14153 tests, 0 failures, 0 errors; the 17 in-scope suites are all present (4+4+1+1+1+3+3 = 17) with 0 failures (AC8). No other container fails, so none exceeds its P0-T3 baseline count. Every shard JUnit file was readable.
- Loop history: the first P6-T13 run of this resume (2026-11-04T14-23 to 14-30) had shards 2 and 4 exit 1, with one failure each in `PoshQC.TestingCommands.Tests.ps1` and `PoshQC.ScanFolders.Tests.ps1` (IOException: Permission denied creating `/repo/artifacts`; the `New-Item` mock was not reached under the PoshQC-hosted shard run). The fix and the restart from P6-T4 are recorded in `evidence/other/execution-deviations.2026-11-04T13-58.md`.
