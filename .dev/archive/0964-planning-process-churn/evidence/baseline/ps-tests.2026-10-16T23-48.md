# Baseline — Pester with Coverage

Timestamp: 2026-10-16T23-27
Task: [P0-T8]
Command: sh SCRATCH/issue-964-pwsh.sh 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders "tests/scripts"' (one fresh single-process run of the self-hosted PoshQC module); counts and coverage read with SCRATCH/issue-964-pscov.py
EXIT_CODE: 0
Output Summary:
- Run window 2026-10-16T23-27 to 2026-10-16T23-47 (UTC).
- `artifacts/pester/pester-junit.xml`: tests 10848, failures 0, errors 0, skipped 10 (console: "Tests Passed: 10838, Failed: 0, Skipped: 10").
- `artifacts/pester/powershell-coverage.xml`: total line coverage 92.09% (17136 of 18607 lines); console command coverage 91.36% of 27,230 analyzed commands in 208 files.
- Per-file line coverage: `.claude/hooks/validate-planner-output.ps1` 99.50% (200/201); `.claude/hooks/validate-task-researcher-output.ps1` 97.09% (100/103); `.claude/hooks/validate-executor-output.ps1` 98.33% (118/120).
- Copies of both XML files were kept as `artifacts/pester/pester-junit-964-baseline.xml` and `artifacts/pester/powershell-coverage-964-baseline.xml` (gitignored) for the [P6-T8] delta.
