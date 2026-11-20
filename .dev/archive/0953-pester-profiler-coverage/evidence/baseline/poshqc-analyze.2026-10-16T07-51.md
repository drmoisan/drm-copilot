# PoshQC Analyze Baseline (issue #953, P0-T21)

Timestamp: 2026-10-16T07-51
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-baseline-analyze.log'); $exit = $LASTEXITCODE; ...Select-String -SimpleMatch "PSScriptAnalyzer passed: no findings under"...; exit $exit' (script SCRATCH/issue-953-p0-t21.sh, run with sh)
EXIT_CODE: 0
Output Summary: Analyzer exited 0. The log contains exactly one line with the literal "PSScriptAnalyzer passed: no findings under" (followed by the worktree root path). No "PSScriptAnalyzer reported" line.
