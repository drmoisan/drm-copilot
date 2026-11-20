# Baseline Pytest

Timestamp: 2026-11-06T17-49
Source artifact: evidence/regression-testing/fail-before.2026-11-06T17-42.md
Command: poetry run pytest tests/scripts/dev_tools/test_discovery_documentation_contracts.py -k test_execution_environment_fact_is_unchanged_across_copies -q --no-cov -p no:cacheprovider
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 1 failed, 31 deselected; assert 0 == 6 at the count assertion (checkout path contains a worktrees directory). Fail-before evidence for AC3.
