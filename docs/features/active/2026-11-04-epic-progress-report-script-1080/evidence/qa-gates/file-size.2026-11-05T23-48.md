# QA Gate: File Size (Issue #1080, remediation cycle 1, P2-T5)

Timestamp: 2026-11-05T23-48
Command: sh SCRATCH/issue-1080-lines.sh (@(Get-Content -LiteralPath <path>).Count per change-set file)
EXIT_CODE: 0

## Counts against the 500, 700, and 800 tiers

| File | Baseline (P0-T2) | Final | Tier |
|---|---|---|---|
| scripts/dev-tools/Get-EpicProgressReport.ps1 | 456 | 474 | below 500 |
| scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 | 653 | 661 | at or above 500 (guidance); below 700 |
| tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 | 426 | 455 | below 500 |
| tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | 560 | 601 | at or above 500 (guidance); below 700 |

No file is at or above 700 (advisory) and every file is at or below 800 (hard limit). The two files in the 500 guidance tier were already there at baseline; no gate fails at that tier.

Output Summary: counts 474, 661, 455, 601; all at or below 800; none at or above 700; Get-EpicProgressReport.Logic.ps1 and Get-EpicProgressReport.Logic.Tests.ps1 are in the 500-line guidance tier.
