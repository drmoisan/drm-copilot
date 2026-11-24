# Queue Timeout: Phase 0 pytest Gate (P0-T5)

Timestamp: 2026-11-24T12-11
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest
EXIT_CODE: 75
Output Summary: TEST_EXECUTION_QUEUE_TIMEOUT: the machine test-suite lock was held by a pester suite of another worktree; waited 90000 ms. Recorded as a queue timeout, not a failure; the gate is re-run after the holder finishes.
