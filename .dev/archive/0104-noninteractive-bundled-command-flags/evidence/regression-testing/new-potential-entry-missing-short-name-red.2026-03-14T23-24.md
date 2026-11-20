Timestamp: 2026-03-14T23-24
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts --testNamePattern="newPotentialEntry direct mode rejects missing -ShortName value"
EXIT_CODE: 1
Output Summary:
- Expected fail-before regression captured for `newPotentialEntry direct mode rejects missing -ShortName value`.
- Failure detail: the handler resolved instead of rejecting when `-ShortName` was present without a value.
- Test Suites: 1 failed, 1 total.
- Tests: 1 failed, 36 skipped, 37 total.
