# TS Test and Coverage Gate ([P7-T5])

Timestamp: 2026-09-26T22-12

Loop iteration: 2

Command: `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov` (from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary:
- `Test Suites: 227 passed, 227 total`
- `Tests:       3130 passed, 3130 total` (0 failed)
- text-summary: `Lines        : 96.89% ( 48510/50063 )`; `Branches     : 90.79% ( 6970/7677 )`
- Exit 0 also shows every per-file `coverageThreshold` entry is met, including the `REQUIRED_JEST_KEYS` entries for `executable-resolver.ts`, `render-pr-helpers.ts`, and `autoclose.ts`.
- text rows (`File | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s`):
  - `executable-resolver.ts | 100 | 100 | 100 | 100 |`
  - `pr-context-service-call.ts | 100 | 93.75 | 100 | 100 | 59`
  - `render-pr-helpers.ts | 87.52 | 93.75 | 88.88 | 87.52 | 111-112,229-230,254-278,288-308,395-396`
  - `collector-core.ts | 97.97 | 89.28 | 100 | 97.97 | 214,227-228,306-308,395-396`
  - `autoclose.ts | 98.68 | 95.74 | 100 | 98.68 | 298-299,303-304` (TS_BUILDER_FILE)
- Every listed row has `% Lines` >= 85 and `% Branch` >= 75.
