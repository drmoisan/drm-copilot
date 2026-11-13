# PowerShell Static Final QC, remediation cycle 1 (issue #1163, [P0-T1], finding F1)

Timestamp: 2026-11-13T14-36
Command: sh SCRATCH/issue-1163-static-final.sh f1pass1 (pwsh 7: git fetch origin main; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <item worktree> -GetFileList <55 changed .ps1/.psm1 files from git diff --name-only against the merge base of origin/main and HEAD, bundle mirrors excluded>; git status --porcelain before and after; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary: Final QA loop of remediation cycle 1 on the head carrying "fix(1163): name the full stale branch in the repair detail (F1)". The merge base of origin/main and HEAD is unchanged after the fetch. Formatter exit 0, 0 of 55 files rewritten (git status --porcelain had 0 entries before and 0 after); analyzer 0 findings across all 55 files, including `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`, `.codex/hooks/agent-target-worktree.ps1`, and `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1`. Type checking does not apply to PowerShell. SCRATCH here is the item worktree's gitignored scratch folder for issue 1163. Earlier powershell-static-final artifacts stay as history.

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format | Invoke-PoshQCFormat (writing) over the 55 files | 0 | 0 files rewritten |
| Porcelain observation | git status --porcelain before and after the formatter | 0 | 0 entries before, 0 after |
| Lint | Invoke-ScriptAnalyzer with pssa.settings.psd1, per file | 0 | 0 |
| Type check | not applicable to PowerShell | n/a | n/a |
