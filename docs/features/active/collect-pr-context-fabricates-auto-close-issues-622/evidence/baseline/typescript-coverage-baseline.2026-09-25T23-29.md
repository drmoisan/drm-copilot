# TypeScript Coverage Baseline (P0-T24)

Timestamp: 2026-09-26T19-43
Command: node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov (from extensions/drm-copilot)
EXIT_CODE: 0

Output Summary:
- `Test Suites: 220 passed, 220 total`
- `Tests:       3011 passed, 3011 total`
- text-summary: Lines 96.85% (48119/49681); Branches 90.55% (6884/7602).
- text rows (File | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s), src/lib/pr-context:
  - models.ts | 100 | 100 | 100 | 100 |
  - feature-docs-parsers.ts | 96.89 | 88.52 | 100 | 96.89 | 192-193,247-248,253-254,300-301,311-312
  - render-feature-excerpts.ts | 95.08 | 84.26 | 100 | 95.08 | 71-72,77-81,101-102,366-367,379-380,384-386,431-432,437-438,442-443
  - render-pr-helpers.ts | 88.77 | 93.02 | 88.88 | 88.77 | 109-110,164-165,224-225,249-273,283-303,459-460
  - collector-core.ts | 97.89 | 89.85 | 100 | 97.89 | 208,227-228,297-299,427-428,474-475
- None of the five files is below 85 % Lines or 75 % Branch.
