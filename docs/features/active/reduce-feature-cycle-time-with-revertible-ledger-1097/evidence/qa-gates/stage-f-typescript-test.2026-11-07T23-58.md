# Stage F TypeScript Test Gate (P3-T4, compared with the Phase 0 baseline)

Timestamp: 2026-11-07T23-58
Command: in extensions/drm-copilot: node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary (one run after the G5 fix; launcher stored under SCRATCH); per-file line and branch figures from extensions/drm-copilot/coverage/lcov.info by SCRATCH/sf/issue-1097-sf-lcov.py; baseline: stage-f-typescript-test-baseline.2026-11-07T23-08.md
EXIT_CODE: 0
Output Summary:
  Supersedes stage-f-typescript-test.2026-11-07T23-45.md, which reported EXIT_CODE 1 for the per-file branch figure of plan-gate-discrimination.ts. The fix commit with reduction: 0008 in its subject removes the unreachable blocking arm of the G5 channel choice in evaluateLiteral (G5_SEVERITY, every message, and every test expectation unchanged) and regenerates the 0008 stored patch.
  Run exit 0. Test Suites: 331 passed, 331 total (baseline 330). Tests: 5397 passed, 0 failed (baseline 5345). The per-file coverageThreshold entries passed. No test result changed with the fix: the count equals the earlier run.
  Suite counts: the reporter prints totals only. plan-gate-guideline-cutoff.test.ts is the one added suite (330 to 331), and plan-gate-document.test.ts and plan-gate-document-parity.test.ts are part of the 331 passed with the 52 added tests.
  src/lib/validate/plan-gate-document.ts: lines 100.00% (467 of 467), branches 95.83% (69 of 72); baseline 100.00% (337 of 337) and 95.08% (58 of 61). No drop.
  src/lib/validate/orchestration-artifacts.ts: lines 100.00% (375 of 375), branches 97.62% (82 of 84); baseline 100.00% (369 of 369) and 97.56% (80 of 82). No drop.
  src/lib/validate/plan-gate-discrimination.ts: lines 100.00% (302 of 302), branches 100.00% (55 of 55); baseline 100.00% (302 of 302) and 98.28% (57 of 58). No drop; the one uncovered branch of the baseline no longer exists.
  All three files reach 85% line and 75% branch coverage.
  Text-summary totals: Statements 97.09% (62303/64166), Branches 93.72% (9458/10091), Functions 91.94% (1861/2024), Lines 97.09% (62303/64166); baseline 97.09% (62167/64030), 93.71% (9447/10081), 91.93% (1859/2022), 97.09% (62167/64030). No total is below its baseline value.
  extensions/drm-copilot/coverage/lcov.info written by the run and left on disk.
