# Python Test + Coverage Baseline (Pytest)

Timestamp: 2026-06-24T22-12
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing tests/scripts/dev_tools
EXIT_CODE: 0
Output Summary:
- Tests: 1098 passed, 19 skipped (skips are .codex/.agents gitignored-in-CI contract tests, unrelated to this feature).
- TOTAL line coverage (whole measured denominator): 83% (8391 stmts, 1218 miss).
- TOTAL branch coverage: 2994 branches, 420 partial.
- Module-of-interest baseline: scripts/dev_tools/push_down_claude_customizations.py = 88% line (92 stmts, 10 miss; 12 branches, 1 partial).
- The 83% TOTAL is dominated by out-of-scope modules not exercised by this test path (e.g., shell_qc.py 0%, tk_dialog_helpers.py 45%). The feature-relevant push-down modules are 88-97%.
