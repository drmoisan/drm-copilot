# RealFileSystem Tests (#623)

Timestamp: 2026-09-30T08-43
Command: poetry run pytest -v "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"
EXIT_CODE: 0
Output Summary: Final summary line `============================== 7 passed in 0.08s ==============================`. Seven PASSED nodes, one per RealFileSystem method.

## pytest output (verbatim excerpt)

```
collecting ... collected 7 items

tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_resolve_path_expands_user_then_resolves PASSED [ 14%]
tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_exists_delegates_to_path_exists PASSED [ 28%]
tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_read_text_reads_utf8 PASSED [ 42%]
tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_write_text_writes_utf8 PASSED [ 57%]
tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_write_lines_joins_lines_with_newlines PASSED [ 71%]
tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_ensure_dir_creates_parents PASSED [ 85%]
tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_move_creates_parent_then_moves PASSED [100%]

============================== 7 passed in 0.08s ==============================
```
