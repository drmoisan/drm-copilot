# Pester Concurrent-Shard Run

Timestamp: 2026-11-03T14-00
Task: [P8-T11]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-parallel.ps1 importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCParallelTest -Root <worktree> (scan folders from config/poshqc-scan.json, default worker count); counts read from the merged artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: 8 concurrent shard processes, every shard exit 0, merge exit 0, wall clock 294.75 s. Merged JUnit: 13912 tests, 0 failures, 0 errors, 493 suites.

Loop history: the pass-1 run at 2026-11-03T13-46 ended with shard 6 exit 1 and no merge (2049 tests in that shard, 1 failure): tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 reported four DynamicInvocation sites in .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 (`& $link` and `& $byPair`). The module was changed to call a named helper (Add-ParallelPrecedenceNeighborLink) and to pass a sort-property array, the bundle copy was refreshed, and the Phase 8 loop restarted at P8-T1; this record is pass 2.
