# Jest gate - worktree-root coverage run (feature review)

Timestamp: 2026-11-18T01-22
Command: node run-jest.cjs --coverage (run once at the worktree root by the feature-review agent through a scratch `sh` launcher; Jest parallel workers)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-18T01-22-07 to 2026-11-18T01-22-30 UTC at head 89d0e58610eac3b66504ca2ba27a6d22a8f15312.
- Test Suites: 352 passed, 352 total. Tests: 5717 passed, 5717 total. Failing tests: none.
- All files (root `jest.config.cjs` scope): lines 98.3%, branches 93.78%, functions 92.38%.
- extensions/drm-copilot/src/lib/push-down/claude-customizations.ts: lines 100%, branches 96.82% (uncovered branch lines 236 and 301, unchanged by this branch).
- Purpose: the canonical TypeScript coverage artifact `coverage/lcov.info` at the worktree root was absent at review start (the executor's Jest gate wrote its report to the scratch directory). This run produced it; it writes only gitignored output and changes no tracked file.
