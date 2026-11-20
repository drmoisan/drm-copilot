Timestamp: 2026-03-14T23-24
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts --testNamePattern="newPotentialBugEntry direct mode rejects invalid short-name pattern"
EXIT_CODE: 1
Output Summary:
- Expected fail-before regression captured for `newPotentialBugEntry direct mode rejects invalid short-name pattern`.
- Failure detail: the handler resolved instead of rejecting an invalid direct `--short-name` value.
- Test Suites: 1 failed, 1 total.
- Tests: 1 failed, 39 skipped, 40 total.
