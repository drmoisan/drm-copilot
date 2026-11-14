# Jest Phase 0 baseline (P0-T7)

Timestamp: 2026-11-10T03-35
Command: node run-jest.cjs --coverage (in extensions/drm-copilot, through sh SCRATCH/issue-1162-jest.sh; Jest normal parallel workers)
EXIT_CODE: 0
Output Summary:
- Counts: 340 suites passed of 340; 5476 tests passed, 0 failed.
- Repository total (v8 provider): lines 97.15% (63660/65526), branches 93.87% (9710/10344).
- epic-orchestrator-state-resolution.ts: line 97.91% (281/287), branch 93.85% (61/65).
- epic-orchestrator-state-core.ts: line 100.00% (395/395), branch 96.10% (74/77).
- epic-orchestrator-state-wave-barrier.ts: line 100.00% (273/273), branch 98.08% (51/52).
- epic-planner-state-core.ts: line 100.00% (495/495), branch 96.85% (123/127).
- Per-file figures read from extensions/drm-copilot/coverage/lcov.info (copy kept as SCRATCH/issue-1162-jest-lcov-baseline.info). Every figure is at or above the 85% line and 75% branch thresholds, so P2-T3 needs no additional raising tests.
- Jest printed a "worker process has failed to exit gracefully" notice; it did not fail any suite.
