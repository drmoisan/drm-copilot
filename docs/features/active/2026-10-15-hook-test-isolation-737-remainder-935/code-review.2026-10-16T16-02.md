# Code Review — Issue #935 (hook-test-isolation-737-remainder), re-audit after remediation cycle 3

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`
**Head reviewed:** `ddadd0835e302f3e45cd60808356e7cb5872ca3e` (PR #956)
**Files reviewed:**
- All 18 PowerShell files under `tests/scripts/` in `git diff origin/main...HEAD` (7 created, 11 edited).
- Focus on the cycle-3 code delta `git diff 1d364d0c1 HEAD -- tests`, which changed two files: `EpicStateIsolation.Discovery.Helpers.ps1` (header paragraph and one call in `Get-EpicStateHookLiteral`) and `EpicStateIsolation.HookReference.Helpers.ps1` (one spacing fix).
- Feature-folder Markdown, the cycle-3 coverage evidence and the COV-1 decision record, read for context.

## Total Blocking Findings: 0

No code defect was found that blocks the change. The one blocking item for this branch is the coverage regression COV-1, recorded in `policy-audit.2026-10-16T16-02.md` and `remediation-inputs.2026-10-16T16-02.md`. It is classified `external_dependency` because the recorded decision routes the fix through issue #953 / PR #959, outside this item's Write Set.

## Executive Summary

The prior review (`code-review.2026-10-16T11-25.md`) recorded three non-blocking findings. This re-audit verified each against HEAD:

| Prior finding | Status | Verification |
|---|---|---|
| CR-R4 | Fixed | `Get-EpicStateHookLiteral` (Discovery helper line 139) now calls `Test-EpicStateIsolationExcludedHookName -Name $name` in place of the two inline ordinal checks. The predicate (HookReference helper lines 71-80) returns ordinal `StartsWith('EpicStateIsolation.')` or `EndsWith('.Tests.ps1')`, so the set of skipped names is unchanged and the closure stays literal-seeded (AC-13). The lookbehind regex is unchanged. The header paragraph now names `Get-EpicStateHookLiteral` as a caller of the HookReference helper and states the dot-source requirement. |
| CR-R5 | Fixed | HookReference helper line 434 reads `$seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)`. |
| DOC-1 | Open (carried) | `gh pr view 956 --json body` at HEAD: the description still covers cycle 1 only, states that COV-1 "is recorded as a denominator mismatch", and does not mention cycles 2 and 3 or the profiler-mode decision. |

Dependency check for CR-R4: `Get-EpicStateHookLiteral` now requires `Test-EpicStateIsolationExcludedHookName` at call time. Every file that dot-sources `EpicStateIsolation.Discovery.Helpers.ps1` (the Discovery suite, twice, and the HookReference suite) also dot-sources `EpicStateIsolation.Helpers.ps1`, which dot-sources the HookReference helper. No other file in `tests/`, `scripts/` or `.claude/` references the Discovery helper. Run 38922641167 (code identical to HEAD) reports 0 failures for the Discovery suite (365 testcases) and the HookReference suite (41).

## Findings Table

Blocking findings: 0. Non-blocking findings: 2.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (DOC-1, carried) | PR #956 description | `## Verification` section | The description covers remediation cycle 1 only and still calls COV-1 a denominator mismatch. Cycles 2 and 3, the COV-1 bisection outcome, the profiler-mode decision and the dependency on #953 / PR #959 are not described. | Update the description with cycles 2 and 3, the decision record path, the dependency on PR #959, and the final AC-24 figure once known. | Accuracy of the change description; reviewers otherwise read an outdated coverage claim. | `gh pr view 956 --json body` (lines 10, 46, 75, 79 of the body). |
| Low (EV-2) | `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/cov1-decision.2026-10-16T15-56.md` | `## Consequences for #935` | The settlement procedure re-measures only `WorktreeResolution.psm1` against TARGET 142 and records PASS "if the re-measured value reaches TARGET 142". CI on main at `5d2d9a972` (run 38911869997) already reports 112 for that file, so 142 is no longer main's own figure under breakpoint mode. The PR's remaining same-population loss (105 lines) is in `.claude/lib/orchestrator-state/` (104) and `EpicScopeResolution.psm1` (1), which the procedure does not examine. | When AC-24 is settled, compare the root LINE counter of the final-head PR CI file against the 90.42% baseline and against main CI at the same population, and diff every per-file counter. Treat `WorktreeResolution.psm1` = 142 as a supporting signal only. | AC-24 is a root-level criterion; a single-file target can pass while the root figure stays below the baseline. | Per-file diff of the `poshqc-test-results` coverage files of runs 38922641167 and 38911869997 (section 1.2.1 of the policy audit). |

## COV-1 Context for Code Owners

- Cycle 3 ran the planned bisection (N0-N5) and three fix trials. At the merged head the U4 revert no longer restores the attribution (`T-U4-NO-LONGER`), so no Write Set file is identified as the trigger. This agrees with the CI comparison above: main's own attribution of `WorktreeResolution.psm1` moved from 142 to 112 between `3fc83c8c3` and `5d2d9a972` without any #935 change, and the PR's loss relative to main has moved to different modules.
- Three PR CI runs on code-identical trees (`d81de8ac8`, `af4672b7d`, `3ab81c26f`) report identical root and per-file counters, so the per-run attribution is repeatable for a fixed suite set; it changes when the suite set changes.
- Nothing in the two cycle-3 code lines can affect module loading: one is a function call that replaces two string comparisons, and the other is whitespace.

## Correctness Notes (no finding)

- `Test-EpicStateIsolationExcludedHookName` uses `-or` across the two ordinal checks, matching the two sequential `continue` statements it replaces.
- The Discovery helper's header update keeps the file at 292 lines; no row name or row result changed.

## Positive Observations

- The cycle-3 bisection used pre-declared nodes, a terminal derivation and tree-restore checks on every run, and it recorded that the cycle-2 localisation no longer held after the merge instead of forcing a fix.
- EV-1 was corrected in a new record without editing the cycle-2 record, preserving the audit trail.
- The executor stopped at `human_decision_required` rather than editing PoshQC settings outside the Write Set.
