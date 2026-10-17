# Acceptance criteria check-off (issue #543)

Timestamp: 2026-10-02T05-48
Timestamp-Correction: original value 2026-10-02T06-55 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper bound on the command run time.
Task: P10-T6
Command: `grep -c '^- \[x\] ' spec.md` and `grep -c '^- \[ \] ' spec.md` (feature-folder `spec.md`; D3 substitute for the two `Select-String ... .Count` commands)
Route: native (D3) (replaces the plan's `Route: sh-pwsh`)
EXIT_CODE: 0

## Output Summary

- Checked (`^- \[x\] `): 21 (twenty acceptance criteria plus the pre-existing `Medium` Impact/Severity box).
- Unchecked (`^- \[ \] `): 3 (the `Blocker`, `High`, and `Low` Impact/Severity boxes at lines 23, 24, 26).
- Matches the required 21 / 3 against the P0-T18 baseline of 1 / 23. Only `- [ ]` was changed to `- [x]`; no criterion text or other section was edited.
- Each criterion was ticked when its mapped task passed (tick rule in the plan's Execution notes); none was later returned to unchecked.

## Criterion citations

- AC1 (ticked at P2-T6): `evidence/regression-testing/fail-before-python.2026-10-02T05-20.md` (EXIT_CODE 1) and `evidence/regression-testing/pass-after-python.2026-10-02T05-30.md` (EXIT_CODE 0); node `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_ready_gate_skips_launch_binding_for_feature_without_launch_paths`.
- AC2 (P4-T2): node `test_ready_gate_rejects_partial_launch_binding`, `PASSED` in `evidence/regression-testing/python-launch-binding-suite.2026-10-02T05-45.md`.
- AC3 (P4-T3): node `test_codex_flag_keeps_launch_binding_unconditional[require_codex_model_routing]` and `[require_codex_topology]`, both `PASSED` in the same artifact.
- AC4 (P4-T1): node `test_launch_evidence_is_required_only_for_execution_readiness`, `PASSED` in the same artifact.
- AC5 (P4-T4): node `test_ready_gate_preserves_feature_index_when_earlier_feature_is_skipped`, `PASSED` in the same artifact.
- AC6 (P4-T5): node `test_ready_gate_validates_feature_with_empty_launch_path_value[]` and `[None]`, both `PASSED` in the same artifact.
- AC7 (P4-T9): `evidence/regression-testing/python-launch-evidence-suite.2026-10-02T05-45.md` (`test_require_launch_paths_skips_feature_without_launch_keys`, `test_require_launch_paths_still_rejects_partial_launch_keys` PASSED).
- AC8 (P5-T6): `evidence/regression-testing/typescript-launch-binding-suite.2026-10-02T05-55.md` (six titles passed; `Tests: 19 passed`).
- AC9 (P5-T10): `evidence/regression-testing/typescript-evidence-and-dispatch-suites.2026-10-02T06-00.md` (two launch-evidence twins passed).
- AC10 (P5-T10): same artifact (`threads the Codex flags into epic-planner-state` passed).
- AC11 (P7-T3): `evidence/regression-testing/generated-orchestrator-invariant.2026-10-02T06-20.md`.
- AC12 (P4-T10): node `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` (1 passed; old literal and old docstring phrase both absent, `grep -c -F` = 0); also covered by the P7-T1 and P8-T5 runs.
- AC13 (P6-T9): `evidence/regression-testing/pass-after-guidance.2026-10-02T06-10.md` (guidance test 1 passed; Pester PassedCount 10, FailedCount 0, byte-identical testcase Passed; three root/bundle pairs SHA-256 equal).
- AC14 (P7-T1): `evidence/regression-testing/targeted-python.2026-10-02T06-15.md` (118 passed; three unchanged test files confirmed unedited).
- AC15 (P7-T2): `evidence/regression-testing/targeted-typescript.2026-10-02T06-15.md` (7 suites, 133 tests passed; four unchanged test files confirmed unedited).
- AC16 (P10-T3): `evidence/qa-gates/scope-exclusions.2026-10-02T06-50.md`.
- AC17 (P10-T5): `evidence/qa-gates/line-counts-final.2026-10-02T06-50.md`.
- AC18 (P8-T6): `evidence/qa-gates/final-python-per-file-coverage.2026-10-02T06-25.md` with `evidence/qa-gates/final-python-test-coverage.2026-10-02T06-25.md`.
- AC19 (P9-T5): `evidence/qa-gates/final-typescript-test-coverage.2026-10-02T06-35.md`.
- AC20 (P10-T2): `evidence/qa-gates/final-qa-clean-pass.2026-10-02T06-45.md`.

## Notes

1. AC1 canonical-folder substitution: the spec names `evidence/regression/`; the fail-before and pass-after artifacts are in the canonical `evidence/regression-testing/` folder (EVIDENCE_LOCATION_OVERRIDE_REJECTED recorded in the plan header and in `evidence/baseline/scope-confirmation.2026-10-02T05-01.md`).
2. AC16 merge-base anchor: the spec's `git diff main` is run as `git diff ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`, the merge base with `origin/main` (D2), which stays fixed if `origin/main` advances.
3. AC18 `--deselect`: the full-suite run deselects the #510 local-only node `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, identically at baseline and final; this change does not touch the `.claude` tree that node protects.
4. AC18 dependence on P4-T11: `scripts/dev_tools/epic_planner_readiness.py` was below the branch floor at baseline (64/92, 69.57%); the three P4-T11 `test_readiness_integrity_` tests raised it to 71/92 (77.17%). AC18 was ticked at P8-T6 only; P4-T11 contributed to it but did not tick it.

## Deviations affecting this record

- D3: `grep -c` used in place of `Select-String`; `Route: native (D3)`.
