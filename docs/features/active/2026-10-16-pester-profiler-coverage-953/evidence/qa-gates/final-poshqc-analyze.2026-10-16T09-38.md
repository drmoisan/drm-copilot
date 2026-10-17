# Final PoshQC Analyze (issue #953, P6-T2, post-split restart pass)

Timestamp: 2026-10-16T09-38
Command: SCRATCH/issue-953-p6-t2.sh: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-final-analyze.log')`, then a `Select-String -SimpleMatch` count of `PSScriptAnalyzer passed: no findings under` in that log
EXIT_CODE: 0
Output Summary: Analyzer exited 0. The log is one line, `PSScriptAnalyzer passed: no findings under <worktree root>`; the literal `PSScriptAnalyzer passed: no findings under` occurs on 1 line. Zero findings (AC-07).
