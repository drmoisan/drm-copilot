# typescript-root-tests

Timestamp: 2026-10-18T03-55
Command: node run-jest.cjs --coverage --runInBand --coverageDirectory=SCRATCH/issue-980-jest-root --coverageReporters=json-summary --coverageReporters=json --coverageReporters=text-summary --json --outputFile=SCRATCH/issue-980-jest-root-results.json
EXIT_CODE: 0
Output Summary: 4122 passed, 0 failed, 0 pending; 284/284 suites passed. Lines 97.98%, branches 92.35%; 5 discovery wrapper files retain per-file metrics.

Working directory: .
Started: 2026-10-18T03:53:52.547111+00:00
Duration seconds: 88.671
Phase: P0 baseline; no implementation repair is performed by this command.

## Captured output

```text
jest-haste-map: Haste module naming collision: drm-copilot
  The following files share their name; please adjust your hasteImpl:
    * <rootDir>\package.json
    * <rootDir>\extensions\drm-copilot\package.json


=============================== Coverage summary ===============================
Statements   : 97.98% ( 56394/57553 )
Branches     : 92.35% ( 8263/8947 )
Functions    : 91.45% ( 1756/1920 )
Lines        : 97.98% ( 56394/57553 )
================================================================================

Test Suites: 284 passed, 284 total
Tests:       4122 passed, 4122 total
Snapshots:   0 total
Time:        88.01 s
Ran all test suites.
Test results written to: SCRATCH\issue-980-jest-root-results.json
```

## Machine-readable evidence

- coverage-summary: typescript-root-coverage-summary.2026-10-18T03-55.json
- coverage-final: typescript-root-coverage-final.2026-10-18T03-55.json
- test-results: typescript-root-test-results.2026-10-18T03-55.json
