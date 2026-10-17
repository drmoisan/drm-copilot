# Order Independence, Seed 20261017 (round 2, P4-T3)

Timestamp: 2026-10-17T13-09
Command: sh SCRATCH/issue-527-launch-shuffle.sh 20261017 (same shuffled-container Pester run as seed 527, with `System.Random(20261017)`); then sh SCRATCH/issue-527-launch-compare.sh shuffle-20261017
EXIT_CODE: 0
Output Summary: PROCESS_EXIT=0; ORDER_MATCH is True; JUNIT_FAILURES is 0; POPULATION_SOURCE is `config`; the ORDER differs from the ORDERs recorded for seeds 527 and 1017 (first file `PoshQC.Coverage.Tests.ps1`); 215 files, root LINE total 19095, same KEY_SHA256 as run A.

```text
SEED=20261017
ORDER=PoshQC.Coverage.Tests.ps1,PoshQC.TestingInvokeConfigPaths.Tests.ps1,PoshQC.ScanConfig.Tests.ps1,PoshQC.TestingCoveragePruning.Tests.ps1,PoshQC.TestingSeamDefaults.Tests.ps1,PoshQC.ScanFolders.Tests.ps1,PoshQC.Shard.Tests.ps1,Get-PoshQCFileList.Excludes.Tests.ps1,PoshQC.CoverageMerge.Tests.ps1,PoshQC.Comprehensive.Tests.ps1,PoshQC.Tests.ps1,PoshQC.CoverageConfig.Tests.ps1,PoshQC.TestingCommands.Tests.ps1,PoshQC.TestingInvokeSummary.Tests.ps1,PoshQC.ModuleCoverage.Tests.ps1,PoshQC.EntryPoints.Tests.ps1,PoshQC.RunSettings.Tests.ps1,PoshQC.TestingShard.Tests.ps1
POPULATION_SOURCE=config
POPULATION_FILES=215
ORDER_MATCH=True

== LABEL shuffle-20261017
FILES=215
DUPLICATE_KEYS=0
ROOT_LINE_TOTAL=19095
SUM_FILE_TOTALS=19095
KEY_SHA256=08ab3a8d86d003c06f1baa8276fccd32c7d0acc0c11254f90f6c218b118449a5
JUNIT_TESTS=195
JUNIT_FAILURES=0
POPULATION_LINE=Code coverage population: source=config; files=215
PROCESS_EXIT=0
```
