# Validator Acceptance (Phase 6 gate)

Timestamp: 2026-10-31T15-46
Command: poetry run pytest tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py -q -p no:cacheprovider --no-cov; sh SCRATCH/issue-1013-jest.sh p6t4 test/lib/validate/parallel-state-tolerated-edge-fields.test.ts; git diff --name-only MB HEAD and git status --porcelain (MB = merge base of origin/main and HEAD)
EXIT_CODE: 0
Output Summary: zero failures. Python 114 passed, 5 skipped; Jest 1 suite, 8 tests passed. No validator module is in the branch diff.

## Detail

- `test_validate_parallel_state_tolerated_edge_fields.py`: 8 passed, including the new `test_orchestrator_state_accepts_observed_resolution`, `test_orchestrator_state_accepts_combined_issue_nums`, and `test_planner_state_accepts_combined_item_and_combinations_list` (planner under the plain and ready gates); `test_out_of_enum_reason_is_still_rejected` unchanged and passing.
- `parallel-state-tolerated-edge-fields.test.ts`: 8 passed, including the three new shapes (planner under the plain and ready gates).
- `test_parallel_manifest_bash_parity.py`: `test_validator_reproduces_the_fixture_errors[manifest_valid_combined_item]` and `test_accessors_reproduce_the_fixture_defaults[manifest_valid_combined_item]` pass; the five skips are the existing `manifest_m1_*` accessor-expectation skips. The bash lane (`tests/shell/parallel_manifest_parity.bats`, which globs `tests/fixtures/parallel_manifest_bash/*.json`) runs in `shell-coverage / Shell Coverage (Bats + kcov)` in CI and is pending CI.
- Scope: the committed diff from the merge base and the working-tree status list no file under `scripts/dev_tools/validate_*`, `extensions/drm-copilot/src/lib/validate/`, or `.claude/lib/bash/`; the only validator-related paths are the two edited test files and the new manifest fixture.
