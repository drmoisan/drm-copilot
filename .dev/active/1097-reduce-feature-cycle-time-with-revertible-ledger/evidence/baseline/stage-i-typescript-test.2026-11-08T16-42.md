# Stage I TypeScript Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-08T16-42
Command: in extensions/drm-copilot (the Jest route of the execution-environment brief; the worktree root has no node_modules): node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary (one run; launcher stored under SCRATCH); per-file figures read from extensions/drm-copilot/coverage/lcov.info, copied to SCRATCH/issue-1097-i-baseline-lcov.info
EXIT_CODE: 0
Output Summary:
  Test Suites: 338 passed, 338 total. Tests: 5446 passed, 0 failed. No failing test.
  Named suites (cases counted from the source: it calls plus it.each rows): epic-orchestrator-state-wave-barrier.test.ts 16 (2 it plus 14 start-guard rows); epic-orchestrator-state-core.test.ts 31; epic-orchestrator-state-core.ordering.test.ts 1; all in the passing total.
  src/lib/validate/epic-orchestrator-state-core.ts: lines 98.78% (486 of 492), branches 93.55% (87 of 93); zero-count branch records at the BRDA lines 181, 223, 359, 364, 400, 443.
  Text-summary totals: Statements 97.13% (63473/65347), Branches 93.81% (9666/10303), Functions 92.09% (1900/2063), Lines 97.13% (63473/65347).
