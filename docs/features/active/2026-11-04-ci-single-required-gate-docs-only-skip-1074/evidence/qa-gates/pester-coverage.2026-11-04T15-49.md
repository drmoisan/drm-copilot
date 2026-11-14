# Final Pester Run with Coverage: tests/scripts/ci and tests/scripts/workflows (Issue #1074)

Timestamp: 2026-11-04T15-49
Task: [P6-T3]
Command: sh SCRATCH/issue-1074-run.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts/ci,tests/scripts/workflows -SettingsPath SCRATCH/issue-1074-pester.settings.psd1, a copy of the module settings with CodeCoverage.Path set to the four scripts/ci decision and entry files and Run.Exit false)
EXIT_CODE: 0
Output Summary:
- Source `artifacts/pester/pester-junit.xml` (testsuites root): tests 410, failures 0, errors 0, disabled 0.
- New suites: `tests/scripts/ci/CiRequiredGate.Tests.ps1` 103 tests (RG01 to RG13 all passed), `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1` 18 tests (IG01 to IG07 all passed; IG01 to IG06 are the planned cases, IG07 covers the default seams through the mocked environment wrapper), `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` 5 tests (WG01 to WG05 all passed). 126 RG, IG, and WG test cases, failures 0.
- Existing suites unchanged and passing: CiChangeScope 80, CiDocsOnlyPathsConfig 26, FileSizeBaseline 26, FileSizePolicy.RepoGate 5, Invoke-CiChangeScope 30, Invoke-CiChangeScopeMergeBase 28, New-FileSizeBaseline 15, CiChangeScopeWorkflow 40, CiWorkflow 4, PoshQcWorkflow 15, PublishMcpNpmWorkflow 11, VerifyPublishedReleasesWorkflow 4.
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`: 5 tests, failures 0 (repository file-size gate passed).
- Source `artifacts/pester/powershell-coverage.xml` (LINE counters):
  - `scripts/ci/CiRequiredGate.psm1`: 90 covered, 0 missed, 100% (floor 85%).
  - `scripts/ci/Invoke-CiRequiredGate.ps1`: 27 covered, 3 missed, 90% (floor 85%); the missed lines are the three guarded entry statements that run only when the script is executed (the `Invoke-CiRequiredGateEntry` call and the two `exit` statements).
  - `scripts/ci/CiChangeScope.psm1`: 131 covered, 9 missed, 93.57%.
  - `scripts/ci/Invoke-CiChangeScope.ps1`: 103 covered, 10 missed, 91.15%.
