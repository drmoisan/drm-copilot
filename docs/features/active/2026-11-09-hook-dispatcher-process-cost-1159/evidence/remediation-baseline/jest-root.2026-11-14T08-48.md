# Remediation cycle 2 — Phase 0 baseline, root Jest gate ([P0-T3])

Timestamp: 2026-11-14T08-48
Command: sh SCRATCH/issue-1159-jest-root.sh (from the worktree root: npm run test:unit:coverage, i.e. node run-jest.cjs --coverage, normal parallel workers)
EXIT_CODE: 1
Output Summary: Test Suites: 1 failed, 344 passed, 345 total. Tests: 1 failed, 5570 passed, 5571 total. Repo-wide coverage (text table "All files" row, v8): statements 98.29%, branches 93.67%, functions 92.28%, lines 98.29%.

## Failing tests

- extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts — "Codex bundle publish (real bundle, in-memory destination) › publishes every registered hook and its dot-source closure in typescript pack mode": expect(received).toBeGreaterThan(expected), "Expected: > 21", "Received:   10". This is the fail-before record for finding F2 (same message as CI runs 43570680445 and 43573314091).

No other test fails.
