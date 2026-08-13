# Python batch 2 expected-red tests

Timestamp: 2026-08-12T10:15:03.744Z

Command: `poetry run pytest -o "addopts=" -q tests/scripts/dev_tools/test_push_down_codex_routing_merge.py tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py tests/scripts/dev_tools/test_parallel_kickoff_contract.py -k "object_merge_seam or readiness_item_paths_seam or ready_identity_path_seam"`

EXIT_CODE: 1

Output Summary: 3 failed and 52 deselected in 0.17 seconds. Each new test failed at its explicit seam-existence assertion before any batch 2 production edit.

- `test_push_down_codex_routing_merge.py` failed because `_merge_routing_objects` is absent; its test owns additive, unchanged-boundary, nested-conflict, and top-level error cases.
- `test_validate_parallel_codex_readiness.py` failed because `_readiness_item_paths` is absent; its test owns valid, missing-boundary, unsafe-POSIX, and absolute-path cases.
- `test_parallel_kickoff_contract.py` failed because `_ready_identity_paths` is absent; its test owns valid, one-character-boundary, malformed, and empty slug cases.

Acceptance result: PASS as expected-red. All new cases failed for the intended uncovered testability seams, the failure count is nonzero, and no batch 2 production source was edited.
