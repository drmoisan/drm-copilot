# Regression: QT009 message form ([P3-T7])

Timestamp: 2026-10-09T21-15
Command: poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py -k "qt009" -v
EXIT_CODE: 0
Output Summary: 6 passed, 10 deselected in 0.08s. All six named QT009 node IDs PASSED (collection order differs from the plan's listing order; the set is identical).

```
tests/scripts/dev_tools/test_check_quality_tiers.py::test_main_returns_one_with_qt009_when_runner_raises_oserror PASSED [ 16%]
tests/scripts/dev_tools/test_check_quality_tiers.py::test_main_returns_one_with_qt009_when_git_exits_nonzero PASSED [ 33%]
tests/scripts/dev_tools/test_check_quality_tiers.py::test_qt009_message_includes_git_stderr PASSED [ 50%]
tests/scripts/dev_tools/test_check_quality_tiers.py::test_qt009_message_collapses_multiline_git_stderr PASSED [ 66%]
tests/scripts/dev_tools/test_check_quality_tiers.py::test_main_returns_one_with_qt009_when_git_not_found PASSED [ 83%]
tests/scripts/dev_tools/test_check_quality_tiers.py::test_main_reports_entry_errors_alongside_qt009 PASSED [100%]
====================== 6 passed, 10 deselected in 0.08s =======================
```

Acceptance (AC-5 behavior half): exit 0; the six required node IDs are PASSED (6 passed). PASS. AC-5 is checked off at [P10-T13], not in this phase.
