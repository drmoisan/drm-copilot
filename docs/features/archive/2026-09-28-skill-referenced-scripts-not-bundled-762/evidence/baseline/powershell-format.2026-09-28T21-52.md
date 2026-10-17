# PowerShell Format Baseline (P0-T16)

Timestamp: 2026-09-28T21-52
Command: sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 scripts/orchestration/Invoke-CiGateParser.ps1 tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary: `FORMAT-SUMMARY ChangedCount=0` (all three files report `Changed=False`; read-only check).

```text
FORMAT file=scripts/orchestration/Invoke-CiGateParser.ps1 Changed=False
FORMAT file=tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 Changed=False
FORMAT file=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 Changed=False
FORMAT-SUMMARY ChangedCount=0
```
