# Concurrent versus serial Pester run on the same tree (#1048, P7-T3)

Timestamp: 2026-10-31T19-50
Command: serial: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> (SCRATCH/issue-1048-pester-serial.ps1); concurrent: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <worktree root> (SCRATCH/issue-1048-pester-parallel.ps1)
EXIT_CODE: 0
Output Summary:

| Run | testsuites@tests | failures | errors | disabled | testsuite elements | Wall-clock seconds | Workers | Exit code |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Serial `Invoke-PoshQCTest` | 13643 | 0 | 0 | 10 | 485 | 1071.2 (Pester test time 820.95; the rest is discovery, coverage processing, and report writing) | 1 | 0 |
| Concurrent `Invoke-PoshQCParallelTest` | 13643 | 0 | 0 | 10 | 485 | 270.33 (`WallClockSeconds` of the returned object) | 8 (default: half of 24 logical processors, capped at 8) | 0 (`ExitCode`; every shard exited 0) |

- The totals and the pass/fail outcome are equal. The merged JUnit root `time` is 185.188 s, the longest shard's root time (shard 1, which holds only `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`).
- Coverage: the merged `artifacts/pester/powershell-coverage.xml` exists after the concurrent run, together with `powershell-coverage.koverage.xml`. Its LINE totals equal the serial report (covered 21113, missed 1453), as do the per-file figures for `PoshQC.Testing.psm1` (192/205), `PoshQC.Shard.psm1` (136/138), and `PoshQC.Parallel.psm1` (144/150).
- The first concurrent attempt stopped in the runner's default wait seam (`Wait-Process: Cannot find a process with the process identifier ...`) before any merged artifact was written. The seam was fixed to wait on the held process object (deviation D5 in `execution-deviations.2026-10-31T19-18.md`), and the concurrent run above was repeated on the same test tree.
