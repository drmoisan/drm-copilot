# Task Check - P2-T1 (Issue #1221)

Timestamp: 2026-11-24T04-36
Command: sh SCRATCH/issue-1221-static-ps.sh check <files>; sh SCRATCH/issue-1221-pssa-one.sh <file>; cmp <module> <bundle copy>; awk 'END{print NR}' <file>; sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <selection>
EXIT_CODE: 0
Output Summary: Format 0 files needing format; analyzer 0 findings on both modules and both test files (one transient analyzer null-reference on DocsLedgerCommands.psm1, clean on the immediate retry in a fresh process); both bundle copies byte-identical; DocsLedgerCommands.psm1 760 logical lines (baseline 758, +2, cap 761); Pester selection 611 passed, 0 failed (8 shards, exit 0).

## Changed Files

- `.claude/lib/docs/DocsCoverageReport.psm1`: new exported `Get-DocsCoverageFamilySection` and `ConvertTo-DocsCoverageFamilyLine`; one delegating line at the end of `ConvertTo-DocsCoverageReportLine` that runs only when the report contains `families`; `DocsFamilyCheck.psm1` import; `Get-DocsCoverageReport` signature and return literal unchanged (224 logical lines).
- `.claude/lib/docs/DocsLedgerCommands.psm1`: `DocsFamilyCheck.psm1` import and the `$report['families']` assignment after the `Get-DocsCoverageReport` call in `Invoke-DocsCoverageCommand` (2 added logical lines).
- Bundle copies of both modules under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` (byte-identical).
- `tests/scripts/claude-lib/docs/DocsCoverageReport.Families.Tests.ps1` (new; drafted by the earlier executor run in SCRATCH, placed on resume): section shape and empty arrays, the zero summary line through `ConvertTo-DocsCoverageReportLine`, no family line without the key, family lines with the `missing_root_files` suffix, legacy lines, `It 'counts a mixed families section in the summary line'` (Planner Decision P-2, recorded as decision 1 of `decisions.2026-11-23T13-10.md`), the six keys of `Get-DocsCoverageReport`, and `It 'reports a present family through the coverage command'`.
- `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1`: `It 'returns totals with by_analysis_method, undocumented, deferred, precision_limits, stale_pages and parity'` now expects the sorted keys `deferred, families, parity, precision_limits, stale_pages, totals, undocumented` (AC-15).

## Selection and Rule

- Every test file that names `DocsCoverageReport`, `DocsLedgerCommands`, or `Invoke-DocsCommand.ps1`, plus `Docs.Manifest.Tests.ps1` and `FileSizePolicy.RepoGate.Tests.ps1`: 33 files (SCRATCH/issue-1221-sel-p2t1.txt), which include the plan's new file and the three existing files (`DocsLedgerCommands.Tests.ps1`, `DocsCoverageReport.Tests.ps1`, `DocsCoverageReport.Properties.Tests.ps1`). Integration-lane files are excluded locally.

## Commands and Exit Codes

| Step | Command | EXIT_CODE | Result |
|---|---|---|---|
| Format | static-ps check (4 files) | 0 | FILES_NEEDING_FORMAT=0 |
| Analyze | pssa-one per file (4 files, 2 bundle copies) | 0 | FINDINGS=0 each (one transient NRE retried) |
| Line count | awk over DocsLedgerCommands.psm1 | 0 | 760 |
| Pester | launcher pester -TestPath (33 files) | 0 | TESTS=611 FAILURES=0 |
