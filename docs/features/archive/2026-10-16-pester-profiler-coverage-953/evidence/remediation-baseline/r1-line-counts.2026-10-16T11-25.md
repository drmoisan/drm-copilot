# Remediation Cycle 1 - Baseline Line Counts (P0-T12)

Timestamp: 2026-10-16T11-25
Command: sh SCRATCH/issue-953-r1-p0-t12.sh (pwsh -NoProfile -Command: foreach ($p in <four paths>) { "LINES: $p $((Get-Content -LiteralPath $p).Count)" })
EXIT_CODE: 0
Output Summary: The three fixed counts match the planning-time values (461, 163, 122). PoshQC.psm1 records 149 (PSM1_BASELINE_LINES).

LINES: scripts/powershell/PoshQC/PoshQC.Testing.psm1 461
LINES: scripts/powershell/PoshQC/PoshQC.psm1 149
LINES: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 163
LINES: tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 122
PSM1_BASELINE_LINES: 149
