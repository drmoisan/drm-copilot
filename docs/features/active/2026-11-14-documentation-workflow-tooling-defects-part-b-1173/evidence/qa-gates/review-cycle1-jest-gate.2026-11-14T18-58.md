# Review Rerun: Root Jest Coverage Gate (feature review, cycle 1 re-audit)

Timestamp: 2026-11-14T18-58
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest --coverage --coverageReporters=lcov --coverageReporters=text-summary (from the item worktree root, through a scratch runner that retried on exit 75; normal parallel workers); per-file figures parsed from coverage/lcov.info
EXIT_CODE: 0
Output Summary:
- Reason: the feature-review coverage Stop hook compares coverage/lcov.info with the newest commit touching TypeScript files (c30225091, 2026-11-14T18:40:29Z); the existing report was written at 2026-11-14T17:41Z, before it, and did not contain the new grammar module.
- Launch attempts (UTC, clock-read): 18:50:54Z and 18:53:25Z exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT; lock held by another worktree's Pester suite). The run started 18:55:56Z and ended 18:57:36Z at head aea5742dc2b628f2c095ce9cf71aa53f18a538de, clean tree.
- Test Suites: 347 passed, 347 total. Tests: 5698 passed, 5698 total.
- Root coverage summary: lines 98.16% (70753/72076), branches 93.78% (10631/11335), functions 91.84%. coverage/lcov.info written 2026-11-14T18:57:35Z.
- Changed TypeScript files (lines covered/total, branches covered/total): mcp-tool-inputs-docs.ts 405/407 (99.51%), 102/103 (99.03%); mcp-tool-inputs-docs-grammar.ts (new) 139/139 (100%), 17/17 (100%); mcp-tool-inputs-docs-ledger-batch.ts (new) 206/206 (100%), 55/55 (100%); mcp-docs-tool-definitions.ts 147/147 (100%), 14/15 (93.33%); repo-automation-execute-docs.ts 188/188 (100%), 19/19 (100%); mcp-handlers/docs-handlers.ts 55/55 (100%), 9/9 (100%).
- Per-file figures equal the executor's cycle 1 final gate (evidence/qa-gates/final-qc-jest.2026-11-14T18-41.md). The root total differs from the prior review rerun (98.3% lines) because the merge of origin/main changed the measured file set.
