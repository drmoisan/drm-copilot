# Code Review: Epic-planner per-feature receipt-checks key gate (#543), re-review after remediation cycle 1

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-543` suffix matches the branch name.
**Base Branch:** `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head Branch:** `bug/epic-planner-receipt-checks-key-gate-543` @ `c99c528a9bbba77fa3678014f9a3b0f7f669a409`
**Review Type:** Re-review after remediation cycle 1 (prior review set `*.2026-10-16T01-36.md`)

---

## Executive Summary

The branch key-gates the per-feature `model_routing_receipt` and `topology_receipt` checks in the epic-planner execution-ready gate (cycle 0), and in cycle 1 makes every `features[i]` prefix on the epic-planner validation path use the entry's original index in the checkpoint `features` array (prior finding CR-5, extended by orchestrator decision to the dependency-wave, launch-binding, and git-integrity `planning_commit` sites). Cycle 1 also regenerated both coverage artifacts with the configured reporters, closing the prior Blocker CR-1 and Minor CR-2. Reviewed evidence: the full branch diff (142 files), `artifacts/pr_context.summary.txt` (generated 04:32 UTC at head `c99c528a9`), the cycle-1 evidence set, both lcov artifacts, and reviewer re-runs of Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (97 passed), and targeted Jest (89 passed).

