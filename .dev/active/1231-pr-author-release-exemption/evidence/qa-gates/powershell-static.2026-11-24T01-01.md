# Final PowerShell Static QC, Loop Pass 2 (issue #1231)

Timestamp: 2026-11-24T01-01
Command: sh SCRATCH/issue-1231-p4-static.sh
EXIT_CODE: 0
Output Summary: the final QA loop restarted from format after the attempt-1 Pester failure (evidence/other/final-qa-attempt-1.2026-11-24T00-58.md) and the pr-author skill rewording; format, analyzer, and leak scan are clean in one pass; git status --porcelain unchanged before and after (PORCELAIN_UNCHANGED=yes).

## Step 1: format
Command: pwsh -NoProfile -File SCRATCH/issue-1231-static.ps1 (Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 in check mode, without writing) over the 13 new and changed .ps1 files (four new hook files, four edited hook files, five new suites)
EXIT_CODE: 0
Output Summary: formatter changed-file count 0.

## Step 2: analyzer
Command: Invoke-ScriptAnalyzer -Path <each of the 13 files> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
EXIT_CODE: 0
Output Summary: analyzer finding count 0.

## Step 3: type check
Not applicable for PowerShell.

## Step 4: leak scan
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root ."
EXIT_CODE: 0
Output Summary: `Leak scan: 907 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.` (one pre-existing configuration warning: folder tests/powershell does not exist and was skipped).
