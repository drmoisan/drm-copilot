# F7 Coverage Delta / Threshold Verification

Timestamp: 2026-06-26T01-12
Command:
- Baseline: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" (see f7-ts-test-baseline.md)
- Post-change: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" (see f7-final-test-coverage.md)
EXIT_CODE: 0

Output Summary:

Overall `src/lib/**` coverage:
- Baseline:     line 96.97%, branch 87.93% (825 tests)
- Post-change:  line 97.36%, branch 87.55% (908 tests)
- Line coverage improved by +0.39 points. Branch coverage moved -0.38 points,
  remaining far above the 75% policy floor. The slight overall-branch movement
  reflects adding five new production files whose subtree branch (84.00%) is
  above threshold but below the pre-existing `src/lib/**` average; it is not a
  regression on changed lines and every new file meets the per-file thresholds.

New / changed-code coverage (every new src/lib/potential-to-issue/** file):
- content.ts:                          line 99.16%, branch 88.70%  (>= 85% / >= 75%: PASS)
- gh-client.ts:                        line 100.00%, branch 79.31% (PASS)
- promotion.ts:                        line 98.85%, branch 81.96%  (PASS)
- promotion-filesystem.ts:             line 100.00%, branch 85.71% (PASS)
- potential-to-issue-service-call.ts:  line 100.00%, branch 81.25% (PASS)

Changed production file (delegation only):
- src/repo-automation-service.ts: the `potentialToIssue` method now delegates to
  the new helper; covered by the reworked extension suite and the service-call
  unit suite.

Conclusion: No regression below policy thresholds on overall `src/lib/**`
coverage; all new files meet the >= 85% line / >= 75% branch thresholds.
Outcome: PASS.
