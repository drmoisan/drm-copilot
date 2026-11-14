# PowerShell final static checks, post-merge confirmation (issue #1157, P6-T3)

Timestamp: 2026-11-12T12-36
Command: sh SCRATCH/issue-1157-static.sh (in the item worktree; file list = .ps1/.psm1 paths of git diff --name-only --diff-filter=AMR from the merge base of origin/main and HEAD to the working tree, plus untracked files; pwsh 7: Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 comparing formatted text with file text (nothing written), Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, then Invoke-PoshQCLeakScan -Root from the branch-current scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 0
Output Summary:
- Context: re-run because merge 4fb158d74-equivalent tree state changed (origin/main with issue #1167 merged into the branch after the earlier P6-T3 evidence); plan rule P6-T10 requires P6-T3 to P6-T7 on the changed tree.
- Files checked: 42.
- Format step: files whose formatted text differs: 0 (EXIT_CODE 0).
- Lint step: Invoke-ScriptAnalyzer findings: 0 (EXIT_CODE 0).
- Leak scan step: "Leak scan: 749 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures."; EXIT_CODE 0; config/poshqc-leak-allowlist.json unchanged against the merge base.
