# P14-T8 PowerShell shard and completeness shape

Timestamp: 2026-10-29T12-14
Task: [P14-T8] Re-run the PowerShell gates and CI-shaped execution on the rebased tree.
Command: Invoke-PoshQCTest -Root <worktree> -ShardIndex N -ShardCount 3 -ShardFileListPath artifacts/shards/poshqc-test-results-shard-N/shard-files.json -DisableKoverageCopy for N in 1..3; then Test-PoshQCShardCompleteness over the three manifests, a discovery-only Invoke-Pester over the manifest's `all` list, Test-PoshQCShardTestCount against the three JUnit totals, and Merge-PoshQCCoverageReport over the three coverage reports (the `poshqc / PowerShell QC shard 1..3` and `poshqc / PowerShell QC` job shapes)
EXIT_CODE: 0, 0, 0 (shards, pass 2), 0 (completeness and merge, pass 2)
Output Summary: Shard 1: 4025 tests, 0 failed, 1 skipped; shard 2: 3592 tests, 0 failed, 2 skipped; shard 3: 4998 tests, 0 failed, 7 skipped. "Shard completeness verified: 3 shards, 452 test files, shard tests 4025 + 3592 + 4998 = discovery 12615." "Merged PowerShell line coverage: 20003 of 21443 lines (93.28%), 1440 missed", equal to the single-process figure, so no shard is missing and no test file is selected twice. Pass 1 failed shard 1 on the stale baseline entry recorded in `p14-powershell-tests.2026-10-29T12-14.md`, and its aggregator count mismatch followed from that failure. Retained files: `p14-powershell-junit-shard-{1,2,3}.2026-10-29T12-14.xml`, `p14-powershell-shard-files-{1,2,3}.2026-10-29T12-14.json`, `p14-powershell-coverage-merged.2026-10-29T12-14.xml`.
Result: PASS
