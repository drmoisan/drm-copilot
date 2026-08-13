# Python batch 1 expected-red tests

Timestamp: 2026-08-12T09:53:54.258Z

Command: `poetry run pytest -o "addopts=" -q tests/scripts/dev_tools/test_parallel_completion_receipts.py tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py -k "completion_item_seam or mutation_parts_seam or git_hash_seam"`

EXIT_CODE: 1

Output Summary: 12 failed and 41 deselected in 0.20 seconds. All 12 new tests failed at their explicit seam-existence assertion before any production-source edit.

- `tests/scripts/dev_tools/test_parallel_completion_receipts.py`: four positive, negative, boundary, and error cases failed because `_validate_completion_item` is absent from `scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py`.
- `tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py`: four positive, negative, boundary, and error cases failed because `_validate_mutation_state_parts` is absent from `scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py`.
- `tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py`: four positive, negative, boundary, and error cases failed because `_normalize_git_hash_result` is absent from `scripts/dev_tools/parallel_codex_readiness_filesystem.py`.

Acceptance result: PASS as expected-red. Each new test failed for the intended uncovered testability seam, the failure count is nonzero, and no batch 1 production source was edited.
