# Python batch 3 expected-red tests

Timestamp: 2026-08-12T10:28:19.672Z

Command: `poetry run pytest -o "addopts=" -q tests/scripts/dev_tools/test_resolve_codex_deployment.py tests/scripts/dev_tools/test_resolve_codex_topology.py -k "parallel_persona_context_seam or parallel_root_context_seam"`

EXIT_CODE: 1

Output Summary: 2 failed and 70 deselected in 0.12 seconds. Both new tests failed at their explicit seam-existence assertions before any batch 3 production edit.

- `test_resolve_codex_deployment.py` owns positive planner, boundary orchestrator, ordinary-agent negative, and mismatched-context error cases for absent `_parallel_persona_context`.
- `test_resolve_codex_topology.py` owns positive planner, boundary orchestrator, ordinary-root negative, and mismatched-context error cases for absent `_parallel_root_context`.

Acceptance result: PASS as expected-red. Both tests failed for their intended uncovered behavior, the failure count is nonzero, and no batch 3 production source was edited.
