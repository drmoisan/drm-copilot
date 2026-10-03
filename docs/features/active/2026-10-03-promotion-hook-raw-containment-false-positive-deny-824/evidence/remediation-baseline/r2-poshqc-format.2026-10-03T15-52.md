# r2 P0-T11 PowerShell format baseline (check-only)

Timestamp: 2026-10-03T15-52
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -WriteFile { param([string] $Path, [string] $Content) }' *> "$Scratch/r2-format-baseline.log" (step script SCRATCH/steps/r2-p0-t11.ps1, with the FORMATTED and ALREADY-FORMATTED counts and VERDICT)
EXIT_CODE: 0
Output Summary: FORMAT-EXIT=0, FORMATTED=0, ALREADY-FORMATTED=624. The injected no-op -WriteFile made the run rewrite nothing; no file needed formatting at BASE_SHA.
