# Final TypeScript Tests and Coverage (P17-T4)

Timestamp: 2026-09-27T18-12
Command: npm --prefix extensions/drm-copilot run test -- --coverage --coverageReporters=text --coverageReporters=lcov
EXIT_CODE: 0
Output Summary: PASS. Jest exited 0. Test Suites: 230 passed, 230 total. Tests: 3154 passed, 3154 total. No line begins "FAIL ". claude-blast-radius-derive-core.ts row: % Lines 100, % Branch 97.5 (% Stmts 100, % Funcs 88.88, uncovered line 315); the jest configuration's 85 line / 75 branch threshold for the derivation core did not fail the run. All files: % Lines 96.95, % Branch 90.91. The pack-manifest completeness test (test/lib/push-down/claude-pack-manifest-completeness.test.ts), run by path to attribute its result because the coverage run prints no per-suite lines, passed: 1 suite, 16 tests, exit 0.

## Jest summary lines (verbatim)

```text
Test Suites: 230 passed, 230 total
Tests:       3154 passed, 3154 total
Snapshots:   0 total
Time:        5.583 s, estimated 7 s
```

Lines beginning "FAIL ": none.

## Coverage table rows (verbatim)

```text
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
All files                                                   |   96.95 |    90.91 |   90.65 |   96.95 |
  claude-blast-radius-derive-core.ts                        |     100 |     97.5 |   88.88 |     100 | 315
```

| File | % Lines | % Branch |
| --- | --- | --- |
| claude-blast-radius-derive-core.ts | 100 | 97.5 |

The lcov report is written to extensions/drm-copilot/coverage/lcov.info (gitignored) and is read by P17-T5.

## Pack-manifest completeness test

Command: npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts
EXIT_CODE: 0

```text
Test Suites: 1 passed, 1 total
Tests:       16 passed, 16 total
```
