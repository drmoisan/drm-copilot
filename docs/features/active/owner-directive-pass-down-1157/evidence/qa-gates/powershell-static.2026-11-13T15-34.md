# PowerShell final-QC static checks (issue #1157, cycle 1, P2-T1)

Timestamp: 2026-11-13T15-34
Command: sh SCRATCH/issue-1157-static.sh -File <every .ps1 and .psm1 path of git diff --name-only --diff-filter=AMR from the merge base of origin/main and HEAD> -LeakScan (pwsh 7: Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 comparing formatted text with file text, nothing written; SHA-256 of each file before and after; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-PoshQCLeakScan -Root from the branch-current scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 0
Output Summary:
- Files checked: 29 (the branch diff holds no .psd1 file); the working tree was clean (git status --porcelain empty) before the run.
- Format step: drift 0; before-and-after SHA-256 equal for all 29 files (EXIT_CODE 0).
- Lint step: Invoke-ScriptAnalyzer findings 0 (EXIT_CODE 0).
- Leak scan step: "Leak scan: 749 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures." (EXIT_CODE 0); leak-scan failures 0. The scan printed a warning that the scan folder tests/powershell does not exist and was skipped; that folder is absent at the merge base as well.
