# Baseline Pester Run With Coverage (issue #1012)

Timestamp: 2026-10-31T10-40
Command: sh SCRATCH/issue-1012-ps.sh SCRATCH/issue-1012-pester.ps1 (PowerShell 7; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts; single process), then SCRATCH/issue-1012-summary.ps1 reading artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- JUnit (artifacts/pester/pester-junit.xml): total 13541, passed 13531, failed 0, skipped 10
- Pre-existing failing tests: none
- Line coverage, `.claude/hooks/validate-orchestrator-output.ps1`: 99.16% (118 covered, 1 missed; missed line inside `Test-HumanInteractionShape` default `FileExistsCheck` scriptblock)
- Run duration: 802 s of test execution (1005 s including coverage processing)
- Aggregate Pester coverage summary: 92.75% of 34081 analyzed commands in 256 files
