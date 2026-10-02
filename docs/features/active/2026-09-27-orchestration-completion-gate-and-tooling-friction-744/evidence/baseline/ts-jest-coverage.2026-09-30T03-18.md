# Baseline TypeScript Tests With Coverage

Timestamp: 2026-10-02T01-17
Command: npm --prefix extensions/drm-copilot run test -- --coverage --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov
EXIT_CODE: 0
Output Summary:
- `Test Suites: 250 passed, 250 total`
- `Tests:       3786 passed, 3786 total`
- text-summary: `Statements   : 97.07% ( 50618/52144 )`, `Branches     : 91.35% ( 7391/8090 )`, `Functions    : 91.52% ( 1522/1663 )`, `Lines        : 97.07% ( 50618/52144 )`
- BaselineTsLines%: 97.07
- BaselineTsBranches%: 91.35
- BaselineVerificationEvidenceRow (under `src/lib/pr-context`): `verification-evidence.ts | 96.92 | 84.61 | 100 | 96.92 | 131-132,271-272,282-283,288,290-291` (% Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s)
- Substitution (deviation D-TOOLS): `node run-jest.cjs --coverage ...` from `extensions/drm-copilot` was executed as `npm --prefix extensions/drm-copilot run test -- <same arguments>`; the `test` script is `node run-jest.cjs` and npm runs it in `extensions/drm-copilot`, so `jest.config.cjs` resolves identically.
