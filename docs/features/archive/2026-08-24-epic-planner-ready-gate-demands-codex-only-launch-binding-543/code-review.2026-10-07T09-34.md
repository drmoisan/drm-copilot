# Code Review: Epic planner ready gate key-gates Codex-only launch evidence (#543)

---

**Review Date:** 2026-10-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Feature Folder Selection Rule:** The only active feature folder in the branch diff; its `-543` suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`; `origin/main` was merged into the branch at `592c91ea`)
**Head Branch:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543` @ `1186467ab3fafe06cf698902cf2e7c7b5fd3ab17`
**Review Type:** Re-review after remediation cycle 2 (pass 3; prior reviews: `code-review.2026-10-02T05-58.md`, `code-review.2026-10-02T07-08.md`)

---

## Executive Summary

The branch corrects the #543 defect in the epic-planner execution-readiness gate. Under `require_ready_for_execution`, the gate no longer demands Codex-only launch evidence for a feature that carries neither `launch_receipt_path` nor `launch_status_path`, unless the caller asserts `require_codex_model_routing` or `require_codex_topology`. One activation value is passed to both launch call sites in both runtimes. The MCP dispatch forwards both flags, and the three Codex guidance callers and their bundle mirrors pass both flags.

Remediation cycle 2 changed one evidence file and added 15 evidence artifacts plus the cycle-2 plan. `git diff --name-only 592c91ea HEAD` lists only feature-folder paths. The `origin/main` merge (`592c91ea`) shares no file with the branch's 21 non-feature-folder files. The reviewer re-ran Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (118 passed), and targeted Jest (170 plus 28 passed) at head `1186467a`; all were clean.

Prior blocker:
- **CR-10 (same as PA-5): resolved.** The R1 row in `evidence/other/python-batch-budget.2026-10-02T05-01.md` (now line 32) reads `Timestamp: 2026-10-02T05-18`, followed by one `Timestamp-Correction:` line naming `2026-10-02T05-30`. The optional N1 header correction was also applied.

New non-blocking item:
- **CR-11 (same as PA-6, Minor).** The N1 header value `05-18` is later than the commit that first contained that header row (`0c6abb95`, 05:14:57). It was prescribed by the pass-2 review, it is observation-derived and disclosed, and it is not composed. A tighter value of `05-14` is available.