**What changed in cycle 1:**
- `scripts/dev_tools/validate_epic_planner_state.py` / `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`: `_extract_features` / `extractFeatures` return `(index, feature)` pairs (TypeScript also returns the raw entries); `_validate_dependency_waves`, `_validate_ready_features`, and their twins iterate the pairs; the planner launch-binding call receives the raw checkpoint entries.
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` / `epic-orchestrator-state-launch-binding.ts`: the planner entry point's first parameter is widened (`Sequence[object]` / `readonly unknown[]`); the existing body already skips non-object entries while enumerating original positions.
- `scripts/dev_tools/epic_planner_git_integrity.py` / `epic-planner-git-integrity.ts`: new private `_pair_plans_with_features` / `pairPlansWithFeatures` match each plan, in order, to the object entry whose `plan_path` derives it, and fall back to the previous positional pairing when any plan has no such entry.
- Four new test files (two per runtime) with fail-before / pass-after evidence.

**Top 3 risks:**
1. The git-integrity pairing now reads `planning_commit` and `plan_hash` from the entry that owns the plan rather than from the compacted position. This is a behavioural correction, not only a message change, and it applies only when a non-object or plan-less entry precedes a plan's entry. It is recorded in the remediation plan ("Pairing consequence") but not in `spec.md` (CR-7).
2. The pairing helper depends on each runtime's readiness `plan_path` normalization (`PurePosixPath(...).as_posix()` in Python, identity in TypeScript). If either readiness module changes its normalization, pairing silently falls back to positional order (CR-8).
3. `epic-planner-state-core.ts` is at 495 of 500 lines (CR-4).

**PR readiness recommendation:** **Ready** - no Blocker or Major finding remains. Rebase onto `main` before opening the PR (policy-audit PA-N4).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | lines 441-443, 454-463 | CR-3 (carried, same file): the call site passes `requireLaunchPaths` as `keyGated`; the local now gates the per-feature receipts and the planner receipt as well as launch paths, and `validateReadyFeatures` takes a positional boolean while the sibling call uses an options object. | In a later change, rename the local to `keyGated` and pass an options object. | Readability only; spec-mandated form (AC10). | `git diff adb9aa5f0..HEAD -- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` |
| Info | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | whole file (495 lines) | CR-4 (carried, same file): the file is at 495 of 500 lines (488 at the prior review). | Split `validateReadyFeatures` (or the dependency-wave check) into its own module before the next addition. | Within the limit; 5 lines of headroom. | reviewer `wc -l`; `evidence/qa-gates/rc1-line-counts-final.2026-10-16T04-25.md` |
| Nit | `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py`, `test_epic_planner_git_integrity_feature_indices.py`, `test_validate_epic_planner_state_feature_receipts.py` | `ASSERTED_MESSAGES` (lines 48, 27, 38) | CR-6 (new, same feature test files): each file defines an `ASSERTED_MESSAGES` tuple that no test references. | Remove the tuples, or use them in a parity assertion. | Unused module constants; no behavioural effect. | `grep -rn ASSERTED_MESSAGES tests/` returns only the three definitions |
| Info | `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` | "Files/modules to change", AC15 | CR-7 (new, same feature): the spec lists two production and four test files; cycle 1 changed four more production files and added four test files, and changed git-integrity pairing behaviour. The scope extension is recorded only in `remediation-plan.2026-10-16T01-36.md` revision 3. | State the CR-5 extension and the pairing consequence in the PR description. Do not add AC items. | Reviewers of the PR will otherwise see changes outside the spec's file list. All extra files meet the 500-line limit and AC13's excluded-path list is untouched. | `git diff --name-status adb9aa5f0..HEAD -- . ":!docs"` (14 files) |
| Info | `scripts/dev_tools/epic_planner_git_integrity.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts` | `_plan_path` / `_pair_plans_with_features` (lines 167-209); `pairPlansWithFeatures` (lines 177-218) | CR-8 (new, same files): matching relies on each runtime reproducing its readiness module's `plan_path` normalization (Python `PurePosixPath(...).as_posix()`, TypeScript strict equality, mirroring `relativePath`). When a plan finds no entry, the helper discards the partial match and pairs all plans positionally. | Consider passing `(index, plan)` pairs from the readiness caller in a later change, which removes the re-derivation. | Correct for the current readiness callers (reviewer read `_relative_path` and `relativePath`); a future normalization change would degrade silently to the previous behaviour rather than fail. | Source reading of `scripts/dev_tools/epic_planner_readiness.py` lines 102-112 and 350-361, `epic-planner-readiness-integrity.ts` lines 32-54 and 334-346 |
| Info | `scripts/dev_tools/validate_epic_planner_state.py` | line 276 | CR-9 (new, same function, pre-existing gap): the modified condition `if len(indexed_features) < 2:` has an untaken true arm in the coverage run; the guarded line 277 was already uncovered at baseline (old line 271). | Optionally add a one-feature ready-gate test. | Not a regression; the line changed only by rename. Per-file coverage is 94.24% / 88.00%. | `artifacts/python/lcov.info` (`DA:277,0`); `evidence/remediation-baseline/rc1-baseline-python-per-file-coverage.2026-10-16T03-47.md` |
| Info | `scripts/dev_tools/epic_planner_readiness.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts` | `_relative_path` / `relativePath` | CR-10 (unrelated to this change, pre-existing): Python accepts a `plan_path` such as `./docs/x/plan.md` (`PurePosixPath` drops `.` before the `"." in parts` check) while TypeScript rejects it. | File separately if runtime parity of readiness path rules is required. | Neither file is changed on this branch. | Source reading |

Prior findings disposition: CR-1 (Blocker) closed by `evidence/qa-gates/typescript-lcov-coverage.2026-10-16T04-22.md` and the reviewer's re-derivation from `extensions/drm-copilot/coverage/lcov.info`; CR-2 (Minor) closed by `evidence/qa-gates/python-repo-wide-coverage.2026-10-16T04-18.md` (214 `SF:` records); CR-5 (Info) fixed in cycle 1.

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Index pairs are produced once in `_extract_features` and consumed by every downstream loop, so the original index is not re-derived in several places.
- `checkpoint_entries` passes the raw list to the launch-binding validator, whose existing `_validate_launch_bindings` already skips non-dict items while enumerating original positions; the redundant `cast` at the call was removed.
- `_pair_plans_with_features` keeps the exported `validate_planning_git_integrity` signature and preserves byte-identical results for direct callers whose plans are not drawn from the checkpoint (existing git-integrity and readiness tests pass unmodified).
- Error strings are unchanged: the reviewer's paired comparison of added and removed lines containing `Epic planner`, `must be`, or `must match` across all six production files found no unpaired line.

#### Typing and API notes

- `validate_epic_planner_child_launch_bindings(features: Sequence[object], ...)` widens the accepted type; every previous argument is still accepted. `Sequence` is imported under `TYPE_CHECKING` only. Pyright reports 0 errors.

#### Error handling and logging

- Validators continue to return error strings. No exceptions or logging changed.

### TypeScript implementation audit

#### What changed well

- The TypeScript twin mirrors the Python structure: `extractFeatures` returns `indexedFeatures` and the raw `entries`; the readonly tuple type `ReadonlyArray<readonly [number, Record<string, unknown>]>` prevents accidental mutation.
- `pairPlansWithFeatures` uses `entries[slot]?.[1] ?? {}` for the fallback, matching the previous `features[index] ?? {}` behaviour.

#### Type safety and maintainability

- No `any`, non-null assertions, casts, or suppressions added. `validateEpicPlannerChildLaunchBindings(features: readonly unknown[])` is a widening.
- See CR-3, CR-4, and CR-8.

#### Error handling and logging

- No change to boundary validation; failures remain aggregated error strings.

---

## Test Quality Audit

Each prefix site has a fail-before / pass-after test in both runtimes, plus unchanged-index controls and the positional-fallback and empty-input edge cases. Fail-before runs failed on pre-fix production code (Python 7 failed / 1 passed and 2 failed / 4 passed; TypeScript the same), and pass-after runs passed 14/14 in each runtime. Shared error literals are byte-identical between the twin files (reviewer comparison: 11, 4, and 5 common constants respectively, 0 mismatched).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-indices.test.ts` - ready gate (4 non-object kinds), Codex-flag receipts, dependency waves, launch bindings, unchanged control.
- `tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts` - non-object skip, plan-less skip, unchanged control, positional fallback, empty and non-list inputs.
- `evidence/regression-testing/fail-before-cr5-*.md` (exit 1) and `pass-after-cr5-*.md` (exit 0).
- `evidence/qa-gates/rc1-byte-identical-strings.2026-10-16T04-07.md`, `rc1-git-byte-identical-strings.2026-10-16T04-09.md`.
- `evidence/qa-gates/typescript-lcov-coverage.2026-10-16T04-22.md`, `python-repo-wide-coverage.2026-10-16T04-18.md`, `rc1-coverage-delta-verification.2026-10-16T04-24.md`.

