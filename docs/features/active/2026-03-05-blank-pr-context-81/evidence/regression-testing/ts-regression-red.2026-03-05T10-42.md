Timestamp: 2026-03-05T10-42
Command: cd extensions/scaffold-extension && npm run test -- extension.collect-pr-context.test.ts
EXIT_CODE: 1
Output Summary:
- Targeted Jest run failed as expected for pre-fix regression lock.
- Failing test: `fails_when_summary_is_placeholder_only`.
- Failure excerpt: `Received promise resolved instead of rejected` (placeholder-only summary currently accepted).
