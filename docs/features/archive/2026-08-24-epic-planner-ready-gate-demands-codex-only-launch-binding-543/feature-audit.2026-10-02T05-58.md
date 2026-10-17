# Feature Audit: Epic planner ready gate key-gates Codex-only launch evidence (#543)

---

**Audit Date:** 2026-10-02
**Feature Folder:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Base Branch:** `main`
**Head Branch:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`)
- **Head branch/commit:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543` (commit `ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81`)
- **Merge base:** `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-02 09:49:47 UTC at head `ecbe5ba1`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/**` (54 files)
  - Additional evidence: reviewer re-runs (targeted pytest 118 passed; targeted Jest 133 passed; Black, Ruff, Pyright, Prettier, and tsc clean), `artifacts/python/lcov.info`, `artifacts/pester/pester-junit.xml`, `sha256sum` of the guidance pairs, `wc -l` of the changed files
- **Feature folder used:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
- **Requirements source:** `spec.md` (section `## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` line 12 reads `- Work Mode: full-bug`, so `spec.md` is the sole AC source. `spec.md` line 9 states that no `user-story.md` exists.
- **Scope note:** The audit covers the full branch diff (79 files). Issue #543 carries an additional gap reported on 2026-09-30, the Codex-only planner `topology_receipt` check (`_validate_planner_topology_receipt`) and the per-feature receipts. `spec.md` (Non-goals; Rollout & Follow-up) places that gap outside this change's acceptance criteria. It is therefore not evaluated as an AC, but it is recorded below as residual issue scope.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` (only source)

### Acceptance criteria

1. `test_ready_gate_skips_launch_binding_for_feature_without_launch_paths` validates a ready checkpoint whose feature has `branch_name`, `worktree_path`, `delegation_receipt`, `launch_receipt_path`, and `launch_status_path` removed. It passes `require_ready_for_execution=True` and a readiness context, asserts that no error contains `" launch binding"` or `"must identify a launch artifact"`, and is recorded failing on pre-fix code and passing after the fix, with evidence under `evidence/regression/`.
2. `test_ready_gate_rejects_partial_launch_binding` removes only `launch_status_path` and asserts the exact single launch-binding error; it passes.
3. `test_codex_flag_keeps_launch_binding_unconditional` is parametrized over `require_codex_model_routing=True` and `require_codex_topology=True`, asserts that a keyless feature still yields its launch-binding errors, and passes for both.
4. `test_launch_evidence_is_required_only_for_execution_readiness` is rewritten so that its `launch binding.branch_name` and `delegation_receipt must be an object` assertions run with `require_codex_topology=True`, and it passes.
5. `test_ready_gate_preserves_feature_index_when_earlier_feature_is_skipped` asserts that the error is prefixed `Epic planner checkpoint features[1]`, and it passes.
6. `test_ready_gate_validates_feature_with_empty_launch_path_value` sets `launch_status_path` to `""` or `None` with no Codex flag, asserts the existing launch-binding error, and passes.
7. `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py` contains two passing tests: `test_require_launch_paths_skips_feature_without_launch_keys` and `test_require_launch_paths_still_rejects_partial_launch_keys`.
8. `epic-planner-state-launch-binding.test.ts` contains five passing TypeScript twins, the rewritten `activates only for execution readiness` under `requireCodexTopology: true`, and byte-identical error strings.
9. `epic-planner-launch-evidence.test.ts` contains passing twins of the two Python launch-evidence tests.
10. `validate-orchestration-service-call.test.ts` contains a passing `threads the Codex flags into epic-planner-state` test.
11. Both runtimes still pass `require_generated_orchestrator=True` / `requireGeneratedOrchestrator: true`, verified by source and by the existing `agent_name` test passing unchanged.
12. `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` asserts the new ready-gate call text; its docstring no longer states that #543 behaviour is unchanged; it passes.
13. The six guidance files pass `require_codex_topology: true` and `require_codex_model_routing: true`, and `Invoke-Pester tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` passes, including `keeps root and tracked bundle runtime copies byte-identical`.
14. Existing tests that keep both launch keys present pass without modification, verified by the targeted `poetry run pytest` command exiting 0.
15. The targeted `node run-jest.cjs` command exits 0 and covers four unchanged suites.
16. `git diff main -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github` produces no output.
17. Every production and test file under "Files/modules to change" is at most 500 lines; no new test is added to the three excluded test files.
18. `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` exits 0 and reports at least 85% line and 75% branch coverage for the four changed Python modules.
19. `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` exits 0 from `extensions/drm-copilot/` with all `coverageThreshold` entries satisfied, and reports at least 85% line and 75% branch coverage for each changed TypeScript file under `extensions/drm-copilot/src/lib/validate/`.
20. The full seven-stage toolchain loop completes in a single clean pass for the changed Python and TypeScript files, with results under `evidence/qa-gates/`.

(Criteria 1-20 are abbreviated faithful transcriptions; the full text is in `spec.md` lines 289-333.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Keyless feature skipped at ready gate; fail-before/pass-after recorded | PASS | Test at `test_validate_epic_planner_state_launch_binding.py` line 141; `evidence/regression-testing/fail-before-python.2026-10-02T05-20.md` (EXIT_CODE 1) and `pass-after-python.2026-10-02T05-30.md` (EXIT_CODE 0). Fail-before ordering is confirmed by file write time 05:15:41 and fix commit `af88dd58` at 05:19:12. | `poetry run pytest <6 targeted files> -q` (reviewer: 118 passed) | Evidence is in the canonical `regression-testing/` folder rather than the spec's `regression/` (recorded override). Recorded `Timestamp:` values are composed (PA-2) but do not change the verified outcome. |
| 2 | Partial binding rejected with exact error | PASS | Line 164; exact-list assertion matches the spec string. | same | |
| 3 | Codex flag keeps keyless validation unconditional | PASS | Line 184 (decorator at 181), `parametrize("flag", [...])` over both flags. | same | |
| 4 | Defect-pinning test rewritten under `require_codex_topology=True` | PASS | Lines 126-140; `_ready_errors(state, require_codex_topology=True)`. | same | |
| 5 | Index preserved when earlier feature skipped | PASS | Line 202; asserts the `features[1]` error only. | same | |
| 6 | Empty or null launch path value arms the gate | PASS | Line 221, parametrized `""` and `None`. | same | |
| 7 | Two launch-evidence `require_launch_paths` tests | PASS | `test_epic_planner_launch_evidence.py` lines 274-309. | same | |
| 8 | Five TypeScript twins plus rewritten readiness test; byte-identical strings | PASS | `epic-planner-state-launch-binding.test.ts` lines 124-243; error literals compared character by character with the Python assertions. | `npx jest --config extensions/drm-copilot/jest.config.cjs <7 suites>` (reviewer: 133 passed) | |
| 9 | TypeScript launch-evidence twins | PASS | `epic-planner-launch-evidence.test.ts` lines 224-262. | same | |
| 10 | MCP dispatch threads Codex flags | PASS | `validate-orchestration-service-call.test.ts` lines 160-205; source `orchestration-artifacts.ts` lines 320-325. | same | |
| 11 | `require_generated_orchestrator` invariant preserved | PASS | `_epic_orchestrator_state_launch_binding.py` line 277 `require_generated_orchestrator=True`; `epic-orchestrator-state-launch-binding.ts` line 303 `requireGeneratedOrchestrator: true`; the `.agent_name must name a generated orchestrator agent.` cases (Python line 287, TypeScript line 283) pass in the reviewer re-runs. | `grep -n` of both sources; pytest and Jest as above | |
| 12 | Source-text contract test updated | PASS | `test_push_down_codex_and_agents_customizations.py` lines 369, 403-404. | pytest as above | |
| 13 | Six guidance files carry both flags; Pester contracts pass | PASS | Diff shows both flags in all six files. Reviewer `sha256sum` shows the pairs identical (`6e1752a9...`, `12b8a82c...`, `8d62f9a0...`). Reviewer inspection of `artifacts/pester/pester-junit.xml` (written 05:44:43, after guidance commit `7ee6d91b` at 05:34:04): suite `codex-epic-runtime-contracts.Tests.ps1` tests=10, failures=0, errors=0; testcase `keeps root and tracked bundle runtime copies byte-identical` status Passed. | `sha256sum <6 files>`; `grep -o '<testsuite [^>]*codex-epic-runtime-contracts[^>]*>' artifacts/pester/pester-junit.xml` | Pester was run through the PoshQC MCP tool rather than `Invoke-Pester` in a shell, per the operator decision in `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`. The results are equivalent for this criterion. |
| 14 | Existing keyed tests pass unmodified | PASS | Reviewer targeted pytest gave 118 passed. `test_validate_epic_planner_state.py`, `test_epic_planner_readiness.py`, and `test_validate_epic_orchestrator_state_launch_binding.py` are absent from the branch diff; the five named tests' bodies are not in any diff hunk. | `poetry run pytest <6 targeted files> -q` | |
| 15 | Targeted Jest command exits 0 | PASS | Reviewer: 7 suites, 133 tests passed. The four named suites are absent from the branch diff. | `npx jest --config <abs>/jest.config.cjs <7 suites>` | The reviewer used `npx jest` with the same config file because `run-jest.cjs` requires the extension directory as cwd. |
| 16 | No diff to Python CLI, `.claude`, or `.github` | PASS | Reviewer command returned no paths. | `git diff --name-only ef80c57d..HEAD -- artifacts .claude .github scripts/dev_tools/validate_orchestration_artifacts.py` | Anchored to the merge base. |
| 17 | 500-line limit; no tests added to the three excluded files | PASS | Reviewer `wc -l`: maximum 471 (production) and 436 (test); the three excluded files are absent from the diff. | `wc -l <15 files>` | |
| 18 | Python coverage of at least 85% lines and 75% branches for the four modules | PASS | Reviewer parse of `artifacts/python/lcov.info`: 97.48/94.64, 92.31/89.13, 90.58/77.17, 91.71/84.04 (lines/branches %). Executor full suite: 6450 passed, exit 0. | `python lcov_parse.py artifacts/python/lcov.info ...` | The lcov file was written after the last Python commit. |
| 19 | TypeScript coverage of at least 85% lines and 75% branches for each changed file | UNVERIFIED | Only the executor's text transcription exists (`evidence/qa-gates/final-typescript-test-coverage.2026-10-02T06-35.md`). No lcov or JSON coverage artifact is on disk. Jest `coverageThreshold` gates only `orchestration-artifacts.ts` (`jest.config.cjs` line 98), so exit 0 does not substantiate the per-file floors for the other four files. | `ls coverage/lcov.info extensions/drm-copilot/coverage/lcov.info` (neither exists) | Returned to unchecked in `spec.md`. Resolved by remediation R1. |
| 20 | Seven-stage loop clean in a single pass | PASS | `evidence/qa-gates/final-qa-clean-pass.2026-10-02T06-45.md`: Python iteration 1 clean; TypeScript iteration 2 clean after one Prettier restart. The reviewer re-ran format, lint, type-check, and the targeted tests clean. | Black, Ruff, Pyright, Prettier, tsc, pytest, and Jest as listed in the policy audit, Appendix B | The final iteration of each language is clean. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-19)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-19: TypeScript per-file coverage cannot be confirmed from an artifact (policy finding PA-1, remediation R1).
2. Evidence integrity: 35 evidence artifacts carry composed `Timestamp:` values (policy finding PA-2, remediation R2). This does not change any AC outcome above, but it blocks the policy audit.
3. Residual issue scope (not an AC of this spec): the Claude-runtime ready gate still fails on the Codex-only per-feature `model_routing_receipt` / `topology_receipt` and the planner `topology_receipt` (`_validate_planner_topology_receipt`). The PR must state "Partially addresses #543" and must not close the issue.

**Recommended follow-up verification steps:**

1. After R1, parse `extensions/drm-copilot/coverage/lcov.info` for the five changed TypeScript production files and confirm at least 85% lines and 75% branches for each. Then re-tick AC-19.
2. After R2, confirm that no evidence `Timestamp:` value is later than its file's write time, and re-run `validate_evidence_locations.py --root .`.
3. File, or confirm, a tracking issue for the remaining Codex-only receipt checks before #543 is considered for closure.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

The executor had already checked off all 20 criteria. This review made one source-file change: AC-19 (`node run-jest.cjs --coverage ...`) was returned from `- [x]` to `- [ ]` in `spec.md` because it is evaluated UNVERIFIED. No criterion text was changed. The 19 PASS criteria remain checked.

### AC Status Summary

- Source: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`
- Total AC items: 20
- Checked off (delivered): 19
- Remaining (unchecked): 1
- Items remaining: `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` exits 0 from `extensions/drm-copilot/` with all `coverageThreshold` entries satisfied. It reports at least 85% line and 75% branch coverage for each changed TypeScript file under `extensions/drm-copilot/src/lib/validate/`.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` | 20 | 19 | 1 | Checkbox-backed; AC-19 unchecked by this review |
