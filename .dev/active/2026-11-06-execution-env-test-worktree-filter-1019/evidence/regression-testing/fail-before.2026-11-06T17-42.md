# Fail-Before Run

Timestamp: 2026-11-06T17-41
Command: poetry run pytest tests/scripts/dev_tools/test_discovery_documentation_contracts.py -k test_execution_environment_fact_is_unchanged_across_copies -q --no-cov -p no:cacheprovider
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 1 failed, 31 deselected. `AssertionError: []` with `assert 0 == 6` at the count assertion. The run used an agent-isolated worktree whose path contains a directory named `worktrees`.

Interpreter note: `poetry env info -p` resolves to the shared main-checkout `.venv`, not inside this worktree, so `poetry install` was not run. The test file itself was collected from this worktree, and no dependency was changed.
