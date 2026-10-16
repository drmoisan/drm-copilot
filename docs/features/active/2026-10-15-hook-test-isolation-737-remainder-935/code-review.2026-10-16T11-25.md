# Code Review — Issue #935 (hook-test-isolation-737-remainder), re-audit after remediation cycle 2

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`
**Head reviewed:** `1d364d0c16fa77a1ed38ce16c5506ee55b5bf38c` (PR #956)
**Files reviewed:**
- All 18 PowerShell files under `tests/scripts/` in `git diff origin/main...HEAD` (7 created, 11 edited).
- Focus on the cycle-2 code delta `git diff b8d8a16b0 8937eed67`, which changed two files: `EpicStateIsolation.HookReference.Helpers.ps1` and `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`.
- Feature-folder Markdown and the cycle-2 coverage evidence, read for context.

## Total Blocking Findings: 0

No code defect was found that blocks the change. The one blocking item for this branch is the coverage regression COV-1. It is recorded in `policy-audit.2026-10-16T11-25.md` and `remediation-inputs.2026-10-16T11-25.md`, and the cycle-2 investigation traced it to the isolation-guard unit U4 that this review covers. Section `## COV-1 Context for Code Owners` below gives the code-level observations relevant to that remediation.

## Executive Summary

The prior review (`code-review.2026-10-16T07-30.md`) recorded three non-blocking findings. This re-audit verified each against HEAD:

| Prior finding | Status | Verification |
|---|---|---|
| CR-R1 | Fixed | `Describe 'issue #935 CR-R1 separate-value edge cases'` (suite lines 431-454) holds 8 rows: last element, followed by another parameter, attached argument, abbreviated name, non-parameter element, named value, `-ErrorAction`, `-OutVariable`. The value-parameter list gains the ten value-taking common parameters. Fail-before record: `r2-cr-r1-fail-before.2026-10-16T09-20.md`. All 8 rows passed in CI run 38890188058. |
| CR-R2 | Fixed (one pre-existing copy remains, CR-R4) | `Test-EpicStateIsolationExcludedHookName`, `Get-EpicStateIsolationJoinPathCommand` and `Get-EpicStateIsolationVariableNode` replace the inline exclusion and the six `$isJoinPath`/`$isVariable` script blocks in the HookReference helper. Each call site keeps its original nested-search flag: `$false` in `Get-EpicStateIsolationReferenceRecord` (Join-Path) and in `Get-EpicStateIsolationHookReference` (variables), and the default `$true` elsewhere. |
| CR-R3 | Fixed | The `-Credential` row now passes `$Source` without `.Replace(...)`. |

The cycle-2 changes do not change behaviour for the paths that existed before. The one exception is the expanded common-parameter list. It narrows the report-only F-3 output (D3) by skipping the separate-token value of a common parameter such as `-ErrorAction Stop`. Two new non-blocking observations are recorded below, and one is carried as a documentation item.

## Findings Table

Blocking findings: 0. Non-blocking findings: 3.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info (CR-R4) | `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` | lines 130-145 (`Get-EpicStateHookLiteral`) | The closure-seed function still inlines the hook-literal regex and the `EpicStateIsolation.` / `.Tests.ps1` exclusion. The HookReference helper now holds both as `Get-EpicStateIsolationPattern -Name HookLiteral` and `Test-EpicStateIsolationExcludedHookName`. The code predates this branch (present on `origin/main`, line 134). | Optional: call `Test-EpicStateIsolationExcludedHookName` from `Get-EpicStateHookLiteral`. Keep the lookbehind regex unless the shared pattern is shown to be identical. | Reusability: a change to the exclusion rule still has to be made in two files. The closure must stay literal-seeded (AC-13), so any change must leave its results unchanged. | `git show origin/main:tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`; file read at HEAD. |
| Info (CR-R5) | `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` | line 434 | `$seen =[System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)` has no space after `=`, which every other assignment in the file has. Cycle 2 introduced it when it removed the preceding `$isVariable` line. The PoshQC formatter and analyzer settings did not flag it. | Insert the space. | Consistent formatting; trivial. | Cycle-2 diff of the helper. |
| Low (DOC-1) | PR #956 description | `## Verification` section | The description covers remediation cycle 1 only. It still states that COV-1 "is recorded as a denominator mismatch" and that the local 94.45% figure is not the AC-24 result. CI has since shown a like-for-like regression (90.27% at `da4ccf4f0`, 90.17% at `988ed2210`), and cycle 2 (CR-R1..CR-R3 and the COV-1 investigation) is not mentioned. | Update the PR description in the next cycle with cycle 2, the COV-1 investigation outcome and the final coverage figure. | Accuracy of the change description. Reviewers otherwise read an outdated coverage claim. | `gh pr view 956 --json body`. |

## COV-1 Context for Code Owners

These observations come from reading the U4 files. They are not a diagnosis.

- The U4 suites hold `Import-Module ./EpicScopeResolution.psm1` and `./WorktreeRunResolution.psm1` only inside here-string fixtures, which are parsed to AST and never executed. The only runtime module import in the guard suites is in the seam-sufficiency block of `enforce-gate-suites.EpicStateIsolation.Tests.ps1` (lines 285-286, `EpicScopeResolution.psm1 -Force` and `WorktreeRunResolution.psm1`). That block is unchanged by this branch: the branch diff of that file adds only fixture lines.
- The F-3 code (`Get-EpicStateVariableHookLoadReport`, AC-5b and the non-vacuity rows) reads suite text through the parse memo. It does not import or dot-source a module.
- A static reading of U4 therefore does not show which construct changes the compiled instance of `WorktreeResolution.psm1` that Pester's breakpoints bind to. The cycle-2 unit isolation localises the trigger to U4 but not to a file inside it. A per-file bisection inside U4 is the next measurable step. One candidate mechanism is a change in suite timing or order: the new HookReference suite adds a file to the `tests/scripts/claude-hooks` run, which comes before `tests/scripts/claude-lib`.

## Correctness Notes (no finding)

- `Test-EpicStateIsolationSeparateValue` still returns `$false` for an attached argument (`-Prefix:Pre`) and for a value parameter followed by another parameter, so neither is double-skipped. The CR-R1 rows assert both.
- The abbreviated-name case (`-Pref Pre`) returns `$false`, which keeps scanning `Pre`. The header comment documents this as report-only behaviour (D3). Over-reporting is the safe direction for a report that never fails a row.
- `Test-EpicStateIsolationExcludedHookName` uses ordinal `StartsWith`/`EndsWith`, the same as the two replaced inline checks.
- Wrapping the two new enumerators with `@(...)` at each call site gives the same empty and single-element behaviour as the previous direct `FindAll` enumeration.

## Positive Observations

- The COV-1 investigation used a pre-declared hypothesis ladder with VALID/INVALID gating and tree-restore checks on every run. It recorded the outcome that its own fix candidate (FIX-U2) did not apply, and did not apply that fix anyway.
- The cycle-2 code changes are confined to the two files named by the findings, and every fix is tied to a finding identifier.
- The CR-R1 rows exercise the helper directly on in-memory command ASTs, as the prior review recommended.
