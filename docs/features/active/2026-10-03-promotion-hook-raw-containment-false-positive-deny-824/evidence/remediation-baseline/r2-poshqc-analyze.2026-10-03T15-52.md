# r2 P0-T12 PowerShell analyze baseline

Timestamp: 2026-10-03T15-52
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "$Scratch/r2-analyze-baseline.log" (step script SCRATCH/steps/r2-p0-t12.ps1, with the PASS-LINE count and VERDICT)
EXIT_CODE: 0
Output Summary: ANALYZE-EXIT=0, PASS-LINE=1 (log line "PSScriptAnalyzer passed: no findings under WORKTREE"); zero findings at BASE_SHA.
