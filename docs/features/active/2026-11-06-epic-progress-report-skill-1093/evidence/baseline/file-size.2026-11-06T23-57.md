# Baseline Physical Line Counts — Issue #1093

Timestamp: 2026-11-06T23-57
Command: sh SCRATCH/issue-1093-lines.sh <four files> (PowerShell 7: `@(Get-Content -LiteralPath <path>).Count` per file)
EXIT_CODE: 0
Output Summary: entry 477, Logic 688, Logic suite 702 (above 700, the split obligation of this plan), entry suite 455.

| File | Physical lines |
|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | 477 |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | 688 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | 702 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 455 |
