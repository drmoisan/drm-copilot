# Acceptance-Criteria Check-off Record (spec.md)

AC source: docs/features/active/gate-suites-read-unmocked-local-epic-state-709/spec.md, section "Acceptance Criteria" (work mode full-bug). ACn is the nth bullet of that section. Each check-off changed only that bullet's `- [ ]` to `- [x]`.

## AC1

Timestamp: 2026-09-27T10-21
Evidence:
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/pester-targeted.2026-09-27T10-15.md (N1 Passed=24, Failed=0, which includes the seven structural-guard rows)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/suite-diff-numstat.2026-09-27T10-21.md (S1-S7 each 2 insertions, 0 deletions)
Result: checked off (spec.md line 249).

## AC2

Timestamp: 2026-09-27T10-22
Evidence:
- tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 exists (committed in 6cee9940).
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/fail-before.2026-09-27T10-09.md (before any suite edit: 7 structural-guard rows failed, one per unprotected suite, each carrying "missing from outermost BeforeAll"; EXIT_CODE: 1, ExpectedExitCode: 1)
Result: checked off (spec.md line 250).

## AC3

Timestamp: 2026-09-27T10-22
Evidence:
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/pass-after.2026-09-27T10-13.md (TOTAL Passed=24, Failed=0: all 4 control and 4 treatment rows pass)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/fail-before.2026-09-27T10-09.md (the only 7 FAILED lines are structural-guard path rows; zero control or treatment rows failed)
The control rows assert IsEpicScope = $true and one read of the epic checkpoint path for the gate-1, gate-3, gate-4, and gate-4 selector shapes; the treatment rows assert IsEpicScope = $false, Reason epic-checkpoint-absent-or-unparseable, and zero invocations of Get-WorktreeResolutionGitFileText for the epic checkpoint path, Get-EpicScopeWorktreeHeadBranch, and Test-EpicScopeMergeInProgress.
Result: checked off (spec.md line 251).

## AC5

Timestamp: 2026-09-27T10-22
Evidence:
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/pester-targeted-baseline.2026-09-27T10-01.md (before)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/pester-targeted-after.2026-09-27T10-14.md (after; comparison table shows EQUAL for S1-S7)
Substitution: the before-change baseline was written to evidence/baseline/ instead of the non-canonical evidence/baselines/ named in the AC5 text (EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baselines/ replaced with docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/).
Result: checked off (spec.md line 253).

## AC6

Timestamp: 2026-09-27T10-22
Evidence:
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/scope-diff.2026-09-27T10-21.md (none of the three *.EpicScope.Tests.ps1 paths is listed by `git diff --name-only` against the merge-base or by `git status --porcelain`)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/pester-targeted-after.2026-09-27T10-14.md (EQUAL for all three EpicScope suites: 5, 4, and 19 passed before and after)
Result: checked off (spec.md line 254).

## AC7

Timestamp: 2026-09-27T10-22
Evidence:
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/scope-diff.2026-09-27T10-21.md (the union of `git diff --name-only` against merge-base 849aae609787172240c1ae7c33d10d6dd337d497 and `git status --porcelain --untracked-files=all` lists only the eight LIST-CHANGED test files and paths under docs/features/active/gate-suites-read-unmocked-local-epic-state-709/; nothing under .claude/, extensions/, or scripts/)
Result: checked off (spec.md line 255).

## AC8

Timestamp: 2026-09-27T10-22
Evidence (clean pass named in docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/qa-loop.2026-09-27T10-20.md):
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/format-check.2026-09-27T10-15.md (FORMAT-DRIFT-COUNT: 0)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/pssa.2026-09-27T10-15.md (PSSA-TOTAL: 0)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/pester-targeted.2026-09-27T10-15.md (EXIT_CODE: 0)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/pester-full.2026-09-27T10-20.md (Tests Passed: 5452, Failed: 0)
Result: checked off (spec.md line 256).

## AC9

Timestamp: 2026-09-27T10-22
Evidence:
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/coverage-epic-scope-baseline.2026-09-27T10-06.md (baseline 90.38%)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/coverage-epic-scope.2026-09-27T10-20.md (post-change 91.35%, greater than or equal to the baseline)
Result: checked off (spec.md line 257).

## AC4

Timestamp: 2026-09-27T10-47
Evidence:
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/hermeticity-scan.2026-09-27T10-20.md (HERMETICITY-MATCH-COUNT: 0, with the code-review notes)
- docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/ci-poshqc.2026-09-27T10-46.md (CI run 36326672278 on head 8d26d3f8686f628fa7d75471ad2aa75a77e5579b, job "poshqc / PowerShell QC" conclusion success; testsuite enforce-gate-suites.EpicStateIsolation.Tests.ps1 tests="24" failures="0" errors="0" skipped="0")
Result: checked off (spec.md line 252).
