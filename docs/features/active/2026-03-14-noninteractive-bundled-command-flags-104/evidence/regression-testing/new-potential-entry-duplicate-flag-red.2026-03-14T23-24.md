Timestamp: 2026-03-14T23-24
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts --testNamePattern="newPotentialEntry direct mode rejects duplicate -ShortName flag"
EXIT_CODE: 1
Output Summary:
- Expected fail-before regression captured for `newPotentialEntry direct mode rejects duplicate -ShortName flag`.
- Failure detail: the handler resolved instead of rejecting duplicate `-ShortName` flags.
- Test Suites: 1 failed, 1 total.
- Tests: 1 failed, 37 skipped, 38 total.
