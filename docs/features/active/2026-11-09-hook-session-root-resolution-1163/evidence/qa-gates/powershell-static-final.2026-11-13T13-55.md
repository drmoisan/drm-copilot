# PowerShell Static Final QC after the self-review fix (issue #1163, P8-T1 re-run)

Timestamp: 2026-11-13T13-55
Command: sh SCRATCH/issue-1163-static-final.sh pass2 (pwsh 7: git fetch origin main; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <item worktree> -GetFileList <55 changed .ps1/.psm1 files from git diff --name-only against the merge base of origin/main and HEAD, bundle mirrors excluded>; git status --porcelain before and after; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary: QA loop re-run from P8-T1 after the P8-T8 self-review fix (commit "fix(1163): keep failure context in two resolver fallbacks (P8-T8)"). The merge base of origin/main and HEAD is unchanged after the fetch. Formatter exit 0, 0 of 55 files rewritten (git status --porcelain had 0 entries before and 0 after); analyzer 0 findings across all 55 files, including the three edited production files and the two edited test files. Type checking does not apply to PowerShell. SCRATCH here is the item worktree's gitignored scratch folder for issue 1163. Earlier powershell-static-final artifacts stay as history.

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format | Invoke-PoshQCFormat (writing) over the 55 files | 0 | 0 files rewritten |
| Porcelain observation | git status --porcelain before and after the formatter | 0 | 0 entries before, 0 after |
| Lint | Invoke-ScriptAnalyzer with pssa.settings.psd1, per file | 0 | 0 |
| Type check | not applicable to PowerShell | n/a | n/a |

The 55 files are the same set as powershell-static-final.2026-11-12T12-35.md; each recorded 0 findings.
