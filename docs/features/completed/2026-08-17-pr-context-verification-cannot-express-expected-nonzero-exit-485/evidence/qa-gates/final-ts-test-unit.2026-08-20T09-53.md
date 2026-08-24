# Final QC — TypeScript unit tests (Jest)

Timestamp: 2026-08-20T09-53

Task: [P8-T8]

Command: (from `extensions/drm-copilot`) npm run test:unit    # node run-jest.cjs
EXIT_CODE: 0

## Result

```
Test Suites: 185 passed, 185 total
Tests:       2580 passed, 2580 total
Snapshots:   0 total
Time:        2.817 s
```

- Suites passed: **185 of 185**; suites failed: 0
- Tests passed: **2580 of 2580**; tests failed: 0

Baseline was 185 suites / 2558 tests, so the suite count is unchanged (the throwaway harness was
deleted at [P7-T7], leaving no new suite) and **22 tests were added**: 19 in
`verification-evidence.test.ts` (11 parametrized shape cases plus 8 named tests) and 3 in
`collector-output.test.ts` (one non-zero expectation case plus a two-variant parametrized zero case).

Output Summary: Jest passes with exit code 0 — 185 of 185 suites and 2580 of 2580 tests, 0 failures.
The suite count matches baseline (no throwaway harness remains) and 22 tests were added against the
2558-test baseline.
