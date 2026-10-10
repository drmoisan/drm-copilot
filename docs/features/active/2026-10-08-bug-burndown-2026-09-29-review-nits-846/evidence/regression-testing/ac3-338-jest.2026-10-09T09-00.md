# Regression: #338 AC-3 corrected command run ([P7-T15], AC-24)

Timestamp: 2026-10-09T21-39
Command: npm run test:unit -- test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts test/lib/new-active-feature-folder/io-launcher.test.ts (run from extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: all three suites passed; zero failed.

```
> drm-copilot@1.0.0 test:unit
> node run-jest.cjs test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts test/lib/new-active-feature-folder/io-launcher.test.ts

Test Suites: 3 passed, 3 total
Tests:       61 passed, 61 total
Snapshots:   0 total
Time:        0.786 s
```

Acceptance (AC-24): exit 0; `Test Suites: 3 passed, 3 total`; `Tests:       61 passed, 61 total` (matches the 61 total derived from the recorded #338 run). PASS.
