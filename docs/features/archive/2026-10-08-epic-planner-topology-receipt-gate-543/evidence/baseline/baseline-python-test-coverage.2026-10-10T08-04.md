# Baseline Python Full-Suite Test and Coverage (Issue #543)

Timestamp: 2026-10-10T08-04
Task: [P0-T10]
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
EXIT_CODE: 0
Output Summary:
- Result line: `6740 passed, 6 skipped, 1 deselected in 91.06s (0:01:31)`; 0 failed.
- Deselected: 1, the known local-only failure tracked as #510 (`test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`).
- TOTAL row (verbatim): `TOTAL                                                                 17571   1107   6342    511    92%`
- term-missing row (verbatim): `scripts\dev_tools\validate_epic_planner_state.py                        181     15     94     15    89%   121, 127, 143-144, 149-150, 152, 154, 156, 169->173, 189, 211->209, 227, 236, 238, 255, 324`
- The `Cover` column (89%) is a combined statement-plus-branch figure; per-file line and branch percentages are recorded in the P0-T11 artifact.
