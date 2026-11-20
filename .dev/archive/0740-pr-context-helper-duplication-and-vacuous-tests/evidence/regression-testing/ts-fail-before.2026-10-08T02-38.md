# Fail-before: code-point order block against pre-fix compareCodePoint (P1-T3) [expect-fail]

Timestamp: 2026-10-08T02-38
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs --runTestsByPath test/lib/pr-context/models.test.ts -t "issue #740 code-point order"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: EXPECTED FAIL observed. `Tests:       5 failed, 30 skipped, 4 passed, 39 total`. The five failing titles are exactly D1, D2, D3, D4, and S1; each scalar failure shows Expected -1 against Received 1 (UTF-16 code-unit result), and S1 shows the U+1F600 element sorted before U+E000 and U+FFFF. No compile error. A1-A4 pass (the two orders agree for those pairs).

State: models.ts unmodified (pre-fix `compareCodePoint` uses `left < right` / `left > right`). Test file: extensions/drm-copilot/test/lib/pr-context/models.test.ts after P1-T2.

## Failing titles (verbatim)

- compareCodePoint issue #740 code-point order › D1 orders U+FFFF before U+1F600 in both argument orders (Expected: -1, Received: 1)
- compareCodePoint issue #740 code-point order › D2 orders U+E000 before U+10000 (Expected: -1, Received: 1)
- compareCodePoint issue #740 code-point order › D3 orders U+FF5E before U+1F600 (Expected: -1, Received: 1)
- compareCodePoint issue #740 code-point order › D4 orders a shared-prefix U+FFFD before a shared-prefix U+1F600 (Expected: -1, Received: 1)
- compareCodePoint issue #740 code-point order › S1 sorts a mixed BMP and non-BMP array into a literal code-point order (received order places U+1F600 after U+00E9 and before U+E000, U+FFFF)

## Summary lines (verbatim)

```
Test Suites: 1 failed, 1 total
Tests:       5 failed, 30 skipped, 4 passed, 39 total
```
