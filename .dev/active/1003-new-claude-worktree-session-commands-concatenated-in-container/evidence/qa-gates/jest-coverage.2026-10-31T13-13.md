# QA Gate: Jest with Coverage (Issue #1003)

Timestamp: 2026-10-31T13-13
Command: npm run test:coverage (in extensions/drm-copilot/; node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary), then node SCRATCH/issue-1003-lcov.cjs extensions/drm-copilot to read coverage/lcov.info
EXIT_CODE: 0
Output Summary: Tests: 5277 passed, 5277 total (326 suites); no `failed`; no `coverage threshold` line. Text summary Lines 97.06% (61859/63730), Branches 93.67% (9389/10023). Per file: src/worktree-session-launch.ts lines 100.00% (244/244), branches 100.00% (14/14); src/claude-worktree-session.ts lines 100.00% (260/260), branches 95.00% (19/20); src/codex-worktree-session.ts lines 100.00% (121/121), branches 100.00% (14/14); src/extension.ts lines 97.10% (435/448), branches 88.46% (46/52). All four files meet lines >= 85% and branches >= 75%.

## Jest summary

```
Test Suites: 326 passed, 326 total
Tests:       5277 passed, 5277 total
Statements   : 97.06% ( 61859/63730 )
Branches     : 93.67% ( 9389/10023 )
Functions    : 91.9% ( 1851/2014 )
Lines        : 97.06% ( 61859/63730 )
```

No line containing `coverage threshold` was printed.

## coverage/lcov.info per-file records

| SF | LF | LH | Lines % | BRF | BRH | Branches % | Threshold (lines/branches) | Result |
|---|---|---|---|---|---|---|---|---|
| src/worktree-session-launch.ts | 244 | 244 | 100.00% | 14 | 14 | 100.00% | 85/75 | PASS |
| src/claude-worktree-session.ts | 260 | 260 | 100.00% | 20 | 19 | 95.00% | 85/75 | PASS |
| src/codex-worktree-session.ts | 121 | 121 | 100.00% | 14 | 14 | 100.00% | 85/75 | PASS |
| src/extension.ts | 448 | 435 | 97.10% | 52 | 46 | 88.46% | 85/75 (ADD-ENTRY) | PASS |
