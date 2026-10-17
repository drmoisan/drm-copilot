# Remediation Cycle 2 CR-6 Parity Tests (P1-T5)

Timestamp: 2026-10-16T06-24
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py -vv; poetry run pyright tests/scripts/dev_tools/typescript_twin_test_support.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
EXIT_CODE: 0
Output Summary:
- 24 passed in 0.24s (9 + 7 + 8)
- tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py::test_asserted_messages_match_typescript_twin PASSED
- tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py::test_asserted_messages_match_typescript_twin PASSED
- tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_asserted_messages_match_typescript_twin PASSED
- pyright: 0 errors, 0 warnings, 0 informations (exit 0)
