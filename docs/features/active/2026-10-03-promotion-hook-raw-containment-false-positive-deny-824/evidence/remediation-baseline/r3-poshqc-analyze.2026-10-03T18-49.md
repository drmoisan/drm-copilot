# r3 P0-T12 PowerShell analyze baseline (issue #824)

Timestamp: 2026-10-03T18-49
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "$Scratch/r3-analyze-baseline.log" (run inside SCRATCH/steps/r3-p0-t12.ps1; pass-line count; VERDICT)
EXIT_CODE: 0
Output Summary:
TS=2026-10-03T18-49
ANALYZE-EXIT=0
PASS-LINE=1
PSScriptAnalyzer reported no findings at baseline.
