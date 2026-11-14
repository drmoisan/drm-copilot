# Stage I TypeScript Test Gate (P3-T4)

Timestamp: 2026-11-08T17-59
Command: in extensions/drm-copilot, where the P0-T4 baseline ran: node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary (one run, after the P2-T3 commit and the P3-T1 restart pass; launcher stored under SCRATCH); per-file figures read from extensions/drm-copilot/coverage/lcov.info, copied to SCRATCH/issue-1097-i-final2-lcov.info
EXIT_CODE: 0
Output Summary:
  Test Suites: 339 passed, 339 total. Tests: 5474 passed, 0 failed (baseline 338 suites, 5446 tests, 0 failed). No failing test.
  Named suites unchanged and passing (no diff against HEAD): epic-orchestrator-state-wave-barrier.test.ts 16 cases, epic-orchestrator-state-core.test.ts 31, epic-orchestrator-state-core.ordering.test.ts 1, as in the baseline.
  New suite epic-orchestrator-state-early-start.test.ts passes (28 tests: matches the corpus for each case, reports nothing for an absent key, keeps the barrier errors in core order).
  src/lib/validate/epic-orchestrator-state-wave-barrier.ts (new): lines 100.00% (273 of 273), branches 98.08% (51 of 52); thresholds 85% and 75% hold; its coverageThreshold entry is enforced by drm-copilot-extension-tests in CI.
  src/lib/validate/epic-orchestrator-state-core.ts: lines 100.00% (395 of 395), branches 96.10% (74 of 77); baseline lines 98.78% (486 of 492), branches 93.55% (87 of 93). No drop; zero-count branch records 3 (baseline 6).
  Text-summary totals: Statements 97.15% (63657/65523), Branches 93.86% (9708/10342), Lines 97.15% (63657/65523); baseline 97.13%, 93.81%, 97.13%. No drop.
