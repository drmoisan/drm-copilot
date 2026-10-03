# r1 P0-T11 — PowerShell format baseline (check-only)

Timestamp: 2026-10-03T12-42
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t11.ps1 -Worktree WORKTREE; step script runs `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -WriteFile { param([string] $Path, [string] $Content) }' *> "$Scratch/r1-format-baseline.log"` then the two Select-String counts and the VERDICT line
EXIT_CODE: 0
Output Summary:
- FORMAT-EXIT=0
- FORMATTED=0
- ALREADY-FORMATTED=620
- The injected no-op `-WriteFile` script block made the run rewrite nothing; log kept at SCRATCH/r1-format-baseline.log.
