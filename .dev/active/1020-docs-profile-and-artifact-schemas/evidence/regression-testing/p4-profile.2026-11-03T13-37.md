# DocsProfile Suite ([P4-T2])

Timestamp: 2026-11-03T13-37
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs issue-1020-exec-p4-profile.log (branch-current `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` from `scripts/powershell/PoshQC/PoshQC.psd1`); counts read from `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1020-summary.ps1 and SCRATCH/issue-1020-exec-suites.ps1
EXIT_CODE: 0
Output Summary: `DocsProfile.Tests.ps1` tests=24 failures=0 errors=0 skipped=0. Whole run (7 suites): tests=274 failures=0 errors=0 skipped=0. Line coverage of `.claude/lib/docs/DocsProfile.psm1` 100% (81 covered, 0 missed).

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| DocsAnalyzerRegistry.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsFinding.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsJson.Tests.ps1 | 27 | 0 | 0 | 0 |
| DocsProfile.Tests.ps1 | 24 | 0 | 0 | 0 |
| DocsSchema.Tests.ps1 | 48 | 0 | 0 | 0 |
| DocsSchemaContract.Tests.ps1 | 49 | 0 | 0 | 0 |
| DocsSurface.Tests.ps1 | 66 | 0 | 0 | 0 |

## Run history

The first run reported 21 failures in `DocsProfile.Tests.ps1`, all from one defect in `ConvertFrom-DocsProfileText`: the default analyzer identifiers were read by piping `Get-DocsAnalyzerRegistration` output (one array object) into `ForEach-Object`, so `.Id` was read from the empty array under strict mode. The production code was changed to iterate the assigned array; the run recorded above is the second run.
