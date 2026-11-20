# Final Jest Gate (P6-T7)

Timestamp: 2026-11-10T01-35
Command: sh SCRATCH/issue-1164-jest-gate.sh (in extensions/drm-copilot: node run-jest.cjs --coverage; normal workers)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-10T01-34 (UTC): Test Suites 341 passed of 341; Tests 5499 passed of 5499 (0 failed); Time 15.281 s (Phase 0 baseline: 340 suites, 5476 tests, 0 failed). The 341 suites include test/lib/validate/parallel-state-scheduling-parity.test.ts and test/lib/push-down/claude-blast-radius-overlay-parity.test.ts, both passed (no suite failed).
- Coverage summary (text-summary reporter): Lines 97.16% (63964/65830; baseline 97.15%); Branches 93.91% (9785/10419; baseline 93.87%).
- Per-file, from the lcov.info the run wrote (copied to SCRATCH/issue-1164-jest-final2-lcov.info), against the Phase 0 baseline:
  - src/lib/validate/parallel-state-records.ts: line 100.00% (643/643), branch 100.00% (141/141); baseline 100.00% / 100.00% (347/347, 66/66)
  - src/lib/validate/parallel-planner-state-core.ts: line 100.00% (468/468), branch 97.96% (48/49); baseline 100.00% / 97.96%
  - src/lib/validate/parallel-orchestrator-state-core.ts: line 99.39% (324/326), branch 92.11% (35/38); baseline 99.38% / 92.11%
- parallel-state-records.ts meets its coverageThreshold entry in extensions/drm-copilot/jest.config.cjs (lines 85, branches 75); the run reported no threshold failure.
- The first final Jest run, which left one branch of parallel-state-records.ts uncovered, is recorded in jest-gate.2026-11-10T01-29.md.
