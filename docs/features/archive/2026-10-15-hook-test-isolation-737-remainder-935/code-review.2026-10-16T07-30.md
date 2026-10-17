# Code Review — Issue #935 (hook-test-isolation-737-remainder), re-audit after remediation cycle 1

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`
**Head reviewed:** `ef9b856982dc373f871103121ffef6999cbff7c5`
**Files reviewed:** the 18 PowerShell files under `tests/scripts/` in `git diff origin/main...HEAD` (7 created, 11 edited), with focus on the R1 delta `git diff 3cea50483 f0eba90a5 -- tests` (7 files, +198/-81); feature-folder Markdown read for context

## Total Blocking Findings: 0

## Executive Summary

The prior code review (`code-review.2026-10-16T03-20.md`) recorded eight non-blocking findings. This re-audit verified each against HEAD:

| Prior finding | Status | Verification |
|---|---|---|
| CR-N1 | Fixed | `EpicStateIsolation.Discovery.Helpers.ps1` header lines 11-14 name `Get-EpicStateIsolationHookReference`, its file, and the required dot-source of `EpicStateIsolation.Helpers.ps1`. |
| CR-N2 | Fixed (minor residue, CR-R2) | `Get-EpicStateIsolationPattern` holds the four regexes; `Get-EpicStateIsolationStringNode` replaces the four `$isLiteral` predicates; `Test-EpicStateIsolationVariableBoundToHook` now iterates `Get-EpicStateIsolationVariableBinding`. |
| CR-N3 | Fixed | `Test-EpicStateIsolationSeparateValue` is used by both `Get-EpicStateIsolationJoinPathPart` (line 161) and `Get-EpicStateIsolationHookReference` (line 380); five rows in `Describe 'issue #935 CR-N3 load-position parameters'` with fail-before record `r1-cr-n3-fail-before.2026-10-16T05-56.md`. |
| CR-N4 | Accepted NO-CHANGE | Disposition in `r1-dispositions.2026-10-16T05-13.md`: shared collection would either share state across `It` blocks or move a throw into discovery, contradicting "AC-5b never fails". The reasoning is sound; the cost is file reads only. |
| CR-N5 | Fixed | `Test-EpicStateIsolationConditionalAncestor` comment wrapped to three lines; `param()` split across lines. |
| CR-N6 | Fixed | Grep finds no column-0 `$script:UnderTest` line in the three guard suites; 33 indented occurrences. |
| CR-N7 | Accepted NO-CHANGE | Titles preserved to keep Pester full names unchanged for AC-14..AC-16 counting. |
| CR-N8 | Fixed | `$hooksSegmentLength = 'hooks'.Length` (HookReference helper line 315). |

The R1 changes are behavior-preserving refactors except CR-N3, which narrows the F-3 report (report-only, D3). The local post-merge JUnit on disk (two hook folders, 6342 testcases, 0 failures) includes every guard suite, the five CR-N3 rows, and the seven AC-6 suites' `AC-4` rows, all passed. No blocking defect was found. Three new non-blocking observations are recorded below.

## Findings Table

Blocking findings: 0. Non-blocking findings: 3.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (CR-R1) | `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` | lines 46-65 (`Test-EpicStateIsolationSeparateValue`) | The new helper has no direct rows. Its boundary branches (value parameter as the last element, value parameter followed by another parameter, value parameter with an attached `-Name:value` argument, and a parameter written in abbreviated form such as `-WorkingDir`) are not exercised; the five CR-N3 rows cover only the "skip next element" and "switch" paths through the callers. The fixed value-parameter list also omits the common parameters (`ErrorAction`, `WarningAction`, `OutVariable` and similar), so their separate-token values are still scanned. | Add a small data-driven `Describe` for `Test-EpicStateIsolationSeparateValue` over in-memory command ASTs covering the four boundary shapes; optionally add the common value parameters to the list. | Scenario completeness in `general-unit-test.md`. The impact is limited: the function only affects the report-only F-3 output (D3), and a common-parameter value such as `Stop` never holds a hook reference. | File read at HEAD; HookReference suite lines 358-429. |
| Info (CR-R2) | `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` | lines 77-78 vs 320; lines 213-214, 247, 305, 332, 395 | Residual duplication after CR-N2: the hook-name exclusion (`EpicStateIsolation.` prefix, `.Tests.ps1` suffix) is written in `Test-EpicStateIsolationHookLiteral` and again in `Get-EpicStateIsolationReferenceRecord`; the `$isJoinPath` and `$isVariable` predicate script blocks are redefined in several functions. | Optional: a `Test-EpicStateIsolationExcludedHookName` helper and shared predicate functions. | Reusability; a change to the exclusion rule must be made in two places. Not required for this item. | File read at HEAD. |
| Info (CR-R3) | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` | row `CR-N3 binds Join-Path positionals after the separate-token value of -Credential` (Arrange) | The row calls `$Source.Replace('__SPAWN__', ...)` on a fixture that contains no `__SPAWN__` placeholder. The call is a no-op. | Remove the `.Replace(...)` call in that row. | Readability; a reader may look for a placeholder that does not exist. | Diff `3cea50483..f0eba90a5` of the suite. |

## Correctness Notes (no finding)

- `Test-EpicStateIsolationSeparateValue` uses `-notcontains`, which is case-insensitive, so `-workingdirectory` matches. It returns `$false` when the parameter carries an attached argument, so `-WorkingDirectory:$dir` is not double-skipped.
- `ArgumentList` appears in the value-parameter list, but for the process-start cmdlet it is a load parameter and is handled before the skip check (line 379), so its value is still reported. For `Import-Module`, `-ArgumentList` values are correctly skipped.
- `Get-EpicStateIsolationStringNode -SearchNestedScriptBlock $false` in `Get-EpicStateIsolationReferenceRecord` preserves the prior non-nested search; the other three call sites use the default `$true`, matching the replaced predicates.
- `Get-EpicStateIsolationPattern` returns the same four regex strings that were previously inlined; the R1 refactor changes no row result (local JUnit: R1, R2 and F-3 rows passed).
- `Get-EpicStateLoadedSourceClosure` is unchanged by R1 and still seeds only from `Get-EpicStateHookLiteral`.

## Positive Observations

- Each R1 fix is a separate commit tagged with the finding identifiers, and `r1-findings-status.2026-10-16T06-56.md` lists every prior finding once with its evidence.
- The CR-N3 rows include switch cases that confirm the fix does not over-skip, not only the false-positive cases it removes.
- The COV-1 comparison records the population mismatch explicitly instead of presenting the 94.45% local figure as a pass.
