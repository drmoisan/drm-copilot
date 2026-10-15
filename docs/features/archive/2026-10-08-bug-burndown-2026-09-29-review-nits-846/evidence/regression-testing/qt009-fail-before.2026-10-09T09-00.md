# Regression: QT009 stderr tests fail before the fix ([P3-T2], expect-fail)

Timestamp: 2026-10-09T21-14
Command: poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py -k "qt009_message" -q
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: 2 failed, 14 deselected in 0.11s. Run against the unchanged production file scripts/dev_tools/check_quality_tiers.py (its anchored diff against merge-base 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a and its porcelain status were both empty in [P3-T1]). test_qt009_message_includes_git_stderr fails because the QT009 line omits git's stderr text:
  AssertionError: assert 'fatal: not a git repository' in 'QT009: cannot list tracked files: git ls-files exited with code 128'
test_qt009_message_collapses_multiline_git_stderr fails for the same reason:
  AssertionError: assert 'fatal: first line hint: second line' in 'QT009: cannot list tracked files: git ls-files exited with code 128'
Both failures are on the final stderr-content assertion; the single-line and `QT009: ` prefix assertions passed. This is the AC-6 observed fail-before run.

Merge-base substitution: [P3-T1] used 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a (recorded in [P0-T4]) in place of e7d3779b398604af919678c16c877c8539a86cc0.

## Short test summary (verbatim)

```
FAILED tests/scripts/dev_tools/test_check_quality_tiers.py::test_qt009_message_includes_git_stderr
FAILED tests/scripts/dev_tools/test_check_quality_tiers.py::test_qt009_message_collapses_multiline_git_stderr
2 failed, 14 deselected in 0.11s
```

Acceptance: exit 1; `2 failed`; the assertion failure for test_qt009_message_includes_git_stderr (missing `fatal: not a git repository`) is quoted above. PASS (expected failure observed).
