# r3 P0-T11 PowerShell format baseline, check-only (issue #824)

Timestamp: 2026-10-03T18-49
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -WriteFile { param([string] $Path, [string] $Content) }' *> "$Scratch/r3-format-baseline.log" (run inside SCRATCH/steps/r3-p0-t11.ps1; Formatted:/Already formatted: line counts; VERDICT)
EXIT_CODE: 0
Output Summary:
TS=2026-10-03T18-49
FORMAT-EXIT=0
FORMATTED=0
ALREADY-FORMATTED=627
The injected no-op -WriteFile rewrote nothing; no file needs formatting at baseline.
