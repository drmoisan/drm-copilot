# Code Review: Epic planner ready gate key-gates Codex-only launch evidence (#543)

---

**Review Date:** 2026-10-02
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Feature Folder Selection Rule:** The only active feature folder in the branch diff; its `-543` suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`)
**Head Branch:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543` @ `9ad8e5a375d1c42f7ea4511e333e873e18ffad47`
**Review Type:** Re-review after remediation cycle 1 (prior review: `code-review.2026-10-02T05-58.md`)

---

## Executive Summary

The branch corrects the #543 defect in the epic-planner execution-readiness gate. Under `require_ready_for_execution`, the gate no longer demands Codex-only launch evidence for a feature that carries neither `launch_receipt_path` nor `launch_status_path`, unless the caller asserts `require_codex_model_routing` or `require_codex_topology`. One activation value is passed to both launch call sites, in both runtimes. The MCP dispatch forwards both flags, and the three Codex guidance callers and their bundle mirrors pass both flags.

Remediation cycle 1 changed no production or test file. `git diff --stat ecbe5ba1..HEAD` lists only feature-folder paths, so the code-level assessment from the prior review stands. The reviewer re-ran Black, Ruff, Pyright, Prettier, tsc, the targeted pytest set (118 passed), and the targeted Jest set (133 passed) at head `9ad8e5a3`, and all were clean.

Prior blockers:
- **CR-1 (TypeScript coverage artifact): resolved.** `extensions/drm-copilot/coverage/lcov.info` exists. The reviewer's independent parse confirms that all five changed TypeScript files meet the floors, and that none of the 53 added lines is uncovered.
- **CR-2 (35 composed timestamps): resolved.** All 35 first-row values were corrected, each with one correction line, and the plan records `D-TIMESTAMPS`.

New blocker:
- **CR-10 (same as PA-5).** One composed `Timestamp:` value remains, in the second row of `evidence/other/python-batch-budget.2026-10-02T05-01.md`.

**What changed (code, unchanged since prior review):**
- `scripts/dev_tools/validate_epic_planner_state.py`: keyword-only `require_codex_model_routing` and `require_codex_topology`; `key_gated` is passed as `require_launch_paths` at both call sites.
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`: public `feature_carries_launch_path`; the planner wrapper forwards `require_launch_paths` and keeps `require_generated_orchestrator=True`.
- `scripts/dev_tools/epic_planner_launch_evidence.py` and `epic_planner_readiness.py`: in-loop skip and parameter forwarding.
- The five TypeScript twins under `extensions/drm-copilot/src/lib/validate/`.
- Six guidance files (three byte-identical root/bundle pairs) and six test files.

**What changed (remediation cycle 1):** 22 new evidence artifacts; first-row `Timestamp:` corrections in 35 artifacts; `## Plan Deviations` in `plan.2026-09-29T16-06.md`; AC-19 re-checked in `spec.md`.

**Top 3 risks:**
1. The Claude-runtime ready gate is still not passable end to end, because the per-feature and planner topology/model-routing receipts remain Codex-only. The PR must say "Partially addresses #543" and must not use a closing keyword.
2. A Codex caller that omits both flags and writes a keyless feature would have that feature skipped silently. Mitigation: all Codex guidance callers pass both flags, and Codex checkpoints carry launch keys by contract.
3. Evidence timestamp integrity has now needed correction twice. A whole-file scan (`grep -rn "Timestamp:"` rather than `grep -m1`) should be part of the executor's final QA.

