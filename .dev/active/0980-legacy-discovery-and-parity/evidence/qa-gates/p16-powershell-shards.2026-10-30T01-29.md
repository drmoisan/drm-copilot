# P16-T3 PowerShell shard and completeness shape

Timestamp: 2026-10-30T01-29
Task: [P16-T3] Run the PowerShell gates and regenerate the canonical coverage file from the full run.
Command: Invoke-PoshQCTest -Root <worktree> -ShardIndex N -ShardCount 3 -ShardFileListPath artifacts/shards/poshqc-test-results-shard-N/shard-files.json -DisableKoverageCopy for N in 1..3; then Test-PoshQCShardCompleteness over the three manifests, a discovery-only Invoke-Pester over the manifest's `all` list, Test-PoshQCShardTestCount against the three JUnit totals, and Merge-PoshQCCoverageReport over the three coverage reports (the `poshqc / PowerShell QC shard 1..3` and `poshqc / PowerShell QC` job shapes)
EXIT_CODE: 0, 0, 0 (shards), 0 (completeness and merge)
Output Summary: Shard 1 (01-06 to 01-15 UTC): 4854 tests, 0 failed, 0 skipped; shard 2 (01-15 to 01-18): 4078 tests, 0 failed, 0 skipped; shard 3 (01-18 to 01-22): 3812 tests, 0 failed, 10 skipped. "Shard completeness verified: 3 shards, 455 test files, shard tests 4854 + 4078 + 3812 = discovery 12744." "Merged PowerShell line coverage: 20188 of 21629 lines (93.34%), 1441 missed", equal to the single-process figure, so no shard is missing and no test file is selected twice. Retained files: `p16-powershell-junit-shard-{1,2,3}.2026-10-30T01-29.xml`, `p16-powershell-shard-files-{1,2,3}.2026-10-30T01-29.json`, `p16-powershell-coverage-merged.2026-10-30T01-29.xml`.
Result: PASS
