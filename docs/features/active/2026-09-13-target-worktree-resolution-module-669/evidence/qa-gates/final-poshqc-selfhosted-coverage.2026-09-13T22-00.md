# Final QC — Self-Hosted Per-File Coverage for the Two New Modules

Timestamp: 2026-09-17T08:42:16-04:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib') ; Copy-Item -LiteralPath artifacts/pester/powershell-coverage.xml -Destination evidence/other/final-powershell-coverage.selfhosted.2026-09-13T22-00.xml -Force ; [xml] extraction of report/package[@name ends with 'worktree-resolution']/sourcefile[@name = '<Module>.psm1']/counter[@type='LINE']
EXIT_CODE: 0
Output Summary: Tests Passed: 1490, Failed: 0 (baseline [P0-T7] failed count 0; no failing test under tests/scripts/claude-lib/worktree-resolution/). WorktreeResolution.psm1: covered=140, missed=2, percentage=98.59. WorktreeTargetResolution.psm1: covered=101, missed=0, percentage=100.00. Both are at least 85.00.

## Summary lines as printed (verbatim, ANSI codes removed)

```text
Discovery found 1490 tests in 2.27s.
Tests completed in 36.71s
Tests Passed: 1490, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Covered 34.46% / 0%. 13,266 analyzed Commands in 103 Files.
```

Failed count: 0 (baseline 0). The replay header was again not printed; the counts come from the
Pester-printed line of the same format (see the [P0-T7] artifact).

## Per-file extraction (names per [P0-T8]; bare-name comparison inside the worktree-resolution package)

Grouping element: `<package name='C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c/.claude/lib/worktree-resolution'>` (the only package whose name ends with `worktree-resolution`).

| Module (`sourcefile/@name`) | Rows | LINE covered | LINE missed | Percentage |
| --- | --- | --- | --- | --- |
| WorktreeResolution.psm1 | 1 | 140 | 2 | 98.59 |
| WorktreeTargetResolution.psm1 | 1 | 101 | 0 | 100.00 |

Percentage = 100 * covered / (covered + missed), rounded to two decimals.

Scoped-run report-level LINE counter (informational): `<counter type="LINE" missed="6336" covered="3243" />` (33.86).
Package count 15 (baseline 14); analyzed files 103 (baseline 101).
