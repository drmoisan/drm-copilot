# Toolchain Versions (round 2, P1-T3)

Timestamp: 2026-10-17T12-59
Command: sh SCRATCH/issue-527-launch-toolchain.sh (PowerShell 7 over SCRATCH/issue-527-toolchain.ps1: prints `$PSVersionTable.PSVersion`, the highest installed Pester from `Get-Module -ListAvailable`, and imports `scripts/powershell/PoshQC/PoshQC.psd1` then resolves `Invoke-PoshQCTest`)
EXIT_CODE: 0
Output Summary: PowerShell 7.6.6; highest installed Pester 5.9.0 (inside the supported range 5.9.0 to 5.99.99 of `Invoke-PoshQCTest`); import of the branch PoshQC module succeeded and exposes `Invoke-PoshQCTest`.

```text
POWERSHELL_VERSION=7.6.6
PESTER_HIGHEST_INSTALLED=5.9.0
IMPORT=ok; COMMAND=Invoke-PoshQCTest; MODULE=PoshQC
PROCESS_EXIT=0
```
