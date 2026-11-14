# Jest Gate, Post-Merge (P6-T7 re-run after merge commit 25dcbcdc2)

Timestamp: 2026-11-10T04-04
Command: sh SCRATCH/issue-1164-jest-gate.sh (in extensions/drm-copilot: node run-jest.cjs --coverage; normal workers)
EXIT_CODE: 0
Output Summary:
- Test Suites 341 passed of 341; Tests 5499 passed of 5499 (0 failed); Time 45.08 s (Phase 0 baseline evidence/baseline/jest-gate.2026-11-09T23-40.md: 340 suites, 5476 tests, 0 failed). No suite failed, so test/lib/validate/parallel-state-scheduling-parity.test.ts and parallel-state-tolerated-edge-fields.test.ts passed.
- Coverage summary: Lines 97.16% (63979/65845; Phase 0 97.15%); Branches 93.91% (9785/10419; Phase 0 93.87%). No drop.
- Per-file, from the lcov.info of this run (copied to SCRATCH/issue-1164-jest-postmerge-lcov.info), versus Phase 0:
  - src/lib/validate/parallel-state-records.ts: line 658/658 = 100.00%, branch 141/141 = 100.00% (baseline 100.00% / 100.00%)
  - src/lib/validate/parallel-planner-state-core.ts: line 468/468 = 100.00%, branch 48/49 = 97.96% (baseline 100.00% / 97.96%)
  - src/lib/validate/parallel-orchestrator-state-core.ts: line 324/326 = 99.39%, branch 35/38 = 92.11% (baseline 99.38% / 92.11%)
- The merge from main changed no TypeScript file; figures equal the pre-merge final gate.
