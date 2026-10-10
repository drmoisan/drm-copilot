# Regression: QT009 stderr tests pass after the fix ([P3-T4])

Timestamp: 2026-10-09T21-14
Command: poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py -q
EXIT_CODE: 0
Output Summary: 16 passed in 0.09s. Includes test_qt009_message_includes_git_stderr, test_qt009_message_collapses_multiline_git_stderr, and the existing test_main_returns_one_with_qt009_when_git_exits_nonzero (empty-stderr branch).

```
16 passed in 0.09s
```

## Block 2

Command: poetry run pyright scripts/dev_tools/check_quality_tiers.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/quality_tiers_contract_test_support.py
EXIT_CODE: 0
Output Summary: `0 errors, 0 warnings, 0 informations`. Pyright also printed the informational line "venv .venv subdirectory not found in venv path ..." (worktree has no local .venv; Poetry's environment is used) and a newer-version notice (v1.1.409 -> v1.1.414); neither is a diagnostic.

```
0 errors, 0 warnings, 0 informations
```

Acceptance: first block exit 0 with 16 passed; second block prints `0 errors, 0 warnings, 0 informations`. PASS.
