# Root Jest coverage run (feature re-review, remediation cycle 1, issue #1161)

Timestamp: 2026-11-14T01-27
Command: sh SCRATCH/rootjest.sh (in the item worktree root: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, normal Jest workers; per-file figures read from `coverage/lcov.info` at the worktree root)
EXIT_CODE: 0
Output Summary: Test Suites 345 passed of 345; Tests 5571 passed, 0 failed; started 2026-11-14T01:27:49Z, finished 2026-11-14T01:28:01Z. Root report totals: lines 98.29% (70203/71423), branches 93.68% (10489/11197; the Jest text summary prints 93.67% because it truncates). `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts`: lines 100.00% (179/179), branches 100.00% (44/44). `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`: lines 100.00% (499/499), branches 96.85% (123/127).

## Reason

The feature-review coverage contract names the worktree-root `coverage/lcov.info` as the TypeScript artifact. The root report from the S7 review (`jest-root-gate.2026-11-14T00-29.md`, written 2026-11-14T00:29:40Z) predates commit `d40a2ee0c` (2026-11-14T01:13:11Z), which changed `epic-planner-state-planner-worktrees.ts`. The executor's final cycle-1 Jest gate (`jest-gate.2026-11-14T01-18.md`) ran in `extensions/drm-copilot` and wrote only the extension report. The reviewer ran the root configuration once at reviewed head `b7913c32c` (one suite on the machine, normal workers). The run writes only gitignored output. The per-file figures equal the executor's extension report.