**What changed (code, unchanged since pass 1):**
- `scripts/dev_tools/validate_epic_planner_state.py`: keyword-only `require_codex_model_routing` and `require_codex_topology`; `key_gated` passed as `require_launch_paths` at both call sites.
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`: public `feature_carries_launch_path`; planner wrapper forwards `require_launch_paths` and keeps `require_generated_orchestrator=True`.
- `scripts/dev_tools/epic_planner_launch_evidence.py` and `epic_planner_readiness.py`: in-loop skip and forwarding.
- Five TypeScript twins under `extensions/drm-copilot/src/lib/validate/`.
- Six guidance files (three byte-identical pairs) and six test files.

**What changed (remediation cycle 2):** R1 and N1 edits in one evidence file; 15 new evidence artifacts under `evidence/remediation-baseline/`, `evidence/other/`, and `evidence/qa-gates/`; `remediation-plan.2026-10-02T07-08.md` (22 of 22 boxes checked).

**Top 3 risks:**
1. The Claude-runtime ready gate is still not passable end to end, because `_validate_planner_topology_receipt` and the per-feature topology/model-routing receipts remain Codex-only. This is outside the spec's acceptance criteria. The PR must say "Partially addresses #543" and must not use a closing keyword.
2. A Codex caller that omits both flags and writes a keyless feature would have that feature skipped silently. Mitigation: all Codex guidance callers pass both flags (pairs byte-identical at `1186467a`).
3. The Pester contract file `codex-epic-runtime-contracts.Tests.ps1` also reads `.codex/config.toml`, which the `origin/main` merge changed. The last local Pester JUnit predates that merge. Per plan deviation D3, the CI `poshqc` job on the PR is the confirming run; no PR or CI run exists yet.

**PR readiness recommendation:** **Ready.** No blocking finding remains. CR-11 is an optional evidence refinement.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` | lines 3-4 | CR-11 (same as PA-6): the N1 header value `2026-10-02T05-18` is later than the commit that first contained the header row (`0c6abb95`, 05:14:57), so the line-4 claim "an upper bound on the write time" is inaccurate for this row. The value meets the cycle-2 definition of done as written, is observation-derived, and is disclosed. | Optionally change line 3 to `2026-10-02T05-14` and cite `0c6abb95` as the upper bound on line 4. | Evidence-first wording: an upper-bound claim should hold for the row it annotates. | `git log --format="%h %ci" -- <file>`; `git show 0c6abb95:<file>` (line 3 present) |
| Minor | `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | lines 351-396 | CR-3 (carried): three `test_readiness_integrity_*` tests exercise `epic_planner_readiness` but live in the launch-binding test file. | Optionally move them to a mirror-layout file in a follow-up. Plan line 120 authorized the placement. | Test-to-module traceability. | `plan.2026-09-29T16-06.md` line 120 |
| Minor | `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | line 205 | CR-4 (carried): public `feature_carries_launch_path` lives in an underscore-prefixed module and is imported cross-module. | Accept as `spec.md` mandates. | API boundary clarity. | `spec.md` line 172 |
| Minor | `scripts/dev_tools/validate_orchestration_artifacts.py` | `epic-planner-state` subparser | CR-5 (carried): the Python CLI cannot assert `--require-codex-*`. | No change; recorded in `spec.md` Non-goals. | Runtime divergence on one low-use entry point. | File unchanged on the branch |
| Nit | `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts` | lines 6-7 | CR-6 (carried): separate value and type imports from the same module. | Optionally merge. | Readability only. | Diff inspection |
| Nit | `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | lines 368-396 | CR-7 (carried): the non-list and non-record readiness tests assert only the absence of `features[` errors. | Optionally add a positive assertion. | Stronger oracle. | Diff inspection |
| Info | `scripts/dev_tools/validate_epic_planner_state.py` | `_validate_planner_topology_receipt` call; `_validate_ready_features` | CR-8 (carried, informational): residual #543 scope; the planner topology receipt check is still unconditional and the per-feature Codex receipts remain. | State "Partially addresses #543" in the PR; no closing keyword. | Keeps #543 open while its symptom persists on the Claude runtime. | `spec.md` Non-goals; Rollout & Follow-up |

There are 0 Blocker and 0 Major findings. CR-10 from pass 2 is resolved and is no longer listed.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `key_gated = not (require_codex_model_routing or require_codex_topology)` is computed once and reused at both call sites.
- The skip in `validate_epic_planner_launch_evidence` sits after the `_is_record` guard, so a skipped feature contributes no status path to the shared-status comparison.
- Every new parameter is keyword-only with a pre-fix default.
- `require_generated_orchestrator=True` is preserved (AC-11).

#### Typing and API notes

- `feature_carries_launch_path(feature: Mapping[str, object]) -> bool`. Pyright exits 0 at `1186467a`.

#### Error handling and logging

- No error string added, removed, or reworded. No logging changes.

### TypeScript implementation audit

#### What changed well

- `requireLaunchPaths = options.requireCodexModelRouting !== true && options.requireCodexTopology !== true` mirrors the Python predicate.
- `LaunchPathGateOptions` is declared once and shared by three validators.
- The dispatch uses the conditional-spread pattern of the adjacent `epic-orchestrator-state` case.

#### Type safety and maintainability

- No `any`, suppressions, or non-null assertions in production code. `tsc --noEmit` and ESLint exit 0 at `1186467a`.

#### Error handling and logging

- Validation remains fail-closed for any feature that carries a key, including a present key with an empty or `null` value.

---

## Test Quality Audit

All 20 acceptance-criterion tests exist with the names in `spec.md`. Reviewer re-runs at `1186467a`: 118 pytest passes over the six targeted files; 170 Jest passes over the 12 epic validator suites; 28 passes in `orchestration-artifacts.test.ts`.

### Reviewed test and QA artifacts

- `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info`: re-parsed in this pass; per-file values match pass 2 exactly. Both predate the `origin/main` merge, which shares no file with the branch, so the per-file values describe the head code.
- `evidence/remediation-baseline/d4-merge-intersection.2026-10-07T09-24.md`: `branch_changed=112 merge_changed=288 intersection=0`. The reviewer's independent intersection (non-feature-folder branch files against `git diff --name-only ef80c57d f6ef5b2f`) is also empty.
- `evidence/qa-gates/composed-row-absence.2026-10-07T09-26.md`, `timestamp-rows-scan-after.2026-10-07T09-26.md`, `correction-line-counts-after.2026-10-07T09-26.md`: consistent with the reviewer's own `git grep` counts (99 `Timestamp:` rows; only `python-batch-budget` at count 2; 36 files with a `Timestamp-Correction:` line, one of them at count 2).
- Whole-tree scan by the reviewer: each `Timestamp:` value was compared with the add-commit time of its file. 97 of 99 rows are at or before it. The two `python-batch-budget` rows (`05-18`) are later than its add commit (05:14:57); the R1 row was introduced in `af88dd58` (05:19:12) and is consistent, and the header row is CR-11.
- `artifacts/pester/pester-junit.xml` (2026-10-02 05:44): `codex-epic-runtime-contracts.Tests.ps1` tests=10, failures=0. See risk 3 for the merged-head route.

### Quality assessment prompts

- **Determinism:** In-memory fixtures and `VirtualFileSystem`; no clock or randomness.
- **Isolation:** Each test builds its own state and covers one activation case.
- **Speed:** 0.42 s for the six targeted pytest files.
- **Diagnostics:** Exact-list assertions print the full error list on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess changes. |
| Input validation at boundaries | ✅ PASS | Key-membership predicate applied after the `_is_record` / `isRecord` guards. |
| Error handling remains explicit | ✅ PASS | Error strings unchanged; validation for keyed features unchanged. |
| Configuration / path handling is safe | ✅ PASS | No path handling changed. |
| Fail-closed default for Codex callers | ✅ PASS | All six guidance files assert both flags; reviewer `sha256sum` pairs identical at `1186467a`. |

---

## Research Log

No external research was required. Design context comes from `research/research.2026-09-29T16-10.md` (Approach A) and the #524 precedent on `main`.

---

## Verdict

The implementation is correct, minimal, and consistent across both runtimes, and it is unchanged since pass 1. The pass-2 blocker (CR-10) is resolved, and the reviewer's toolchain re-run at `1186467a` is clean. One optional evidence refinement remains (CR-11). The PR may be authored, stating "Partially addresses #543" (CR-8), with the CI `poshqc` job confirming the Pester contract at the merged head.
