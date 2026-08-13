# Python batch 1 expected-red coverage

Timestamp: 2026-08-12T09:54:47.614Z

Command: `$env:COVERAGE_FILE='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/.coverage-python-batch-1-red'; poetry run pytest -o "addopts=" -q tests/scripts/dev_tools/test_parallel_completion_receipts.py tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py -k "completion_item_seam or mutation_parts_seam or git_hash_seam" --cov=scripts.dev_tools._parallel_orchestrator_state_completion_receipts --cov=scripts.dev_tools._parallel_orchestrator_state_mutation_receipts --cov=scripts.dev_tools.parallel_codex_readiness_filesystem --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/python-batch-1-coverage-red.json`

EXIT_CODE: 1

Output Summary: 12 failed and 41 deselected. Combined coverage was 15% across 416 statements and 180 branches, with 334 statements missing and 5 partial branches. The canonical JSON report was written beside this evidence file.

## Exact uncovered-line mappings

- `scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py` -> `tests/scripts/dev_tools/test_parallel_completion_receipts.py`: 11% line/branch aggregate; missing `33-36, 46, 52, 58, 64-70, 76, 84-117, 125-139, 147-188, 194-217`.
- `scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py` -> `tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py`: 10% line/branch aggregate; missing `29-31, 41-46, 52-64, 72-77, 85-101, 111-156, 162, 170-191, 201-277, 285-289`.
- `scripts/dev_tools/parallel_codex_readiness_filesystem.py` -> `tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py`: 21% line/branch aggregate; missing `33->exit, 35->exit, 44, 49, 55->exit, 57->exit, 59->exit, 68-69, 72-73, 78-79, 84-85, 90-91, 122-124, 135-146, 158-166, 176-235, 250-339`.

Acceptance result: PASS as expected-red. Every numeric deficit is attributed to its production path and P3-T1 test owner before any batch 1 production edit.