**PR readiness recommendation:** **Needs Revision (minor)**. The code is ready. One evidence row (CR-10) must be corrected before the PR is authored.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` | line 31 (`### Reset 1 (P2-T4)`) | CR-10 (same as PA-5): `Timestamp: 2026-10-02T05-30` is later than the file's write time (05:18:16) and its last commit (`af88dd58`, 05:19:12), so the value was composed. R2 corrected only first rows, and the prior scan (`grep -m1`) did not reach this row. | Replace the value with `2026-10-02T05-18` and add one `Timestamp-Correction:` line directly below it. Optionally correct the line-3 header (`05-01`) to `05-18` in the same edit (PA-3). | `evidence-and-timestamp-conventions` line 49 applies to every `Timestamp` value and forbids composition. | `ls -l --time-style=+%H:%M:%S`; `git log --format="%h %ci" -- <file>`; `grep -rc "^Timestamp:" evidence/ \| grep -v ":1$"` |
| Minor | `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | lines 351-396 | CR-3 (carried): three `test_readiness_integrity_*` tests exercise `epic_planner_readiness` but live in the launch-binding test file. | Optionally move them to a mirror-layout file in a follow-up. Plan line 120 authorized the placement. | Test-to-module traceability. | `plan.2026-09-29T16-06.md` line 120; `spec.md` line 162 |
| Minor | `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | line 205 | CR-4 (carried): public `feature_carries_launch_path` lives in an underscore-prefixed module and is imported cross-module. | Accept as `spec.md` mandates. | API boundary clarity. | `spec.md` line 172 |
| Minor | `scripts/dev_tools/validate_orchestration_artifacts.py` | `epic-planner-state` subparser | CR-5 (carried): the Python CLI cannot assert `--require-codex-*`. | No change; recorded deviation in `spec.md` Non-goals. | Runtime divergence on one low-use entry point. | `git diff` shows the file unchanged |
| Nit | `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts` | lines 6-7 | CR-6 (carried): separate value and type imports from the same module. | Optionally merge. | Readability only. | Diff inspection |
| Nit | `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | lines 368-396 | CR-7 (carried): the non-list and non-record readiness tests assert only the absence of `features[` errors. | Optionally add a positive assertion. | Stronger oracle. | Diff inspection |
| Info | `scripts/dev_tools/validate_epic_planner_state.py` | `_validate_ready_features`, `_validate_planner_topology_receipt` call | CR-8 (carried): residual #543 scope; Codex-only receipts remain. | State "Partially addresses #543" in the PR; no closing keyword. | Keeps #543 open while its symptom persists on the Claude runtime. | `spec.md` lines 65-69, 351-355 |
| Info | `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md` | lines 484-494 | CR-9 (resolved): D1-D3 and D-TIMESTAMPS are now recorded under `## Plan Deviations`; the plan validator passed. | None. | n/a | `evidence/qa-gates/original-plan-validation.2026-10-02T07-00.md` |

There is 1 Blocker finding (CR-10, the same finding as PA-5, counted once). There are no Major findings. CR-1 and CR-2 from the prior review are resolved and no longer listed as findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `key_gated = not (require_codex_model_routing or require_codex_topology)` is computed once and reused at both call sites.
- The skip in `validate_epic_planner_launch_evidence` sits after the `_is_record` guard, so a skipped feature contributes no status path to the shared-status comparison.
- Every new parameter is keyword-only with a pre-fix default.
- `require_generated_orchestrator=True` is preserved (AC-11).

#### Typing and API notes

- `feature_carries_launch_path(feature: Mapping[str, object]) -> bool` removes an `Any` from the signature. Pyright reports 0 errors at 9ad8e5a3.

#### Error handling and logging

- No error string was added, removed, or reworded. No logging changes.

### TypeScript implementation audit

#### What changed well

- `requireLaunchPaths = options.requireCodexModelRouting !== true && options.requireCodexTopology !== true` mirrors the Python predicate.
- The exported `LaunchPathGateOptions` interface is declared once and shared by three validators.
- The dispatch uses the conditional-spread pattern of the adjacent `epic-orchestrator-state` case.

#### Type safety and maintainability

- No `any`, suppressions, or non-null assertions in production code. `tsc --noEmit` exits 0 at 9ad8e5a3.

#### Error handling and logging

- Validation remains fail-closed for any feature that carries a key, including a present key with an empty or `null` value.

---

## Test Quality Audit

All 20 acceptance-criterion tests exist with the exact names in `spec.md`, and the reviewer's re-run at 9ad8e5a3 gave 118 pytest and 133 Jest passes. With the R2 corrections, the recorded fail-before timestamps are now consistent with the commit order: `fail-before-python` records `05-15` and `fail-before-typescript` records `05-16`, both before the fix commit `af88dd58` (05:19:12). `pass-after-python` records `05-18`, which is before that commit time, but the file was written after the fix was made in the working tree and was committed with the fix. The reviewer treats this as consistent: the value is an upper bound taken from the write time.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/coverage/lcov.info`: written 06:53:09, after the last TypeScript code commit (05:45:42). Reviewer per-file parse: `epic-orchestrator-state-launch-binding.ts` 96.11% lines / 93.28% branches; `epic-planner-launch-evidence.ts` 92.75 / 84.48; `epic-planner-readiness-integrity.ts` 91.62 / 84.29; `epic-planner-state-core.ts` 98.30 / 93.58; `orchestration-artifacts.ts` 100 / 97.56. Added-line intersection with zero-hit rows: empty for all five files (53 added lines).
- `evidence/qa-gates/typescript-coverage-run.2026-10-02T06-52.md`: 250 suites and 3794 tests passed, exit 0. `npm run test:coverage` expands to `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=text`. No prohibited flag was passed.
- `evidence/qa-gates/typescript-lcov-coverage.2026-10-02T06-54.md`: its values match the reviewer's parse to two decimals. The differences are truncation versus rounding, for example 84.28 versus 84.29.
- `evidence/qa-gates/timestamp-correction-verification.2026-10-02T06-59.md`: 35 matches and 0 mismatches against the prior blobs. The reviewer confirmed this independently with first-row `grep` and the correction-line count.
- `artifacts/python/lcov.info` and `artifacts/pester/pester-junit.xml`: unchanged since the prior review. Both remain valid because no code or guidance file changed.

### Quality assessment prompts

- **Determinism:** In-memory fixtures and `VirtualFileSystem`; no clock or randomness.
- **Isolation:** Each test builds its own state and covers one activation case.
- **Speed:** 0.37 s (pytest) and 1.23 s (Jest) for the targeted sets.
- **Diagnostics:** Exact-list assertions print the full error list on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess changes. |
| Input validation at boundaries | ✅ PASS | The key-membership predicate is applied only after the `_is_record` / `isRecord` guards. |
| Error handling remains explicit | ✅ PASS | Error strings unchanged; validation for keyed features unchanged. |
| Configuration / path handling is safe | ✅ PASS | No path handling changed. |
| Fail-closed default for Codex callers | ✅ PASS | All six guidance files assert both flags. Reviewer `sha256sum` confirms byte-identical pairs at 9ad8e5a3. |

---

## Research Log

No external research was required. Design context comes from `research/research.2026-09-29T16-10.md` (Approach A) and the #524 precedent on `main`.

---

## Verdict

The implementation is correct, minimal, and consistent across both runtimes. The coverage evidence is now backed by artifacts in both changed coverage languages, and the 35 timestamp corrections are in place. One evidence row remains to be corrected (CR-10/PA-5): a one-line edit with a correction note. No code change is required. After that edit, the PR should be authored with "Partially addresses #543" (CR-8).
