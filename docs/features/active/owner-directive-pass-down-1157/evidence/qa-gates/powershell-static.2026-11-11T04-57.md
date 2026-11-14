# PowerShell final static checks (issue #1157, P6-T3)

Timestamp: 2026-11-11T04-57
Command: sh SCRATCH/issue-1157-static.sh (in the item worktree; file list = .ps1/.psm1 paths of git diff --name-only --diff-filter=AMR from the merge base of origin/main and HEAD plus untracked files; pwsh 7: Invoke-Formatter check mode with scripts/powershell/PoshQC/settings/pssa.settings.psd1 comparing formatted text with file text, Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, then Invoke-PoshQCLeakScan -Root from the branch-current scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 0
Output Summary:
- Files checked: 26 (7 production files, their 7 bundle copies, and 12 new or changed test files).
- Format step: files whose formatted text differs: 0 (EXIT_CODE 0).
- Lint step: Invoke-ScriptAnalyzer findings: 0 (EXIT_CODE 0).
- Leak scan step: "Leak scan: 748 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures."; EXIT_CODE 0; config/poshqc-leak-allowlist.json unchanged by this item.
- Loop history: the first pass of this loop (same command) exited 1 with 1 format difference (tests/scripts/claude-hooks/owner-directive-pass-down-target.Tests.ps1) and 43 analyzer findings: 2 PSUseOutputTypeCorrectly on Get-OwnerDirectiveParentIssue in .claude/hooks/owner-directive-pass-down-target.ps1 and its bundle copy, and 41 in five test files (PSUseShouldProcessForStateChangingFunctions on New-/Set- test helpers, PSReviewUnusedParameter on injected seam stubs, PSAlignAssignmentStatement). Fixes: OutputType set to [long] in source and re-copied to the bundle; test helpers renamed to Get-/Register- verbs; a file-level PSReviewUnusedParameter suppression with justification plus param() added to the two hook test files whose seam stubs mirror production signatures; Invoke-Formatter applied to the target test file. The loop restarted from the format step and this pass is clean.
