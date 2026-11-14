# Jest root-configuration gate (feature-review reviewer run)

Timestamp: 2026-11-14T07-12
Command: node run-jest.cjs --coverage (worktree root configuration, Jest parallel workers), launched by the reviewer through sh SCRATCH/r1162-rootjest.sh at head 73ecccd13
EXIT_CODE: 0
Output Summary:
- Reason: the canonical TypeScript coverage report `coverage/lcov.info` at the worktree root was absent; the executor gate (`jest.2026-11-14T07-01.md`) ran the extension configuration only, which writes `extensions/drm-copilot/coverage/lcov.info`.
- Run: started 2026-11-14T07:11:57Z, ended 2026-11-14T07:12:20Z.
- Counts: 346 suites passed of 346; 5641 tests passed, 0 failed.
- Repository total (root report, all files): lines 98.29%, branches 93.72%.
- epic-orchestrator-state-resolution.ts: line 98.84%, branch 96.99% (uncovered lines 54-55, 57-58, 62-63, outside the added lines).
- epic-orchestrator-state-core.ts: line 100%, branch 96.15%.
- epic-orchestrator-state-wave-barrier.ts: line 100%, branch 98.55%.
- epic-planner-state-core.ts: line 100%, branch 96.96%.
- The report was written to `coverage/lcov.info` at the worktree root (gitignored).
