# Direct Helper Tests (P2-T7, AC-7)

Timestamp: 2026-10-08T02-38
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs --runTestsByPath test/lib/pr-context/models.test.ts -t "^(sortedSet|escapeRegExp|splitLines) " ; cd extensions/drm-copilot && npx jest --config jest.config.cjs --runTestsByPath test/lib/pr-context/feature-docs.test.ts -t "^relativeToPosix "
EXIT_CODE: 0
Output Summary: PASS. Both commands exit 0. First: 15 passed, 0 failed. Second: 5 passed, 0 failed (includes the Windows-style root and the path-outside-root cases).

## Command 1 (models.test.ts)

```
Test Suites: 1 passed, 1 total
Tests:       39 skipped, 15 passed, 54 total
```

## Command 2 (feature-docs.test.ts)

```
Test Suites: 1 passed, 1 total
Tests:       28 skipped, 5 passed, 33 total
```

Loop note: this command ran on loop pass 2 and again on loop pass 3, the final clean pass of P2-T1 through P2-T15 with no file changed (after the DEV-8 compaction of models.test.ts). Both passes gave identical results; the values above are from loop pass 3.
