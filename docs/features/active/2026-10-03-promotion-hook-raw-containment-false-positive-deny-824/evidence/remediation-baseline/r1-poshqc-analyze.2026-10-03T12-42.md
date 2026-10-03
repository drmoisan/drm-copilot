# r1 P0-T12 — PowerShell analyze baseline

Timestamp: 2026-10-03T12-42
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t12.ps1 -Worktree WORKTREE; step script runs `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "$Scratch/r1-analyze-baseline.log"` then the pass-line count and the VERDICT line
EXIT_CODE: 0
Output Summary:
- ANALYZE-EXIT=0
- PASS-LINE=1 (`PSScriptAnalyzer passed: no findings under` printed once; zero findings)
