# Jest Phase 0 Baseline (remediation cycle 1, P0-T6)

Timestamp: 2026-11-11T06-24
Command: sh SCRATCH/issue-1164-jest-gate.sh baseline (in extensions/drm-copilot: node run-jest.cjs --coverage; normal workers); per-file figures read from the coverage/lcov.info this run wrote (copied to SCRATCH/issue-1164-jest-baseline-lcov.info)
EXIT_CODE: 0
Output Summary:
- Test Suites: 341 passed, 341 total; Tests: 5499 passed, 5499 total (0 failed); Time 18.116 s.
- Coverage summary: Lines 97.16% (63979/65845); Branches 93.91% (9785/10419).
- Per-file (lcov LF/LH, BRF/BRH):
  - src/lib/validate/parallel-state-shared.ts: line 473/486 = 97.33%, branch 100/103 = 97.09%
  - src/lib/validate/parallel-state-records.ts: line 658/658 = 100.00%, branch 141/141 = 100.00%
