# Code-point Order Block (P2-T6, AC-1, AC-2, AC-3)

Timestamp: 2026-10-08T02-38
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs --runTestsByPath test/lib/pr-context/models.test.ts -t "issue #740 code-point order"
EXIT_CODE: 0
Output Summary: PASS. 9 passed, 0 failed (D1, D2, D3, D4, S1, A1, A2, A3, A4), run against the escape-form source restored under DEV-7.

```
Test Suites: 1 passed, 1 total
Tests:       45 skipped, 9 passed, 54 total
```

Loop note: this command ran on loop pass 2 and again on loop pass 3, the final clean pass of P2-T1 through P2-T15 with no file changed (after the DEV-8 compaction of models.test.ts). Both passes gave identical results; the values above are from loop pass 3.
