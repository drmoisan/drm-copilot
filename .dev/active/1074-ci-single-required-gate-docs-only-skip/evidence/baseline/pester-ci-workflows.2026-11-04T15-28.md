# Baseline Pester Run with Coverage: tests/scripts/ci and tests/scripts/workflows (Issue #1074)

Timestamp: 2026-11-04T15-28
Task: [P0-T4]
Command: sh SCRATCH/issue-1074-baseline.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts/ci,tests/scripts/workflows -SettingsPath SCRATCH/issue-1074-pester.settings.psd1, a copy of the module settings with CodeCoverage.Path limited to scripts/ci/CiChangeScope.psm1 and scripts/ci/Invoke-CiChangeScope.ps1 and Run.Exit false)
EXIT_CODE: 0
Output Summary:
- Source `artifacts/pester/pester-junit.xml` (testsuites root): tests 284, failures 0, errors 0, skipped 0, disabled 0.
- Per-suite: CiChangeScope 80, CiDocsOnlyPathsConfig 26, FileSizeBaseline 26, FileSizePolicy.RepoGate 5, Invoke-CiChangeScope 30, Invoke-CiChangeScopeMergeBase 28, New-FileSizeBaseline 15, CiChangeScopeWorkflow 40, CiWorkflow 4, PoshQcWorkflow 15, PublishMcpNpmWorkflow 11, VerifyPublishedReleasesWorkflow 4; all with failures 0.
- Source `artifacts/pester/powershell-coverage.xml` (LINE counters):
  - `scripts/ci/CiChangeScope.psm1`: 131 covered, 9 missed, 93.57% line coverage.
  - `scripts/ci/Invoke-CiChangeScope.ps1`: 103 covered, 10 missed, 91.15% line coverage.
