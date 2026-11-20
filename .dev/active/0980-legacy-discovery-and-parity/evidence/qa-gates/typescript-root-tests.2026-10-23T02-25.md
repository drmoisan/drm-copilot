# P11-T3 TypeScript root test gate with coverage

Timestamp: 2026-10-23T02-25
Command: node run-jest.cjs --coverage --runInBand --coverageDirectory=SCRATCH/issue-980-jest-root-final --coverageReporters=json-summary --coverageReporters=json --coverageReporters=text-summary --json --outputFile=SCRATCH/issue-980-jest-root-final-results.json
EXIT_CODE: 0
Output Summary: 315 suites passed, 5013 tests passed, 0 failed, 0 pending (the root configuration collects tests/unit and the extension test tree). Coverage: statements and lines 98.2% (65007/66195), branches 93.23% (9631/10330), functions 91.81% (2054/2237). Baseline was 284 suites, 4122 tests, 97.98% lines and 92.35% branches, so the branch adds 31 suites and 891 tests at a higher aggregate coverage. The root configuration carries no coverage threshold; the per-file floors are enforced by the extension configuration (see `typescript-extension-tests.2026-10-23T02-25.md`).
