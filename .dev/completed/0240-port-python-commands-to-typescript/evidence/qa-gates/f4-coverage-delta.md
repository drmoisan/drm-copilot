# F4 Coverage Delta / Threshold Verification

Timestamp: 2026-06-26T00-50

Command:
- Baseline: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (recorded in `evidence/baseline/f4-ts-test-baseline.md`)
- Post-change: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (recorded in `evidence/qa-gates/f4-final-test-coverage.md`)

EXIT_CODE: 0 (both runs)

Output Summary:

Overall `src/lib/**` coverage (no-regression check):
- Baseline: line 95.75%, branch 88.72%.
- Post-change: line 96.09%, branch 89.40%.
- Delta: line +0.34 pts, branch +0.68 pts. No regression on overall `src/lib/**` coverage.

New / changed-code coverage (threshold check, line >= 85% / branch >= 75%):
- `src/lib/collect-commit-context.ts` (new file): line 100.00%, branch 96.96% — PASS.
- `src/lib/file-system.ts` (added `ensureDir`): file line 96.83%, branch 86.66% — PASS. The `ensureDir` method (single statement `fs.mkdirSync(path, { recursive: true })`) is exercised by `test/lib/file-system.test.ts` "creates a nested directory path recursively and is idempotent".

Conclusion: New-file coverage meets both thresholds and overall `src/lib/**` coverage did not regress. F4 coverage gate: PASS.
