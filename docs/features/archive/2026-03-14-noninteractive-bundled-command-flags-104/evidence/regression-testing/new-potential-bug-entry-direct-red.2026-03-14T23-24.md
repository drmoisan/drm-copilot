Timestamp: 2026-03-14T23-24
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts --testNamePattern="newPotentialBugEntry direct --short-name invocation skips prompts"
EXIT_CODE: 1
Output Summary:
- Expected fail-before regression captured for `newPotentialBugEntry direct --short-name invocation skips prompts`.
- Failure detail: `showInputBox` was called once instead of being skipped in direct mode.
- Test Suites: 1 failed, 1 total.
- Tests: 1 failed, 38 skipped, 39 total.
