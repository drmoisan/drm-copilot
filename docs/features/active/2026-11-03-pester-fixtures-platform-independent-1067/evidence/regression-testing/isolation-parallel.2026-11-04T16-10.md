# Isolation — concurrent-shard run with Invoke-PoshQCParallelTest (P3-T5)

Timestamp: 2026-11-04T16-10
Command: sh SCRATCH/issue-1067-parallel.sh (pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-parallel.ps1: Import-Module scripts/powershell/PoshQC/PoshQC.psd1, Invoke-PoshQCParallelTest -Root <worktree> -WorkerCount (Get-PoshQCParallelWorkerCount); each artifacts/pester/parallel/shard-<i>/pester-junit.xml read afterwards; run 2026-11-04T16-03 to 16-10)
EXIT_CODE: 0

- Worker count: 8 (Get-PoshQCParallelWorkerCount on 16 logical processors). Wall clock 411.95 s; Invoke-PoshQCParallelTest exit code 0; merged JUnit and coverage written.
- Shard exit codes: shard 1 = 0, shard 2 = 0, shard 3 = 0, shard 4 = 0, shard 5 = 0, shard 6 = 0, shard 7 = 0, shard 8 = 0.

| Shard | Suites | Tests | Failures | Errors | Change-set suites present |
|---|---|---|---|---|---|
| shard-1 | 1 | 439 | 0 | 0 | none |
| shard-2 | 67 | 1591 | 0 | 0 | Test-DiscoveryHostCapability.Entry.Tests.ps1 |
| shard-3 | 71 | 2242 | 0 | 0 | link-feature-docs.Tests.ps1 |
| shard-4 | 72 | 1864 | 0 | 0 | Enter-DrmCopilotShell.Tests.ps1, Test-DiscoveryHostCapability.Tests.ps1 |
| shard-5 | 73 | 2039 | 0 | 0 | none |
| shard-6 | 73 | 2111 | 0 | 0 | link-parent-child.Tests.ps1 |
| shard-7 | 74 | 2401 | 0 | 0 | none |
| shard-8 | 73 | 1485 | 0 | 0 | none |

Totals: 504 suites, 14172 tests, 0 failures, 0 errors. All five change-set suites are present (1 + 1 + 2 + 1 = 5) with 0 failures. Every shard JUnit file was readable.

Loop history: the first `[P3-T5]` run of this cycle (2026-11-04T15-53 to 16-01) had shard 8 exit 1 with one failure in `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, a child-process `System.IO.FileLoadException` (exit 134) outside the change set; that suite passed 3 of 3 alone, and the loop restarted from `[P3-T1]` with no file change (`evidence/other/execution-deviations.2026-11-04T16-02.md`, item 2).

Output Summary: 8 workers, every shard exit code 0, total failures 0 over 14172 tests, and the five change-set suites present and passing.
