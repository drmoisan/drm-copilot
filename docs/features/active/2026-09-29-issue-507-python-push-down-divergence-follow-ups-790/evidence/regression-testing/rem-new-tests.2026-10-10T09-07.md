# P1-T3 New Tests and Whole TEST-FILE

Timestamp: 2026-10-10T09-07
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py -k test_excluding_file_system_list_files_applies_memory_mode; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py
EXIT_CODE: 0
Output Summary:
- First command exit 0: 4 passed, 6 deselected.
- Second command exit 0: 10 passed (6 existing plus 4 new), no failed test.
- Node IDs (all PASSED):
  - tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py::test_excluding_file_system_list_files_applies_memory_mode[skip-drops-general-memory]
  - ...[merge-drops-memory-present-at-destination]
  - ...[merge-keeps-memory-absent-at-destination]
  - ...[merge-without-destination-root-keeps-memory]
