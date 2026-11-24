# Final PowerShell Static QC (issue #1231)

Timestamp: 2026-11-24T00-46
Command: sh SCRATCH/issue-1231-p4-static.sh
EXIT_CODE: 0
Output Summary: format, analyzer, and leak scan all clean in one pass; git status --porcelain unchanged before and after (PORCELAIN_UNCHANGED=yes).

## Step 1: format
Command: pwsh -NoProfile -File SCRATCH/issue-1231-static.ps1 (Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 in check mode, the comparison Invoke-PoshQCFormat performs, without writing) over every new and changed .ps1 file: the four new hook files, the four edited hook files, and the five new suites (13 files)
EXIT_CODE: 0
Output Summary: formatter changed-file count 0.

## Step 2: analyzer
Command: Invoke-ScriptAnalyzer -Path <each of the 13 files> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 (same script)
EXIT_CODE: 0
Output Summary: analyzer finding count 0 across the 13 files.

## Step 3: type check
Not applicable for PowerShell.

## Step 4: leak scan
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root ." (the scan throws on any failure, which ends the command non-zero)
EXIT_CODE: 0
Output Summary: `Leak scan: 907 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.` One warning: the scan configuration folder tests/powershell does not exist and was skipped (pre-existing configuration, unrelated to this change).

Note: the PoshQC MCP format tool writes files across the repository and returns no output, so the check-mode run above is the recorded format step for the in-scope files.
