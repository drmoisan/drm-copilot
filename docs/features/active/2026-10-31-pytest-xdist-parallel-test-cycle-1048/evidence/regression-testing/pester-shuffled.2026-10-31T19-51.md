# Seeded shuffled file-order Pester runs of the touched suites (#1048, P7-T4)

Timestamp: 2026-10-31T19-51
Command: SCRATCH/issue-1048-pester-shuffle.ps1 -Seed <seed>: one pwsh process per seed runs Invoke-Pester over tests/scripts/powershell/PoshQC/*.Tests.ps1 and tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 (23 files) in a Fisher-Yates order drawn from [System.Random]::new(<seed>), with JUnit written to SCRATCH/issue-1048-pester-shuffle-<seed>.xml
EXIT_CODE: 0
Output Summary:
All three seeds ran 242 tests (235 passed, 7 skipped) with 0 failures and 0 errors read from the JUnit files.

| Seed | JUnit tests | Failures (JUnit) | Errors | Disabled |
| --- | --- | --- | --- | --- |
| 1048 | 242 | 0 | 0 | 7 |
| 20261031 | 242 | 0 | 0 | 7 |
| 7 | 242 | 0 | 0 | 7 |

File orders:

- Seed 1048: PoshQC.TestingCommands, PoshQC.Comprehensive, PoshQC.TestingCoveragePruning, PoshQC.Shard, PoshQC.ShardWeights, PoshQC.ScanFolders, PoshQC.Coverage, PoshQC.ParallelRunner, PoshQC.TestingSeamDefaults, PoshQC.TestingOutputPath, Get-PoshQCFileList.Excludes, PoshQC.TestingInvokeConfigPaths, PoshQcWorkflow, PoshQC.ScanConfig, PoshQC.RunSettings, PoshQC.CoverageConfig, PoshQC.TestingInvokeSummary, PoshQC, PoshQC.TestingShard, PoshQC.CoverageMerge, PoshQC.ModuleCoverage, PoshQC.ParallelMerge, PoshQC.EntryPoints (each `.Tests.ps1`).
- Seed 20261031: PoshQC.Shard, PoshQC.TestingCoveragePruning, PoshQC.TestingSeamDefaults, PoshQC.TestingInvokeSummary, PoshQC.ParallelRunner, PoshQC.CoverageConfig, PoshQC, PoshQC.TestingShard, PoshQC.EntryPoints, PoshQC.ModuleCoverage, PoshQC.TestingOutputPath, Get-PoshQCFileList.Excludes, PoshQcWorkflow, PoshQC.TestingInvokeConfigPaths, PoshQC.ShardWeights, PoshQC.ScanConfig, PoshQC.RunSettings, PoshQC.Comprehensive, PoshQC.TestingCommands, PoshQC.ParallelMerge, PoshQC.Coverage, PoshQC.ScanFolders, PoshQC.CoverageMerge (each `.Tests.ps1`).
- Seed 7: PoshQcWorkflow, PoshQC.RunSettings, PoshQC.TestingOutputPath, PoshQC.TestingInvokeConfigPaths, PoshQC.ScanConfig, PoshQC.Coverage, PoshQC.TestingCommands, PoshQC.CoverageConfig, PoshQC.ParallelMerge, PoshQC, PoshQC.CoverageMerge, PoshQC.TestingShard, PoshQC.EntryPoints, PoshQC.ScanFolders, PoshQC.TestingInvokeSummary, PoshQC.TestingCoveragePruning, Get-PoshQCFileList.Excludes, PoshQC.Shard, PoshQC.ModuleCoverage, PoshQC.Comprehensive, PoshQC.ShardWeights, PoshQC.TestingSeamDefaults, PoshQC.ParallelRunner (each `.Tests.ps1`).
