# PowerShell QA: Direct Analyzer Run (P6-T6)

Timestamp: 2026-10-29T15-15
Command: sh SCRATCH/issue-992-ps.sh static -FormatMode write (for each file from Get-PoshQCFileList -Root <worktree>: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information, with a reload-and-retry on the intermittent engine NullReferenceException)
EXIT_CODE: 0
Output Summary: 886 files analyzed; 0 findings. The first pass found 4 PSReviewUnusedParameter warnings in the new hook test (parameters read only inside GetNewClosure script blocks); they were fixed by copying each parameter into a local before the closure, and this pass reports none.
