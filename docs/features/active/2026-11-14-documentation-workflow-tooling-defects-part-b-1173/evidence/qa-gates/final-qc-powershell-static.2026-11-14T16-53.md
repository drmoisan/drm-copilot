# Final QC: PowerShell Static Loop (P7-T1)

Timestamp: 2026-11-14T16-53
Command: git diff --name-only --diff-filter=d <merge base of origin/main and HEAD> HEAD -- '*.ps1' '*.psm1' '*.psd1' > SCRATCH/issue-1173-final-ps.txt; sh SCRATCH/issue-1173-p0t1.sh issue-1173-final-ps.txt (SCRATCH/issue-1173-ps-static.ps1: Invoke-Formatter -ScriptDefinition with the repository settings compared with each file text, then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary:

| Step | Command | Exit code | Files | Finding count |
|---|---|---|---|---|
| 1. Format (check) | Invoke-Formatter per changed file, compared with the file text | 0 | 87 | 0 drift (no file rewritten) |
| 2. Lint | Invoke-ScriptAnalyzer per changed file with the repository settings | 0 | 87 | 0 findings |
| 3. Type check | not applicable to PowerShell | n/a | n/a | n/a |

- The 87 files are every PowerShell file added or modified on the branch since the merge base of origin/main and HEAD, including the bundle copies under extensions/drm-copilot/resources/claude-customizations/.
- The repository-wide format and analyzer stages also passed in the Phase 6 gate (1654 files, 0 drift, 0 findings).
- Recorded pass: one pass, no file rewritten, no finding.
