# Pester Concurrent-Shard Run (remediation cycle 1, loop pass 3)

Timestamp: 2026-11-03T20-39
Task: [P6-T5]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-parallel.ps1 importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCParallelTest -Root <worktree> (scan folders from config/poshqc-scan.json, default worker count 8); per-shard counts from each shard's console summary in artifacts/pester/parallel/shard-<n>/shard.log
EXIT_CODE: 1
Output Summary: 8 shard processes, wall clock 517.42 s. Shards 1 and 5 exited 0; shards 2, 3, 4, 6, 7, 8 exited non-zero, so no merged artifact was written. 89 failures, the same per-shard counts as pass 2 (pester-parallel-shards.2026-11-03T20-08.md), all in host-fixture suites under tests/scripts/dev-tools and tests/scripts/powershell/PoshQC that fail identically at the merge base 01706c697 (comparison recorded in the pass 2 file). No failure is in a suite this item adds or changes. The acceptance condition (every shard and the merge exit 0, zero failures) is NOT met on this Linux host; the task stays unchecked as a host deviation.

| Shard | Exit | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- |
| 1 | 0 | 427 | 0 | 0 |
| 2 | 24 | 1415 | 24 | 0 |
| 3 | 13 | 2337 | 13 | 1 |
| 4 | 1 | 1582 | 1 | 7 |
| 5 | 0 | 1957 | 0 | 0 |
| 6 | 3 | 2209 | 3 | 0 |
| 7 | 255 | 2257 | 30 | 2 |
| 8 | 18 | 1663 | 18 | 0 |
