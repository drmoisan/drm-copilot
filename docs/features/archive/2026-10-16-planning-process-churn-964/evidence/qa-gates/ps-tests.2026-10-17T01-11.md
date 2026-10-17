# QA Gate — Pester with Coverage

Timestamp: 2026-10-17T00-53
Task: [P6-T6]
Command: sh SCRATCH/issue-964-pwsh.sh 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders "tests/scripts"' (one fresh single-process run of the self-hosted PoshQC module); counts and coverage read with SCRATCH/issue-964-pscov.py
EXIT_CODE: 0
Output Summary:
- Run window 2026-10-17T00-53 to 2026-10-17T01-10 (UTC).
- `artifacts/pester/pester-junit.xml`: tests 10916, failures 0, errors 0, skipped 10 (baseline [P0-T8]: 10848 tests).
- `artifacts/pester/powershell-coverage.xml`: total line coverage 92.13% (17238 of 18710 lines); baseline 92.09%; no regression.
- Per-file line coverage: `.claude/hooks/premortem-section.ps1` 100.00% (45/45, new); `.claude/hooks/validate-planner-output.ps1` 99.52% (206/207; baseline 99.50%); `.claude/hooks/validate-task-researcher-output.ps1` 97.25% (106/109; baseline 97.09%); `.claude/hooks/validate-executor-output.ps1` 98.19% (163/166; baseline 98.33%). Every file is at or above 85%.
- Copies kept as `artifacts/pester/pester-junit-964-qa.xml` and `artifacts/pester/powershell-coverage-964-qa.xml` (gitignored).
