Timestamp: 2026-09-30T10-22
Command: poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue.py" "tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py" "tests/scripts/dev_tools/test_potential_to_issue_work_modes.py" "tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py" "tests/scripts/dev_tools/test_potential_to_issue_branches.py" "tests/scripts/dev_tools/test_potential_to_issue_content.py" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py" "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" --collect-only -q
EXIT_CODE: 0
Output Summary:
POST_CHANGE_COLLECTED_COUNT: 59 (footer `59 tests collected`).
Count comparison: 59 == BASELINE_COLLECTED_COUNT 59 (evidence/baseline/collected-count.md): EQUAL.
Name comparison: the sorted 59 collected test function names (file paths stripped) were diffed against the sorted name list in evidence/baseline/collected-count.md; diff output empty (NAMES_EQUAL). All 59 names are unique, so no name was lost or duplicated by the split.
