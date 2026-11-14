# Review Rerun: Root Jest Coverage Gate (feature review)

Timestamp: 2026-11-14T17-45
Command: sh SCRATCH/fr1173-jest.sh (from the item worktree root: node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary; normal parallel workers); per-file figures parsed from coverage/lcov.info
EXIT_CODE: 0
Output Summary:
- Reason: the feature-review coverage Stop hook requires the worktree-root report `coverage/lcov.info`, which the executor's extension-only gate did not write, and the merge of origin/main (commit ec00c5389f10) is newer than the earlier reports.
- Run window (UTC, clock-read): 2026-11-14T17:40:58Z to 2026-11-14T17:41:16Z at head ec00c5389f10be134de8390cf839365fea5c5687, clean tree.
- Test Suites: 349 passed, 349 total. Tests: 5687 passed, 5687 total.
- Root coverage summary: lines 98.3% (70818/72038), branches 93.77% (10660/11368), functions 92.34%.
- Changed TypeScript files (line % / branch %): mcp-tool-inputs-docs.ts 99.61 / 98.10; mcp-tool-inputs-docs-ledger-batch.ts (new) 100 / 100; mcp-docs-tool-definitions.ts 100 / 93.33; repo-automation-execute-docs.ts 100 / 100; mcp-handlers/docs-handlers.ts 100 / 100.
- Deviation note: run through a scratch launcher calling `node run-jest.cjs`, not through `run-test-suite.sh jest`; the command is the same as the launcher's `jest` suite.
