# #846 CR-1 After (P4-T18)

Timestamp: 2026-10-13T11-27
Command: poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py -v
EXIT_CODE: 0
Output Summary: 17 passed in 0.11s. Both parametrized nodes PASSED and assert the exact line `QT009: cannot list tracked files: git ls-files exited with code 128`.

- tests/scripts/dev_tools/test_check_quality_tiers.py::test_main_returns_one_with_qt009_when_git_exits_nonzero[empty-stderr] PASSED
- tests/scripts/dev_tools/test_check_quality_tiers.py::test_main_returns_one_with_qt009_when_git_exits_nonzero[whitespace-only-stderr] PASSED

File length after the edit: 458 lines (`wc -l`), within the 470 limit. The exact literal appears once in the file (Grep count 1).
