# PowerShell final-QC static checks, after the #1163 main sync (issue #1157, P6-T3 repeat)

Timestamp: 2026-11-13T17-25
Command: sh SCRATCH/issue-1157-sync2-static.sh (in the item worktree: git diff --name-only --diff-filter=AMR from the merge base of origin/main and HEAD over .ps1, .psm1, and .psd1 paths; then pwsh 7 SCRATCH/issue-1157-static.ps1 -File <that list> -LeakScan: Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 comparing formatted text with file text, nothing written; SHA-256 of each file before and after; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-PoshQCLeakScan -Root from the branch-current scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 0
Output Summary:
- Merge base: origin/main at the PR #1170 merge (the branch now contains it). Files checked: 29 (the branch diff holds no .psd1 file); git status --porcelain was empty before and after the run.
- Format step: drift 0; before-and-after SHA-256 equal for all 29 files (EXIT_CODE 0).
- Lint step: Invoke-ScriptAnalyzer findings 0 (EXIT_CODE 0).
- Leak scan step: "Leak scan: 757 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures." (EXIT_CODE 0); leak-scan failures 0. config/poshqc-leak-allowlist.json is unchanged against the merge base. The scan printed a warning that the scan folder tests/powershell does not exist and was skipped; that folder is absent at the merge base as well.
