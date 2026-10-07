# Code Review: Epic planner ready gate key-gates Codex-only launch evidence (#543)

---

**Review Date:** 2026-10-02
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Feature Folder Selection Rule:** The only active feature folder in the branch diff; its `-543` suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`)
**Head Branch:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543` @ `ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81`
**Review Type:** Initial review

---

## Executive Summary

The branch corrects the #543 defect in the epic-planner execution-readiness gate. The gate demanded Codex-only launch evidence (`launch_receipt_path`, `launch_status_path`, branch, worktree, and delegation bindings) for every feature, which no Claude-runtime producer writes. The fix follows the #524 precedent. One activation value is computed per validation call, true unless either Codex enforcement flag is asserted, and passed to both launch-evidence call sites: the launch-binding validator and the launch-evidence validator reached through readiness integrity. A feature that carries neither launch-path key is skipped inside the existing loops, so error indices and the shared-status-path rule are preserved. The TypeScript runtime mirrors the Python change exactly, the MCP `epic-planner-state` dispatch now forwards both Codex flags, and the three Codex guidance callers and their bundle mirrors assert both flags so Codex enforcement stays unconditional.

The production delta is 9 files and about 90 changed lines across two runtimes. It is minimal, symmetric, and well documented. The reviewer re-ran Black, Ruff, Pyright, Prettier, tsc, the targeted pytest suites (118 passed), and the targeted Jest suites (133 passed); all are clean. The two blocking items are evidence defects, not code defects: no TypeScript coverage artifact, and composed evidence timestamps.

