# Baseline Line Counts (P0-T3)

Timestamp: 2026-10-02T07-45
Command: git grep --untracked -c '' -- scripts/powershell/PoshQC/PoshQC.Testing.psm1 scripts/powershell/PoshQC/PoshQC.psm1 tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1
EXIT_CODE: 0
Output Summary: six numeric line counts recorded (deviation DEV-P0-T3 replaces rule LL with git grep line counting; see `evidence/other/plan-deviations.2026-10-02T07-45.md`). These are the baselines for P4-T5 and P6-T28.

| Lines | Path |
| --- | --- |
| 463 | scripts/powershell/PoshQC/PoshQC.Testing.psm1 |
| 146 | scripts/powershell/PoshQC/PoshQC.psm1 |
| 766 | tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 |
| 579 | tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 |
| 472 | tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 |
| 141 | tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 |

Raw output (path:count):

```text
scripts/powershell/PoshQC/PoshQC.Testing.psm1:463
scripts/powershell/PoshQC/PoshQC.psm1:146
tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1:766
tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1:472
tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1:141
tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1:579
```

`git grep -c ''` counts every line, including a final line without a trailing newline; for files ending in a newline this equals `(Get-Content -LiteralPath <file>).Count` used by rule LL.
