# TS Baseline Tests with Coverage ([P0-T14])

Timestamp: 2026-09-26T21-18

Command: `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov` (from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary:
- `Test Suites: 225 passed, 225 total`
- `Tests:       3108 passed, 3108 total`
- text-summary: `Lines        : 96.88% ( 48372/49925 )`; `Branches     : 90.76% ( 6941/7647 )`
- text rows (`File | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s`):
  - `pr-context-service-call.ts | 100 | 93.33 | 100 | 100 | 57`
  - `render-pr-helpers.ts | 87.52 | 93.75 | 88.88 | 87.52 | 111-112,229-230,254-278,288-308,395-396`
  - `collector-core.ts | 97.97 | 91.22 | 100 | 97.97 | 214,227-228,306-308,395-396`
  - `autoclose.ts | 98.65 | 95.55 | 100 | 98.65 | 292-293,297-298` (TS_BUILDER_FILE)
- No listed row is below 85% lines or 75% branches. No failed test.
