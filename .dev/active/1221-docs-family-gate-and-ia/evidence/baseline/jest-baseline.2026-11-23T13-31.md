# Phase 0 Baseline - Jest Coverage Gate (P0-T4)

Timestamp: 2026-11-23T13-27
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (node run-jest.cjs in extensions/drm-copilot, normal parallel workers); per-file figures read from extensions/drm-copilot/coverage/lcov.info with SCRATCH/issue-1221-lcov.sh
EXIT_CODE: 0
Output Summary: Test Suites 412 passed of 412; Tests 6707 passed of 6707; 0 failures. Totals (text-summary): statements 97.59%, branches 94.96%, functions 93.35%, lines 97.59%. Per file (lcov.info): src/mcp-docs-tool-definitions.ts lines 147/147 (100.00%), branches 14/15 (93.33%); src/mcp-handlers/docs-handlers.ts lines 55/55 (100.00%), branches 9/9 (100.00%).

## Queue Timeouts

The machine test-suite lock was held by a pester suite of another worktree. The launcher exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT) on these attempts, each recorded as a queue timeout and re-run, not as a failure:

- 2026-11-23T13-15 (single attempt), then 2026-11-23T13-17, 13-19, 13-20, 13-22, 13-23 (retry script, 5 attempts), then 2026-11-23T13-25 (first attempt of the second retry script).
- The run that produced the recorded result started at 2026-11-23T13-27 and ended at 2026-11-23T13-28 with exit 0.

A copy of lcov.info was kept under SCRATCH/baseline-jest/ for the final comparison.
