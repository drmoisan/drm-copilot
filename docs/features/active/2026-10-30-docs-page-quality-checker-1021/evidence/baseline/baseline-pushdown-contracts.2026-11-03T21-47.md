# Baseline Push-Down Contracts - Issue #1021

Timestamp: 2026-11-03T21-47
Task: [P0-T9]
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -p no:cacheprovider --no-cov -q`
EXIT_CODE: 0
Output Summary: 32 passed, 0 failed (2.74s).

Note: the worktree Poetry environment held only pip on first use (`pytest_cov` missing, exit 4 on the first attempt); `poetry install --no-interaction --no-root` populated the worktree `.venv` from the committed lock file (no tracked file changed) before the recorded run.
