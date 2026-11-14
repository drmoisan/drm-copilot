# Phase 0 Baseline - pytest Gate (P0-T3)

Timestamp: 2026-11-14T19-12
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (launched from the item worktree root by SCRATCH/issue-1187-pytest-gate.sh; pytest -n auto, 24 workers)
EXIT_CODE: 0
Output Summary:
- 16928 passed, 6 skipped in 63.17s; 0 failed; 16934 items collected.
- Skipped: five test_parallel_manifest_bash_parity.py manifest_m1 rows (no accessor expectation) and one test_blast_radius_regression_452.py row (issue #722 tolerance layer absent); none of the three contract files below is skipped.
- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py: passed (no failure or skip reported).
- tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py: passed (no failure or skip reported).
- tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py: passed (no failure or skip reported).
- Queue note: an earlier attempt at 2026-11-14T18-59 exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT, lock held by a Pester suite of another worktree); it is a queue timeout, not a failure, and this run is the re-run after the holder exited.
