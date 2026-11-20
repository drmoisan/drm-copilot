# PowerShell Format Baseline (P0-T2)

Timestamp: 2026-11-10T03-32
Command: sh SCRATCH/issue-1158-ps-static.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root . -WriteFile <no-op> -Logger <capture>)
EXIT_CODE: 0
Output Summary: check form over 1533 PowerShell files; 0 `Formatted:` lines (finding count 0), 1533 `Already formatted:` lines; `git status --porcelain` identical before and after the run (tree unchanged).
