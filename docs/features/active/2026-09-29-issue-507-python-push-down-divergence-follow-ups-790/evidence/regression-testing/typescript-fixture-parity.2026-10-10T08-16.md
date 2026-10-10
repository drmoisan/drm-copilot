# P2-T3 - Pin the TypeScript merge against the shared fixture before any Python change

Timestamp: 2026-10-10T08-16
Command: npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-gitignore-merge-parity.test.ts
EXIT_CODE: 0
Output Summary:
- `Test Suites: 1 passed, 1 total`; `Tests:       12 passed, 12 total` (planned: 12 passed, 12 total = 1 name-order test + 11 `it.each` cases).
- Every Appendix B `expected` value equals the existing TypeScript `mergeClaudeGitignore` output; no fixture correction was needed.
- An earlier invocation of the same command with `--verbose` appended (same result, 12 passed) is superseded by this exact-command run.
- Result: PASS.
