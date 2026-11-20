# F8 Coverage Delta / Threshold Verification

Timestamp: 2026-06-26T00-00
Command:
- Baseline: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (see `evidence/baseline/f8-ts-test-baseline.md`)
- Final: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (see `evidence/qa-gates/f8-final-test-coverage.md`)
EXIT_CODE: 0

Output Summary:

Overall `src/lib/**` (All files):
- Baseline: line 97.36%, branch 87.55%.
- Post-change: line 97.73%, branch 88.29%.
- Delta: line +0.37 pts, branch +0.74 pts. No regression on overall `src/lib/**` coverage (both metrics increased).

New/changed-code coverage (every new `src/lib/new-active-feature-folder/**` file), line% / branch%:
- models.ts — 97.36% / 83.33%
- markdown.ts — 100% / 93.1%
- io.ts — 98.89% / 88.88%
- docs.ts — 100% / 100%
- flow.ts — 99.54% / 92.1%
- index.ts — 100% / 100% (re-export-only facade)
- new-active-feature-folder-service-call.ts — 100% / 100%

Threshold verification: every new executable file meets line >= 85% and branch >= 75%. Overall `src/lib/**` shows no regression. Result: PASS.
