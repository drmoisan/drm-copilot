# Remediation cycle 2 — Phase 0 baseline, extension Jest gate ([P0-T4])

Timestamp: 2026-11-14T08-49
Command: sh SCRATCH/issue-1159-jest-ext.sh (from extensions/drm-copilot: npm run test:coverage, i.e. node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary, normal parallel workers)
EXIT_CODE: 1
Output Summary: Test Suites: 1 failed, 341 passed, 342 total. Tests: 1 failed, 5553 passed, 5554 total. Text-summary totals: Statements 97.17% (64214/66080), Branches 93.94% (9845/10479), Functions 92.17% (1919/2082), Lines 97.17% (64214/66080). coverageThreshold: no threshold failure line printed (every per-file entry met).

## Failing tests

- test/lib/push-down/codex-bundle-publish.integration.test.ts — "Codex bundle publish (real bundle, in-memory destination) › publishes every registered hook and its dot-source closure in typescript pack mode": "Expected: > 21", "Received:   10". Same failing test as the root baseline (jest-root.2026-11-14T08-48.md).
