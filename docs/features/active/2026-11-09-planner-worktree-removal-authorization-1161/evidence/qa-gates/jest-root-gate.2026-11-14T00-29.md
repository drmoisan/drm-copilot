# Root Jest coverage run (feature review, issue #1161)

Timestamp: 2026-11-14T00-29
Command: sh SCRATCH/rootjest.sh (in the item worktree root: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, normal Jest workers; per-file figures read from `coverage/lcov.info` at the worktree root)
EXIT_CODE: 0
Output Summary: Test Suites 345 passed of 345; Tests 5563 passed, 0 failed; started 2026-11-14T00:29:23Z, finished 2026-11-14T00:29:40Z. Root report totals: lines 98.29% (70196/71416), branches 93.68% (10489/11197). `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts`: lines 100.00% (172/172), branches 100.00% (44/44). `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`: lines 100.00% (499/499), branches 96.85% (123/127).

## Reason

The feature-review coverage contract names the worktree-root `coverage/lcov.info` as the TypeScript artifact. The executor's Jest gate (`jest-gate.2026-11-13T20-09.md`) ran in `extensions/drm-copilot` and wrote only `extensions/drm-copilot/coverage/lcov.info`; no root report existed at review start. The reviewer ran the root configuration once (one suite on the machine, normal workers) at reviewed head `6c8f1d9fa`. The run writes only gitignored output. No TypeScript file changed after the executor's run (newest TypeScript commit `f9a12f0e6`), and the per-file figures equal the executor's extension report.
