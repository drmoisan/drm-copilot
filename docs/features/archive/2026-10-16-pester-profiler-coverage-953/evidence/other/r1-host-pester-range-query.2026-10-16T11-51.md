# Remediation Cycle 1 - Host Pester Range Query (P2-T7)

Timestamp: 2026-10-16T11-51
Command: sh SCRATCH/issue-953-r1-p2-t7.sh (pwsh -NoProfile -Command: "RANGE=" + (@(Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.99.99" } | ForEach-Object { $_.Version.ToString() }) -join ",") + " ALL=" + (@(Get-Module -ListAvailable -Name Pester | ForEach-Object { $_.Version.ToString() }) -join ","))
EXIT_CODE: 0
Output Summary: Printed line: `RANGE=5.9.0 ALL=5.9.0,5.6.1,3.4.0`.
RANGE is non-empty and its only version, 5.9.0, satisfies 5.9.0 <= v <= 5.99.99.
ALL versions outside the range: 5.6.1 and 3.4.0; neither appears in RANGE.
The real Get-Module applies the range that scripts/powershell/PoshQC/PoshQC.Testing.psm1 line 167 now requests, and excludes out-of-range versions such as the inbox 3.4.0 (CR-1 host-side evidence).
