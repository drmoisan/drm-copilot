# PowerShell final static checks, loop pass after the gate fixes (issue #1157, P6-T3)

Timestamp: 2026-11-11T05-49
Command: sh SCRATCH/issue-1157-static.sh (in the item worktree; file list = .ps1/.psm1 paths of git diff --name-only --diff-filter=AMR from the merge base of origin/main and HEAD to the working tree, plus untracked files; pwsh 7: Invoke-Formatter check mode with scripts/powershell/PoshQC/settings/pssa.settings.psd1 comparing formatted text with file text, Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, then Invoke-PoshQCLeakScan -Root from the branch-current scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 0
Output Summary:
- Files checked: 42 (the 26 files of the previous pass plus the 16 existing hook suites that gained baseline isolation mocks after Pester run 1).
- Format step: files whose formatted text differs: 0 (EXIT_CODE 0).
- Lint step: Invoke-ScriptAnalyzer findings: 0 (EXIT_CODE 0).
- Leak scan step: "Leak scan: 748 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures."; EXIT_CODE 0; config/poshqc-leak-allowlist.json unchanged by this item.
- Loop history: this loop restarted after the fixes recorded in pester-final.2026-11-11T05-28.md. Its first pass exited 1 with 3 PSUseBOMForUnicodeEncodedFile findings, because the scripted mock insertion rewrote three suites that carry a UTF-8 BOM without it (validate-orchestrator-output.Tests.ps1, validate-orchestrator-output.human-interaction.Tests.ps1, validate-orchestrator-output.model-routing.Tests.ps1). The BOM was restored on all three, a BOM check over every modified file reports no other change, and this pass is clean.
