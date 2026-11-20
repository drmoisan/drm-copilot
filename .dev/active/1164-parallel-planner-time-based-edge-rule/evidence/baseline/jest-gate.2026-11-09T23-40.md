# Jest Phase 0 Baseline (P0-T6)

Timestamp: 2026-11-09T23-40
Command: sh SCRATCH/issue-1164-jest-gate.sh (in extensions/drm-copilot: node run-jest.cjs --coverage; normal workers)
EXIT_CODE: 0
Output Summary:
- Test Suites: 340 passed, 340 total; Tests: 5476 passed, 5476 total (0 failed); Time 14.324 s.
- Coverage summary (text-summary reporter): Lines 97.15% (63660/65526); Branches 93.87% (9710/10344).
- Per-file, from the lcov.info the run wrote (copied to SCRATCH/issue-1164-jest-p0-lcov.info):
  - src/lib/validate/parallel-state-records.ts: line 100.00% (347/347), branch 100.00% (66/66)
  - src/lib/validate/parallel-planner-state-core.ts: line 100.00% (464/464), branch 97.96% (48/49)
  - src/lib/validate/parallel-orchestrator-state-core.ts: line 99.38% (320/322), branch 92.11% (35/38)
