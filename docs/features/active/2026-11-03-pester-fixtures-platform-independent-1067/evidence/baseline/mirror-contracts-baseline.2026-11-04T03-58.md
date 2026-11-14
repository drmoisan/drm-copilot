# Mirror Contract Baseline (P0-T7)

Timestamp: 2026-11-04T03-58
Command: poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q
EXIT_CODE: 0
Output Summary:
- Pytest summary line: `24 passed in 0.58s` (no failed or error count printed).
- Micro-action before the run: the worktree virtual environment lacked pytest-cov, so the first attempt stopped at argument parsing (`unrecognized arguments: --cov-report=lcov:...`); `poetry install --no-interaction --no-root` in the worktree installed the locked dependencies without changing any tracked file, and the command above was then run.
