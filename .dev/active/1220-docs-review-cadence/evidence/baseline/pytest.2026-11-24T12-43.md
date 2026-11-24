# Phase 0 Baseline: pytest Gate (P0-T5)

Timestamp: 2026-11-24T12-43
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (launcher pytest suite: poetry run pytest -n auto, integration and golden lanes excluded; testpaths tests), run through SCRATCH/issue-1220-retry.sh, which re-ran the launcher after each queue timeout
EXIT_CODE: 0
Output Summary: 17104 passed, 6 skipped, 0 failed in 91.04s. The four push-down contract files test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py and test_push_down_pack_manifest_dependency_closure.py are under testpaths and had no failure (pass). No Python file is in scope, so no Python coverage threshold applies.

Queue: attempts 1-18 exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT, the machine lock was held by pester suites of other worktrees); attempt 19 ran the suite. The first launcher call is recorded in FEATURE/evidence/other/queue-timeout.pytest-baseline.2026-11-24T12-11.md.

Skipped tests (pre-existing): five cases of tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py and one of tests/scripts/dev_tools/test_blast_radius_regression_452.py.
