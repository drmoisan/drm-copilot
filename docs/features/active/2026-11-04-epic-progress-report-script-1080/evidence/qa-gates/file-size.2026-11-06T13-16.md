# File-Size Gate — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-16
Task: P2-T5
Command: sh SCRATCH/issue-1080-lines.sh (physical lines via @(Get-Content -LiteralPath <path>).Count)
EXIT_CODE: 0
Output Summary: 475 / 688 / 455 / 702; all at or below 800. The logic file (688) is in the 500 guidance tier; the Logic test file (702) is in the 700 advisory tier, with the disposition recorded below.

## Counts

| File | Lines | Tier |
|---|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | 475 | below 500 |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | 688 | 500 guidance tier (at or above 500, below 700) |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 455 | below 500 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | 702 | 700 advisory tier (at or above 700, at or below 800) |

## Advisory disposition (from the plan `## Design`, Size)

`tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` (702): non-blocking Warning. No split in this cycle, because the file stays below 800 and the change is confined to one function (`ConvertFrom-EpicProgressKickoffRow`) and its one `Describe` block. No gate fails at this tier.
