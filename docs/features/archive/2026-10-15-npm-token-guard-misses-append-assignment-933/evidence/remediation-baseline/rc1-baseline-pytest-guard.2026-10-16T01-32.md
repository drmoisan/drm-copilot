# rc1 Baseline Guard Pytest (P0-T12)

Timestamp: 2026-10-16T01-32
Command: poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -v
EXIT_CODE: 0
Output Summary:
============================= 66 passed in 0.25s ==============================
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[powershell-env-append] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[arithmetic-increment] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[env-context-read] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[prefixed-name-key] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[bash-append-reported] PASSED
