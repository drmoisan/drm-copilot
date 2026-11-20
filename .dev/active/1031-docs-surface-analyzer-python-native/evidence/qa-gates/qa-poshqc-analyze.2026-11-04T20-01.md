# [P6-T8] PSScriptAnalyzer, direct (fresh run on the post-merge head)

Timestamp: 2026-11-04T20-01
Command: sh SCRATCH/issue-1031-psstatic.sh qa-ps3 (direct Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file over the Get-PoshQCFileList set of the worktree root)
EXIT_CODE: 0
Output Summary: "ANALYZE files=714 findings=0 errors=0 warnings=0 information=0 exceptions=0": zero findings in files this plan created or changed (including the four renamed-helper suites of bbef268db) and a total of 0, not above the [P0-T7] total of 0.
