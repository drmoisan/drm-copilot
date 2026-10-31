# Projected shard balance with the committed weights (#1048, P7-T2)

Timestamp: 2026-10-31T19-22
Command: SCRATCH/issue-1048-projection.ps1: enumerate *.Tests.ps1 under the scan folders of config/poshqc-scan.json with the default exclusions, weigh them with Get-PoshQCShardTestFileWeight -RootPath <root>, and run Select-PoshQCShardTestFile for shards 1..3 of 3
EXIT_CODE: 0
Output Summary:
- Scan folders: `scripts`, `tests/scripts` (`tests/powershell` is listed in `config/poshqc-scan.json` but does not exist and is skipped with a warning). Test files enumerated: 485. These are the 481 weighted files plus the 4 new suites of this item (`PoshQC.TestingOutputPath`, `PoshQC.ShardWeights`, `PoshQC.ParallelMerge`, `PoshQC.ParallelRunner`), which are unlisted and weigh the median.

| Shard | Files | Projected milliseconds |
| --- | --- | --- |
| 1 | 161 | 328973 |
| 2 | 162 | 328932 |
| 3 | 162 | 328930 |

- Projected spread (longest minus shortest projected load): 43 ms.
- Measured baseline spread (P0-T5, run 41209645365): 371 s (shard 1 639 s, shard 2 268 s, shard 3 381 s job durations).
- Comparison: by summed measured test time the three shards are within 0.05 s of each other, against a 371 s measured job spread under size-based weights. Job durations also include per-shard setup (checkout, module install, coverage processing), which the weights do not model, so the measured CI spread will be larger than the projection. The CI result is measured in Phase 9 (P9-T4).
