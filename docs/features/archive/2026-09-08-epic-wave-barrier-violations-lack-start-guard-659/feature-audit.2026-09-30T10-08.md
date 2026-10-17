# Feature Audit: epic-wave-barrier-violations-lack-start-guard (Issue #659)

- Timestamp: 2026-09-30T10-08
- Branch: `bug/epic-wave-barrier-violations-lack-start-guard-659` at `bcc1e260`
- Reviewer: feature-review agent

## Scope and Baseline

- Base: `origin/main`, merge base `a24a1ce30c4c386d8ff2529f5b904092c3f12a52`. `origin/main` has since advanced to `2b0121ab` (#804); the trial merge is clean and #804 touches no branch path.
- Audit scope: full `origin/main...HEAD` diff (56 files).
- Work mode: `minor-audit`, read from `issue.md` (`- Work Mode: minor-audit`). AC source: `issue.md`, section `## Acceptance Criteria` only. `spec.md` and `user-story.md` are absent from the feature folder, as the mode requires (confirmed by directory listing and by `evidence/qa-gates/minor-audit-end-state.md`).
- Baseline behavior (from `issue.md` and research): `_validate_wave_barrier_ordering` emitted `EPIC_WAVE_BARRIER_VIOLATION: <f> started before dependency <d> merged` for every edge whose dependency was not merged, whether or not the dependent had started, so a kickoff checkpoint reported one violation per edge. The TypeScript port had the same behavior.
- Plan: `plan.2026-09-29T21-21.md` v1.3; 57 of 57 checklist items checked.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Initial state at review |
|---|---|---|
| AC-1 | Unstarted dependent (`not_started`, no `worktree_created_at`) with an unmerged dependency produces no violation | checked |
| AC-2 | Started dependent (other status, string `worktree_created_at`, or absent / non-string status) with an unmerged dependency produces exactly one violation per violated edge | checked |
| AC-3 | Timing violation still reported; started dependent whose dependencies merged before it started produces none | checked |
| AC-4 | Error text corrected, prefix retained, names dependent and dependency; SKILL.md and bundled mirror updated | checked |
| AC-5 | TypeScript applies the same guard with byte-identical strings across the AC-1 to AC-3 matrix, asserted by Jest | checked |
| AC-6 | Epic #678 shape and kickoff shape produce zero violations in Python and TypeScript | checked |
| AC-7 | Python and TypeScript toolchains pass; line >= 85%, branch >= 75% on changed modules; no changed file > 500 lines; no changed-line regression | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | Fixture cases `unstarted-dependent-unmerged-dependency` and `unstarted-dependent-null-timestamp` expect `[]`. They failed before the fix (`evidence/regression-testing/fail-before-python.md`) and pass after (`pass-after-python.md`; reviewer re-run 93 passed). The function named in the criterion was relocated to `validate_wave_barrier_ordering` in `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` and is still reached through `validate_epic_orchestrator_state_text`, the path the tests exercise. The relocation does not change the observable behavior the criterion describes. |
| AC-2 | PASS | Cases `started-by-status-unmerged-dependency`, `merge-status-absent-treated-as-started`, `merge-status-null-treated-as-started`, `not-started-with-timestamp-treated-as-started`, and `dependency-merge-status-absent` each expect exactly one error; `two-unmerged-dependencies-in-order` expects one error per edge, in order; `status-and-timing-on-one-edge` confirms a single error when both conditions hold. `test_feature_has_started` covers integer and absent status. |
| AC-3 | PASS | `merged-dependency-confirmed-after-start` expects the timing error; `dependencies-merged-before-start` expects `[]` (this case passed both before and after, as intended). |
| AC-4 | PASS | New strings: `EPIC_WAVE_BARRIER_VIOLATION: <f> is treated as started while dependency <d> is not merged` (status case) and `EPIC_WAVE_BARRIER_VIOLATION: <f> worktree_created_at precedes dependency <d> merge_confirmed_at` (timing case). Each is accurate for the only condition that emits it, keeps the prefix, and names both features. `.claude/skills/epic-orchestrate/SKILL.md` and its bundled mirror both move to blob `53137cfd` in the diff (identical content). Old text absent from all sites (`evidence/qa-gates/old-text-absence.md`, supported by a positive calibration query). |
| AC-5 | PASS | `hasStarted` and the guard in `validateWaveBarrierOrdering` mirror the Python predicate and control flow. `epic-orchestrator-state-wave-barrier.test.ts` asserts the same 14 fixture cases with `toEqual` on the full ordered barrier-error list, which is a byte-level string comparison. All 16 tests pass (`pass-after-typescript.md`; reviewer re-run 47 of 47 across both suites). |
| AC-6 | PASS | Cases `epic-678-checkpoint-shape` and `kickoff-all-not-started` expect `[]` and pass in both runtimes; both failed before the fix in both runtimes. |
| AC-7 | PASS | Python: black, ruff, pyright clean (reviewer re-run); 92 passed in the coverage run. TypeScript: extension format, lint, typecheck clean; 3331 of 3331 tests passed. Coverage: helper 100.00% / 100.00%, validator 96.85% / 93.55%, TypeScript core 97.96% / 91.11%; changed-line 100.00% in all three files; no regression. Largest changed file 496 lines. Note: the new JSON fixture is not Prettier-formatted (policy audit O-1). It is neither a Python nor a TypeScript source file, and the declared TypeScript format gate passes, so the criterion is met; the reviewer recommends formatting it. |

## Summary

All seven acceptance criteria are delivered and verified against evidence. The reviewer re-ran the Python toolchain and the scoped Python and Jest suites at head `bcc1e260` and re-derived all coverage values from the existing lcov artifacts; results match the executor's evidence.

- Overall feature verdict: **PASS**
- Blocking findings: 0
- Non-blocking findings: 5 in the code review (1 Minor, 4 Advisory) and 4 observations in the policy audit, overlapping. No remediation-inputs artifact is required.

The executor's three flagged notes ([P2-T13] environmental-only parity, [P2-T10] JSON-reporter per-test status, [P2-T11] hook-denied non-plan wrapper) were evaluated and accepted; reasons are recorded in the policy audit section 8.

## Acceptance Criteria Check-off

- No change to `issue.md` was needed. All seven items were already `- [x]`, and each evaluates PASS above, so each stays checked. No item was unchecked, because no FAIL, PARTIAL, or UNVERIFIED verdict was recorded.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/issue.md` (`## Acceptance Criteria`)
- Total AC items: 7
- Checked off (delivered): 7
- Remaining (unchecked): 0
- Items remaining: none
