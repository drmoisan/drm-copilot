# QA Gate: TypeScript Tests With Coverage

Timestamp: 2026-10-02T01-50
Command: npm --prefix extensions/drm-copilot run test -- --coverage --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov
EXIT_CODE: 0
Loop iteration: 1
Output Summary:
- `Test Suites: 250 passed, 250 total`
- `Tests:       3786 passed, 3786 total`
- text-summary: `Statements   : 97.07% ( 50620/52146 )`, `Branches     : 91.35% ( 7391/8090 )`, `Functions    : 91.52% ( 1522/1663 )`, `Lines        : 97.07% ( 50620/52146 )`
- FinalTsLines%: 97.07
- FinalTsBranches%: 91.35
- FinalVerificationEvidenceRow (under `src/lib/pr-context`): `verification-evidence.ts | 96.94 | 84.61 | 100 | 96.94 | 133-134,273-274,284-285,290,292-293` (% Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s)
- Exit 0 also shows every existing per-file `coverageThreshold` entry is met.
- Substitution (deviation D-TOOLS): `node run-jest.cjs ...` from `extensions/drm-copilot` executed as `npm --prefix extensions/drm-copilot run test -- <same arguments>`.
