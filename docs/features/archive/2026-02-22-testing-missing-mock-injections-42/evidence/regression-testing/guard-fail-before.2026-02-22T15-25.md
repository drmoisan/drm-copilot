Timestamp: 2026-02-22T15-25
Command: poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q -k guard_blocks_unmocked_code_launcher_invocation
EXIT_CODE: 1
Output Summary:
- FAILED tests/scripts/dev_tools/test_new_active_feature_folder.py::test_guard_blocks_unmocked_code_launcher_invocation
- 1 failed, 49 deselected in 0.14s
- Failure included FileNotFoundError from default launcher subprocess path.
