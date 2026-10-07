# Line Limits (P6-T28)

Timestamp: 2026-10-02T08-45
Command: git/static-equivalent deviation DEV-P6-T28 (replaces rule LL). `git grep -c '' -- scripts/powershell/PoshQC/PoshQC.Testing.psm1 scripts/powershell/PoshQC/PoshQC.Coverage.psm1 tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 tests/fixtures/poshqc-consumer/scripts/Sample.psm1 tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1 tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1 tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` run from `<ROOT>` (all nine files tracked; the count is the number of lines).
EXIT_CODE: 0
Output Summary: first eight files at or under 500; Comprehensive 766, equal to its P0-T3 baseline 766.

| File | Lines | Limit |
| --- | --- | --- |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 460 | 500 |
| scripts/powershell/PoshQC/PoshQC.Coverage.psm1 | 314 | 500 |
| tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 | 405 | 500 |
| tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 | 253 | 500 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | 142 | 500 |
| tests/fixtures/poshqc-consumer/scripts/Sample.psm1 | 32 | 500 |
| tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1 | 13 | 500 |
| tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1 | 25 | 500 |
| tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | 766 | baseline 766 |

- Acceptance (AC-18): the first eight counts are at most 500 and the Comprehensive count is at most its P0-T3 baseline. Met.
