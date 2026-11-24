# Baseline: pytest gate (P0-T5)

Timestamp: 2026-11-24T05-52
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term --cov-report=json:SCRATCH/p0-py-coverage.json (run from the item worktree root through SCRATCH/issue-1233-gate-py.sh and SCRATCH/issue-1233-retry.sh; the launcher runs poetry run pytest -n auto)
EXIT_CODE: 0
Output Summary:
- Nine earlier attempts between 05-34 and 05-46 UTC ended with launcher exit 75 (TEST_EXECUTION_QUEUE_TIMEOUT: the machine lock was held by sibling worktrees); each is a queue timeout, not a failure, and the gate was re-run.
- Result: 17104 passed, 6 skipped, 0 failed in 204.74 s.
- Repo-wide coverage (JSON report totals): lines 35372/36090 (98.01%), branches 13100/13722 (95.47%), combined 97.31%; terminal TOTAL 97%.
- scripts/dev_tools/validate_orchestrator_state.py: lines 170/172 (98.84%), branches 80/82 (97.56%); missing lines 119 and 133.
- The JSON report is kept as SCRATCH/p0-py-coverage.json for the P5-T7 comparison.
