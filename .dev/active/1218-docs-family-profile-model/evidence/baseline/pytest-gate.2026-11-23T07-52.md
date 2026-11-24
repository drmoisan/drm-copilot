# Phase 0 Baseline pytest Gate (Issue #1218, P0-T4)

Timestamp: 2026-11-23T07-52
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (one pytest -n auto run through the launcher, worktree form; retried by SCRATCH/issue-1218-gate.sh while the launcher exited 75)
EXIT_CODE: 0
Output Summary:
- Queue timeouts recorded (not failures): 14 launcher exits 75 between 2026-11-23T07-28 and 2026-11-23T07-50 (one direct attempt plus attempts 1-13 of the retry script), each `TEST_EXECUTION_QUEUE_TIMEOUT:` with the machine lock held by a Pester suite of another worktree. Attempt 14 ran the gate.
- Worktree Poetry environment: `env -u VIRTUAL_ENV poetry env info -p` resolved to the worktree `.venv` after `env -u VIRTUAL_ENV poetry install` (in-project setting true).
- Result: 24 workers, 17110 items collected; 17104 passed, 6 skipped, 0 failed in 74.76s.
- Pre-existing failures: none. The contract tests tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, and test_push_down_pack_manifest_dependency_closure.py ran in this gate with no failure.
- Python coverage: not in scope (no Python file changes in this feature).