**What changed:**
- `scripts/dev_tools/validate_epic_planner_state.py`: new keyword-only `require_codex_model_routing` and `require_codex_topology`; `key_gated` is passed as `require_launch_paths` at lines 340-344 and 359-361.
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`: `_carries_launch_path` becomes public `feature_carries_launch_path(feature: Mapping[str, object])`; `validate_epic_planner_child_launch_bindings` forwards `require_launch_paths` and keeps `require_generated_orchestrator=True`.
- `scripts/dev_tools/epic_planner_launch_evidence.py` and `epic_planner_readiness.py`: in-loop skip and parameter forwarding.
- The five TypeScript twins under `extensions/drm-copilot/src/lib/validate/`, including a new exported `LaunchPathGateOptions` interface and conditional-spread flag forwarding in `orchestration-artifacts.ts`.
- Six guidance files (three byte-identical root/bundle pairs).
- Six test files.

**Top 3 risks:**
1. The Claude-runtime ready gate is still not passable end to end. Per-feature `model_routing_receipt` / `topology_receipt` and the top-level planner `topology_receipt` remain Codex-only (`spec.md` Rollout & Follow-up; #543 comment of 2026-09-30). The PR must say "Partially addresses #543" and must not use a closing keyword.
2. A Codex caller that omits both flags and writes a keyless feature would have that feature skipped silently. Mitigation: all Codex guidance callers now pass both flags, and Codex checkpoints carry launch keys by contract. The Python CLI cannot assert the flags at all (documented deviation).
3. TypeScript per-file coverage for four of the five changed production files rests only on transcribed text output. Jest `coverageThreshold` gates only `orchestration-artifacts.ts`.

**PR readiness recommendation:** **Needs Revision**: the code is ready, but two blocking evidence findings (TypeScript coverage artifact, composed timestamps) must be corrected before the PR is authored.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/coverage/lcov.info` (absent) | n/a | CR-1 (same as PA-1): no TypeScript coverage artifact exists. The recorded run passed `--coverageReporters=text --coverageReporters=text-summary`, which overrides the configured `lcov` reporter. | From `extensions/drm-copilot/`, run `node run-jest.cjs --coverage` with the configured reporters, so that `extensions/drm-copilot/coverage/lcov.info` is written. Record per-file LF/LH/BRF/BRH for the five changed production files in a new `evidence/qa-gates/` artifact. | The review contract requires artifact-based coverage verification for every language with changed files. `coverageThreshold` gates only `orchestration-artifacts.ts`, so exit 0 does not establish the floors for the other four files. | `jest.config.cjs` lines 18-19 and 98; `evidence/qa-gates/final-typescript-test-coverage.2026-10-02T06-35.md` line 6; `ls` of both candidate paths |
| Blocker | `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/` | 35 files under `regression-testing/` and `qa-gates/` | CR-2 (same as PA-2): `Timestamp:` values and filename suffixes are later than the files' write times and their commit times, by 4 to 67 minutes. They follow a fixed 5-minute schedule rather than clock readings. | Replace each `Timestamp:` row value with the observed write-time minute, add one `Timestamp-Correction:` line per file, and add a plan deviation entry. See `remediation-inputs.2026-10-02T05-58.md` R2. | `evidence-and-timestamp-conventions` line 49 forbids composed timestamps. `fail-before-python` (`05-20`) then appears to post-date the fix commit `af88dd58` (05:19:12), which inverts the recorded fail-before ordering. | `ls -l --time-style=+%H:%M:%S` of `evidence/*/`; `git log --format=%ci`; `grep -m1 ^Timestamp:` |
| Minor | `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | lines 351-396 | CR-3: three `test_readiness_integrity_*` tests exercise `epic_planner_readiness.validate_epic_readiness_integrity` but live in the launch-binding test file. `spec.md` line 162 directs additional tests to new files that mirror the source layout. | Optionally move them to a new `tests/scripts/dev_tools/test_epic_planner_readiness_branches.py` in a follow-up. Plan line 120 authorized the current placement, so no change is required in this cycle. | Test-to-module traceability. `test_epic_planner_readiness.py` is at 491 lines and cannot receive them. | `plan.2026-09-29T16-06.md` line 120; `spec.md` line 162 |
| Minor | `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | line 205 | CR-4: `feature_carries_launch_path` is public but lives in an underscore-prefixed (module-private) module, and is now imported by `epic_planner_launch_evidence.py`. | Accept as `spec.md` mandates. If the module is renamed later, move the predicate to a non-underscore module. | Cross-module imports from a private-named module blur the public API boundary. | `epic_planner_launch_evidence.py` lines 12-14; `spec.md` line 172 |
| Minor | `scripts/dev_tools/validate_orchestration_artifacts.py` | `epic-planner-state` subparser | CR-5: the Python CLI still cannot assert `--require-codex-*`, so the CLI route always gets key-gated behaviour. | No change in this PR. The deviation is recorded in `spec.md` Non-goals; track CLI parity with the conditional follow-up there. | The behaviour of the two runtimes diverges on one entry point. Impact is low because no production caller uses the Python CLI for this artifact type. | `spec.md` lines 64, 356; `git diff` shows the file unchanged |
| Nit | `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts` | lines 6-7 | CR-6: separate value and type `import` statements from the same module (`./epic-orchestrator-state-launch-binding`). The same pattern appears in `epic-planner-state-launch-binding.test.ts` lines 4-5. | Optionally merge into `import { featureCarriesLaunchPath, type LaunchPathGateOptions } from ...`. | Minor readability. ESLint passes. | Diff inspection |
| Nit | `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | lines 368-396 | CR-7: the non-list and non-record readiness tests assert only that no error contains `features[`. They would also pass if readiness integrity returned no errors at all. | Optionally add a positive assertion, for example that the kickoff or artifact-source errors are still present. | A stronger oracle guards against a regression that short-circuits the whole function. | Diff inspection |
| Info | `scripts/dev_tools/validate_epic_planner_state.py` | `_validate_ready_features` (241-275), `_validate_planner_topology_receipt` call | CR-8: residual #543 scope. Per-feature `model_routing_receipt` / `topology_receipt` and the planner `topology_receipt` remain Codex-only, so a Claude-prepared checkpoint still fails `require_ready_for_execution`. No separate follow-up issue was found (`gh issue list --search "topology receipt planner"`). The gap is tracked only in the #543 comment. | State "Partially addresses #543" in the PR. Do not use a closing keyword, and keep #543 open for the receipt checks. | Prevents #543 from auto-closing while its reported symptom persists on the Claude runtime. | `spec.md` lines 65-69, 351-355; PR context `Issue digests` #543 comment |
| Info | `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md` | n/a | CR-9: deviations D1-D3 (merge-base literal, PowerShell substitution routes) are cited throughout the evidence but not recorded in the plan. The 17 Phase 0 baseline artifacts reuse one `05-01` reading (PA-3). | Record D1-D3 and the timestamp correction in a plan deviations section in the same remediation pass as CR-2. | Keeps the plan the single record of executed deviations. | `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`; `evidence/baseline/scope-anchor.2026-10-02T05-01.md` |

There are 2 Blocker findings (CR-1 and CR-2; they are the same findings as PA-1 and PA-2 and are counted once). There are no Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The activation value `key_gated = not (require_codex_model_routing or require_codex_topology)` is computed once inside the `require_ready_for_execution` block and reused at both call sites. This matches the spec's single-predicate design.
- The skip is placed after the `_is_record` guard and before receipt and status processing in `validate_epic_planner_launch_evidence`, so a skipped feature contributes no status path to the "must share one launch_status_path" comparison.
- Every new parameter is keyword-only with a pre-fix default. Existing callers of `validate_epic_readiness_integrity`, `validate_epic_planner_launch_evidence`, and `validate_epic_planner_child_launch_bindings` are unaffected.
- `require_generated_orchestrator=True` is preserved (`_epic_orchestrator_state_launch_binding.py` line 277), as AC-11 requires.

#### Typing and API notes

- `feature_carries_launch_path(feature: Mapping[str, object]) -> bool` widens the accepted type from `dict[str, Any]`, removing an `Any` from the signature. The `Mapping` import is under `TYPE_CHECKING`, which is correct with `from __future__ import annotations`.
- New public API surface: `feature_carries_launch_path`, and the keyword arguments `require_codex_model_routing`, `require_codex_topology`, and `require_launch_paths`. Pyright reports 0 errors.

#### Error handling and logging

- No error string was added, removed, or reworded. The twin tests assert byte-identical strings across runtimes. No logging changes.

### TypeScript implementation audit

#### What changed well

- `requireLaunchPaths = options.requireCodexModelRouting !== true && options.requireCodexTopology !== true` mirrors the Python predicate and treats `undefined` as false.
- The exported `LaunchPathGateOptions` interface is shared by the launch-binding, launch-evidence, and readiness-integrity validators, so the option is declared once.
- The `orchestration-artifacts.ts` dispatch uses the same conditional-spread pattern as the adjacent `epic-orchestrator-state` case, so an absent flag is not forwarded as `undefined`.

#### Type safety and maintainability

- No `any`, no suppressions, and no non-null assertions in production code. Test files use `!` on fixture array elements, as the surrounding tests already do. `tsc --noEmit` exits 0.

#### Error handling and logging

- Validation remains fail-closed for any feature that carries a key; a present key with an empty or `null` value still arms the gate (AC-6 twin).

---

## Test Quality Audit

All 20 acceptance-criterion tests exist with the exact names in `spec.md`. The reviewer confirmed they pass: the targeted pytest set gave 118 passed and the targeted Jest set gave 7 suites and 133 passed. The fail-before and pass-after pairs for the primary regression test are on disk in both runtimes, and the commit order supports the fail-before claim: test commit `0a5b90d2` at 05:16:31, fail-before files written 05:15-05:16, fix commit `af88dd58` at 05:19:12. The recorded `Timestamp:` values do not support that order (CR-2).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`: covers the skip, partial, Codex-flag, index-preservation, and empty-value cases, plus three branch-coverage tests for readiness integrity. Assertions use exact list equality on filtered launch-binding errors.
- `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py`: two direct unit tests of `require_launch_paths` on the launch-evidence validator.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`: an updated source-text contract and a new guidance contract that whitespace-normalizes and checks all six guidance files.
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts`, `epic-planner-launch-evidence.test.ts`, `validate-orchestration-service-call.test.ts`: TypeScript twins and the MCP dispatch threading test.
- `artifacts/pester/pester-junit.xml`: `codex-epic-runtime-contracts.Tests.ps1` 10 of 10 passed, including `keeps root and tracked bundle runtime copies byte-identical`. Written 05:44:43, after the guidance commit.
- `artifacts/python/lcov.info`: written after the last Python commit. All four changed modules are at least 85% lines and 75% branches, and no added line is uncovered.
- `evidence/qa-gates/final-typescript-test-coverage.2026-10-02T06-35.md`: a text-only transcription (CR-1).

### Quality assessment prompts

- **Determinism:** In-memory fixtures and `VirtualFileSystem`; no clock or randomness.
- **Isolation:** Each test builds its own state and covers one activation case.
- **Speed:** 0.79 s (pytest) and 2.07 s (Jest) for the targeted sets.
- **Diagnostics:** Exact-list assertions print the full error list on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess changes. |
| Input validation at boundaries | ✅ PASS | The key-membership predicate is applied only after the `_is_record` / `isRecord` guards. |
| Error handling remains explicit | ✅ PASS | Error strings are unchanged; validation for keyed features is unchanged. |
| Configuration / path handling is safe | ✅ PASS | No path handling changed. The existing `launch_status_path` prefix check still applies to every validated feature. |
| Fail-closed default for Codex callers | ✅ PASS | All six guidance files assert both flags (reviewer `sha256sum` confirms byte-identical pairs). The Codex launcher writes launch keys, which arm the gate even without flags. |

---

## Research Log

No external research was required. Design context comes from `research/research.2026-09-29T16-10.md` (Approach A) and the #524 precedent already on `main`.

---

## Verdict

The implementation is correct, minimal, and consistent across both runtimes, and every acceptance-criterion test passes under the reviewer's independent re-run. The code itself needs no change.

The branch is not ready for PR authoring until two evidence defects are corrected. CR-1/PA-1: produce and record a TypeScript lcov coverage artifact. CR-2/PA-2: correct the 35 composed evidence timestamps. Both are autonomous evidence-only remediations. After they are resolved, the PR should be authored with "Partially addresses #543" (CR-8).
