# File Size Gate (Issue #1080, P2-T6)

Timestamp: 2026-11-04T20-57
Command: sh SCRATCH/issue-1080-probe.sh (prints @(Get-Content -LiteralPath <path>).Count for each change-set file)
EXIT_CODE: 0

## Result

| File | Lines | Tier |
|---|---|---|
| scripts/dev-tools/Get-EpicProgressReport.ps1 | 451 | below 500 |
| scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 | 653 | 500 guidance tier (below the 700 advisory tier) |
| tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 | 426 | below 500 |
| tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | 560 | 500 guidance tier (below the 700 advisory tier) |

All four counts are at or below 800 (AC1). No file is at or above 700.

Files at or above 500: the logic file and its test file. The logic file holds one cohesive set of pure functions that the main script dot-sources, and AC1 caps the change at three production files, already split by concern into pure logic and I/O wiring; the guidance tier fails no gate. The plan's Pre-Mortem estimated about 450 lines for the logic file; the comment-based help required on every function accounts for the difference.

Output Summary: 451, 653, 426, and 560 lines; all at or below 800; the logic file (653) and the logic test file (560) are in the 500-line guidance tier; none reaches 700.
