# CLI Regression Tests, Expected Failure Before CLI Module Exists (Issue #464)

Timestamp: 2026-09-30T08-31
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py -q -p no:cacheprovider --no-cov
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary:
- Pytest stopped with `Interrupted: 1 error during collection` and `1 error in 0.17s`; no tests collected.
- Collection error: `ModuleNotFoundError: No module named 'scripts.dev_tools.validate_orchestrator_state_cli'`, raised at the `import scripts.dev_tools.validate_orchestrator_state_cli as cli` line (line 26) of the test module. The observed exception class matches the expected `ModuleNotFoundError`.
- Test file length: 359 lines (below the 500-line limit). The `--collect-only` run (P1-T1) reported the same `ModuleNotFoundError` with exit code 2.
- `git grep -c --untracked -F "runpy.run_module"` on the test file printed `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py:1` (P1-T6).
- Deviation note: `-q -p no:cacheprovider --no-cov` added to the planned command to reduce output and skip coverage collection; `wc -l` replaced by a single-line Python line count because `wc` is not on the Bash allowlist.
