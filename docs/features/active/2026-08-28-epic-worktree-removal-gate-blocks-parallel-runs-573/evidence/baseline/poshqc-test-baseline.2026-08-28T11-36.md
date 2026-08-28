# PowerShell TEST-AND-COVERAGE Baseline (P0-T4)

Timestamp: 2026-08-28T11-36

Task: [P0-T4]
Issue: #573
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a691c7afb3cd3aa84`, no `scan_folders` restriction (repository Pester configuration `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, coverage enabled).
2. Count and coverage derivation from the reports that run wrote:
   `pwsh -NoProfile -File <scratch>/read-coverage.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -JUnitXml artifacts/pester/pester-junit.xml -SourceFileSuffix enforce-epic-worktree-removal-gate.ps1 -SuiteNameFragment enforce-epic-worktree-removal-gate`
   and `pwsh -NoProfile -File <scratch>/read-missed-lines.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -SourceFileSuffix enforce-epic-worktree-removal-gate.ps1`

EXIT_CODE: 0

## Whole-run test counts

Read from the root `<testsuites>` element of `artifacts/pester/pester-junit.xml`:

```
name="Pester" tests="3827" errors="0" failures="0" disabled="9" time="136.278"
```

| Metric | Baseline value |
| --- | --- |
| Total tests | 3827 |
| Failed | 0 |
| Errors | 0 |
| Skipped (`disabled`) | 9 |
| **Passed** | **3818** |

Passed is derived as `tests - failures - errors - disabled` = `3827 - 0 - 0 - 9` = `3818`. The `disabled="9"` count appears only on the root element; all 157 per-suite elements carry `disabled="0"`, which is how the Pester JUnit writer reports `SkippedCount`.

**There are zero failing tests in the baseline.** No baseline-red attribution record is required for PowerShell.

## In-scope suite baseline (for AC-6 comparison)

`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, verbatim from the JUnit report:

```
testsuite name="...\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" tests="27" errors="0" failures="0" hostname="MEGALODON4" id="11" skipped="0" disabled="0"
```

| Metric | Baseline value |
| --- | --- |
| In-scope suite tests | 27 |
| In-scope suite failures | 0 |
| In-scope suite skipped | 0 |

This is the count [P1-T6] compares its pre-existing pass count against, and the count [P5-T4] requires to be exactly 19 higher after the change (27 + 19 = 46).

## Codex gate suite baseline (for AC-13 / P5-T10)

```
testsuite name="...\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1" tests="40" errors="0" failures="0" hostname="MEGALODON4" id="116" skipped="0" disabled="0"
```

40 tests, 0 failures. This suite must remain at 40 passing tests and must not be edited.

## Line coverage — whole run

Derived from the report-level `LINE` counter of `artifacts/pester/powershell-coverage.xml`:

| Metric | Value |
| --- | --- |
| Covered lines | 7211 |
| Missed lines | 403 |
| Total lines | 7614 |
| **Line coverage** | **94.71%** |

`7211 / (7211 + 403) * 100 = 94.71`.

## Line coverage — `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`

Derived per the plan's stated derivation: the `sourcefile` element whose `name` ends with `enforce-epic-worktree-removal-gate.ps1`, in package `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a691c7afb3cd3aa84/.claude/hooks`. Exactly one `sourcefile` matched under that package (`SOURCEFILE_MATCH_COUNT=1` for the `.claude/hooks` package).

| Metric | Value |
| --- | --- |
| Covered lines | 64 |
| Missed lines | 4 |
| Total lines | 68 |
| **Line coverage** | **94.12%** |

`64 / (64 + 4) * 100 = 94.1176...`, rounded to `94.12`.

Missed line numbers: `269, 270, 271, 274`. These are the four lines of the un-dot-sourced entry-point tail below the `$MyInvocation.InvocationName -eq '.'` guard at line 262, which is unreachable when the suite dot-sources the hook. They are pre-existing and are not lines this change adds.

Branch coverage is not recorded. Pester does not measure branch coverage and no branch-coverage gate applies to PowerShell, per `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`.

## Runner-artifact note

The MCP wrapper returned only `{"ok":true, ... "summary":"..."}` with no counts. The counts and coverage above were read from the report files that same run wrote into `artifacts/pester/`, whose timestamps (11:42-11:43) confirm they are this run's output. The `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` file is present in the coverage denominator, so the existing `CodeCoverage.Path` registration does cover the in-scope hook and no settings edit is required. No coverage figure looked impossible, so no direct self-hosted re-verification of the test stage was needed.

Output Summary: Green PowerShell baseline. Whole run: 3827 tests, 0 failed, 0 errors, 9 skipped, 3818 passed. In-scope suite `enforce-epic-worktree-removal-gate.Tests.ps1`: 27 tests, 0 failures. Codex gate suite `epic-execution-gates.Tests.ps1`: 40 tests, 0 failures. Whole-run line coverage 94.71% (7211 covered / 403 missed of 7614). Gate-hook line coverage 94.12% (64 covered / 4 missed of 68), with missed lines 269, 270, 271, 274 — the pre-existing unreachable entry-point tail. No failing tests, so no baseline-red enumeration applies.