### Quality assessment prompts

- **Determinism:** pure in-memory validation; git is faked.
- **Isolation:** each test targets one prefix site.
- **Speed:** 97 Python tests in 1.41s (reviewer run).
- **Diagnostics:** full-list equality where ordering matters; exact membership otherwise.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credentials; cycle 1 adds no suppressions. |
| No unsafe subprocess or command construction | N/A | No subprocess code changed; git access goes through the existing `ReadinessGitRepository` protocol. |
| Input validation at boundaries | PASS | Non-object and non-list `features` values are handled in every changed function (empty and non-list tests). |
| Error handling remains explicit | PASS | No error string added, removed, or reworded. |
| Configuration / path handling is safe | PASS | `_plan_path` only normalizes for comparison; path safety checks remain in the readiness module, which is unchanged. |
| Codex strictness preserved | PASS | Codex-flag tests from cycle 0 pass unchanged; cycle 1 adds a Codex-flag test with a shifted index. |

---

## Research Log

No external research was required. The cycle-1 design follows `remediation-plan.2026-10-16T01-36.md` revision 3, including its recorded caller analyses for the launch-binding and git-integrity entry points, which the reviewer confirmed by reading both readiness modules.

---

## Verdict

The implementation is correct and consistent across runtimes, every changed prefix site is covered by fail-before / pass-after tests, and both coverage artifacts are present with all thresholds met and no uncovered added line. All format, lint, type, and test stages pass on reviewer re-run. No blocking finding remains; CR-3, CR-4, and CR-6 to CR-10 are non-blocking.
