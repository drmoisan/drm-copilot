# Final PoshQC Analyze (issue #953, P6-T2)

Timestamp: 2026-10-16T08-29
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-final-analyze.log') (Tool route: SCRATCH/issue-953-p6-t2.sh, run with sh; followed by Select-String -SimpleMatch counts on the log)
EXIT_CODE: 0
Output Summary: Analyzer exited 0. The log contains exactly one line with the literal "PSScriptAnalyzer passed: no findings under"; no "PSScriptAnalyzer reported" line. Invoke-PoshQCAnalyze reports zero findings (AC-07).
