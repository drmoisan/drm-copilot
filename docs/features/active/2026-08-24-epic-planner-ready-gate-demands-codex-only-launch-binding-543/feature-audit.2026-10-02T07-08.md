# Feature Audit: Epic planner ready gate key-gates Codex-only launch evidence (#543)

---

**Audit Date:** 2026-10-02
**Feature Folder:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Base Branch:** `main`
**Head Branch:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1 (prior audit: `feature-audit.2026-10-02T05-58.md`)

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`)
- **Head branch/commit:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543` (commit `9ad8e5a375d1c42f7ea4511e333e873e18ffad47`)
- **Merge base:** `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-02 11:04:39 UTC at head `9ad8e5a3`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (same generation)
  - Feature evidence: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/**`
  - Additional evidence: reviewer re-runs at 9ad8e5a3 (targeted pytest 118 passed; targeted Jest 133 passed; Black, Ruff, Pyright, Prettier, and tsc clean); reviewer parse of `extensions/drm-copilot/coverage/lcov.info` and `artifacts/python/lcov.info`; `sha256sum` of the guidance pairs
- **Feature folder used:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
- **Requirements source:** `spec.md` (section `## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` reads `- Work Mode: full-bug`, so `spec.md` is the sole AC source. `spec.md` line 9 states that no `user-story.md` exists.
- **Scope note:** The audit covers the full branch diff. Remediation cycle 1 changed no production, test, or guidance file (`git diff --stat ecbe5ba1..HEAD`). The Codex-only planner `topology_receipt` check and the per-feature receipts reported on #543 are outside this spec's acceptance criteria (`spec.md` Non-goals; Rollout & Follow-up). They are recorded below as residual issue scope.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` (only source)

### Acceptance criteria

1. `test_ready_gate_skips_launch_binding_for_feature_without_launch_paths` validates a ready checkpoint with the five launch-related keys removed, passes `require_ready_for_execution=True` and a readiness context, asserts no `" launch binding"` or `"must identify a launch artifact"` error, and is recorded failing on pre-fix code and passing after the fix.
2. `test_ready_gate_rejects_partial_launch_binding` removes only `launch_status_path` and asserts the exact single launch-binding error; it passes.
3. `test_codex_flag_keeps_launch_binding_unconditional` is parametrized over both Codex flags, asserts that a keyless feature still yields its launch-binding errors, and passes for both.
4. `test_launch_evidence_is_required_only_for_execution_readiness` is rewritten to run its assertions with `require_codex_topology=True`, and it passes.
5. `test_ready_gate_preserves_feature_index_when_earlier_feature_is_skipped` asserts the `Epic planner checkpoint features[1]` prefix, and it passes.
6. `test_ready_gate_validates_feature_with_empty_launch_path_value` sets `launch_status_path` to `""` or `None`, asserts the existing launch-binding error, and passes.
7. `test_epic_planner_launch_evidence.py` contains two passing `require_launch_paths` tests.
8. `epic-planner-state-launch-binding.test.ts` contains five passing TypeScript twins and the rewritten readiness test, with byte-identical error strings.
9. `epic-planner-launch-evidence.test.ts` contains two passing twins.
10. `validate-orchestration-service-call.test.ts` contains a passing `threads the Codex flags into epic-planner-state` test.
11. Both runtimes still pass `require_generated_orchestrator=True` / `requireGeneratedOrchestrator: true`.
12. `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` asserts the new call text and has an updated docstring; it passes.
13. The six guidance files pass both Codex flags, and the Pester contract file passes, including the byte-identical copy test.
14. Existing keyed tests pass without modification (targeted pytest exits 0).
15. The targeted `node run-jest.cjs` command exits 0.
16. `git diff main -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github` produces no output.
17. Every file under "Files/modules to change" is at most 500 lines; no test added to the three excluded files.
18. Python full-suite coverage exits 0 with at least 85% lines and 75% branches for the four changed modules.
19. `node run-jest.cjs --coverage ...` exits 0 with all `coverageThreshold` entries satisfied and at least 85% lines and 75% branches for each changed TypeScript file under `src/lib/validate/`.
20. The full seven-stage toolchain loop completes in a single clean pass, with results under `evidence/qa-gates/`.

(Criteria 1-20 are abbreviated faithful transcriptions; the full text is in `spec.md` lines 289-333.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Keyless feature skipped; fail-before/pass-after recorded | PASS | `evidence/regression-testing/fail-before-python.2026-10-02T05-20.md` (EXIT_CODE 1, corrected `Timestamp:` 05-15) and `pass-after-python.2026-10-02T05-30.md` (EXIT_CODE 0, corrected 05-18). The fix commit `af88dd58` is at 05:19:12, so the recorded order is now consistent. | `poetry run pytest <6 targeted files> -q` (reviewer: 118 passed) | Canonical `regression-testing/` folder (recorded override of the spec's `regression/`). |
| 2 | Partial binding rejected with exact error | PASS | Exact-list assertion matches the spec string. | same | |
| 3 | Codex flag keeps keyless validation unconditional | PASS | `parametrize("flag", [...])` over both flags. | same | |
| 4 | Defect-pinning test rewritten under `require_codex_topology=True` | PASS | `_ready_errors(state, require_codex_topology=True)`. | same | |
| 5 | Index preserved when earlier feature skipped | PASS | Asserts the `features[1]` error only. | same | |
| 6 | Empty or null launch path value arms the gate | PASS | Parametrized `""` and `None`. | same | |
| 7 | Two launch-evidence `require_launch_paths` tests | PASS | `test_epic_planner_launch_evidence.py` lines 274-309. | same | |
| 8 | Five TypeScript twins plus rewritten test; byte-identical strings | PASS | `epic-planner-state-launch-binding.test.ts` lines 124-243. | `npx jest --config extensions/drm-copilot/jest.config.cjs <7 suites>` (reviewer: 133 passed) | |
| 9 | TypeScript launch-evidence twins | PASS | `epic-planner-launch-evidence.test.ts` lines 224-262. | same | |
| 10 | MCP dispatch threads Codex flags | PASS | `validate-orchestration-service-call.test.ts` lines 160-205. | same | |
| 11 | `require_generated_orchestrator` invariant preserved | PASS | Python line 277 and TypeScript line 303 unchanged; the generated-orchestrator `agent_name` cases pass. | pytest and Jest as above | |
| 12 | Source-text contract test updated | PASS | `test_push_down_codex_and_agents_customizations.py` lines 369, 403-404. | pytest as above | |
| 13 | Six guidance files carry both flags; Pester contracts pass | PASS | Reviewer `sha256sum` at 9ad8e5a3: pairs identical (`6e1752a9ce28`, `12b8a82cd4a0`, `8d62f9a06f08`). Pester JUnit (prior-pass inspection): `codex-epic-runtime-contracts.Tests.ps1` tests=10, failures=0; guidance unchanged since. | `sha256sum <6 files>` | Pester ran through the PoshQC MCP tool per the operator decision (plan deviation D3). |
| 14 | Existing keyed tests pass unmodified | PASS | Reviewer targeted pytest gave 118 passed; the named files are not in the branch diff. | `poetry run pytest <6 targeted files> -q` | |
| 15 | Targeted Jest command exits 0 | PASS | Reviewer: 7 suites, 133 tests passed. | `npx jest --config <abs>/jest.config.cjs <7 suites>` | Same config file as `run-jest.cjs`. |
| 16 | No diff to Python CLI, `.claude`, or `.github` | PASS | Reviewer command returned no paths. | `git diff --name-only ef80c57d..HEAD -- artifacts .claude .github scripts/dev_tools/validate_orchestration_artifacts.py` | |
| 17 | 500-line limit; no tests added to excluded files | PASS | No code change since the prior pass (maximum 471 production, 436 test). | `git diff --stat ecbe5ba1..HEAD` | |
| 18 | Python coverage floors for the four modules | PASS | Reviewer parse of `artifacts/python/lcov.info`: 97.48/94.64, 92.31/89.13, 90.58/77.17, 91.71/84.04 (lines/branches %). | `python lcov_parse.py artifacts/python/lcov.info ...` (prior pass); file unchanged since | |
| 19 | TypeScript coverage floors for each changed file | PASS | `evidence/qa-gates/typescript-coverage-run.2026-10-02T06-52.md`: 250 suites and 3794 tests passed, exit 0, so every `coverageThreshold` entry is met. Reviewer parse of `extensions/drm-copilot/coverage/lcov.info` (written 06:53:09): 96.11/93.28, 92.75/84.48, 91.62/84.29, 98.30/93.58, 100/97.56 (lines/branches %); 0 of 53 added lines uncovered. | `poetry run python <scratchpad>/ts_lcov_check.py` | The run used the `lcov`, `text-summary`, and `text` reporters, a superset of the AC's `text` and `text-summary`, as `remediation-inputs.2026-10-02T05-58.md` R1 directed. |
| 20 | Seven-stage loop clean in a single pass | PASS | `evidence/qa-gates/final-qa-clean-pass.2026-10-02T06-45.md`. Remediation changed no code (`remediation-scope-check.2026-10-02T07-01.md`). Reviewer re-ran format, lint, type-check, and the targeted tests clean. | Black, Ruff, Pyright, Prettier, tsc, pytest, Jest | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION (all acceptance criteria pass; one non-AC policy finding blocks PR authoring)

**Criteria summary:**
- **PASS:** 20 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Evidence integrity (not an AC): `evidence/other/python-batch-budget.2026-10-02T05-01.md` line 31 carries a composed `Timestamp:` value, `05-30`, which is later than the file's write time (05:18:16) and its commit time (05:19:12). This is policy finding PA-5. It does not change any AC outcome above.
2. Residual issue scope (not an AC of this spec): the Claude-runtime ready gate still fails on the Codex-only per-feature `model_routing_receipt` / `topology_receipt` and the planner `topology_receipt`. The PR must state "Partially addresses #543" and must not close the issue.

**Recommended follow-up verification steps:**

1. After the PA-5 correction, run `grep -rc "^Timestamp:" <feature>/evidence/ | grep -v ":1$"`. The only output should be `python-batch-budget` with a count of 2. Then confirm that neither of its values is later than `2026-10-02T05-18`.
2. File, or confirm, a tracking issue for the remaining Codex-only receipt checks before #543 is considered for closure.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

All 20 criteria are evaluated PASS and are already checked in `spec.md`. AC-19 was re-checked by the remediation executor in commit `1dd9be33`; the change was only `- [ ]` to `- [x]`, with no text change. This review made no source-file change.

### AC Status Summary

- Source: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`
- Total AC items: 20
- Checked off (delivered): 20
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` | 20 | 20 | 0 | Checkbox-backed; no change by this review |
