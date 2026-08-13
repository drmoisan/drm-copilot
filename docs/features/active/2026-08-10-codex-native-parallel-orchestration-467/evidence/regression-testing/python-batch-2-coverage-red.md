# Python batch 2 expected-red coverage

Timestamp: 2026-08-12T10:15:43.173Z

Command: `$env:COVERAGE_FILE='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/.coverage-python-batch-2-red'; poetry run pytest -o "addopts=" -q tests/scripts/dev_tools/test_push_down_codex_routing_merge.py tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py tests/scripts/dev_tools/test_parallel_kickoff_contract.py -k "object_merge_seam or readiness_item_paths_seam or ready_identity_path_seam" --cov=scripts.dev_tools.push_down_codex_routing_merge --cov=scripts.dev_tools.validate_parallel_codex_readiness --cov=scripts.dev_tools.parallel_kickoff_contract --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/python-batch-2-coverage-red.json`

EXIT_CODE: 1

Output Summary: 3 failed and 52 deselected. Combined line coverage was 22% across 407 statements, with 317 statements missing. The canonical JSON report was written beside this evidence file.

## Exact uncovered-line mappings

- `scripts/dev_tools/push_down_codex_routing_merge.py` -> `tests/scripts/dev_tools/test_push_down_codex_routing_merge.py`: 24%; missing `30-32, 38-46, 52, 58-77, 83, 93-125, 138-140, 145-151, 156, 161, 166, 171, 176-185, 190`.
- `scripts/dev_tools/validate_parallel_codex_readiness.py` -> `tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py`: 16%; missing `83, 89-100, 108, 129-177, 183-210, 216-221, 232-266, 277-295, 307-314, 327-386, 397-465`.
- `scripts/dev_tools/parallel_kickoff_contract.py` -> `tests/scripts/dev_tools/test_parallel_kickoff_contract.py`: 31%; missing `199-226, 251-280, 306-349, 366-386, 415-418`.

Acceptance result: PASS as expected-red. Every numeric deficit is mapped to its owning batch-2 production path and P4-T1 test owner before any batch-2 production edit.
