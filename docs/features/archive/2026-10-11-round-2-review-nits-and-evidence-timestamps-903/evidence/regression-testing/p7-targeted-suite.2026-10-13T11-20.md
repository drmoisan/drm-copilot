# P7 Targeted Suite (P3-T15)

Timestamp: 2026-10-13T11-20
Command: poetry run pytest tests/scripts/dev_tools/test_evidence_timestamp_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py -q -rA
EXIT_CODE: 0
Output Summary: 101 passed in 0.74s; 0 failed. `-rA` was added to the planned `-q` command so the passed node ids are listed (the plan permits this confirmation).

## Required nodes (quoted from the `-rA` short summary)

- `PASSED tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-evidence]`
- `PASSED tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[agents-evidence]`
- `PASSED tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[github-evidence]`
- `PASSED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

Summary line: `101 passed in 0.74s`
