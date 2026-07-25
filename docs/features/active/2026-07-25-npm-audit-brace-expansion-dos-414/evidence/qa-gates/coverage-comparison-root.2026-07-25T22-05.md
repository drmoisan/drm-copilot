# Coverage No-Regression Comparison — Repository Root (#414, [P4-T7])

Timestamp: 2026-07-25T22-05

Both sides of this comparison use invocation (b), the rootDir-free jest run, because invocation (a) (`npm run test:unit:coverage`) produces no coverage numbers from this worktree path. The two runs use the same jest binary, the same `jest.config.cjs`, the same `testMatch` patterns, and the same coverage provider; only the dependency tree differs.

## Sources

| Side | Task | Artifact |
|---|---|---|
| Baseline (pre-edit) | [P0-T11] | `evidence/baseline/test-unit-coverage-root.2026-07-25T17-05.md` |
| Post-change | [P4-T5] | `evidence/qa-gates/final-test-unit-coverage-root.2026-07-25T22-02.md` |

Invocation (b) command, identical on both sides:
`node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"`
EXIT_CODE on both sides: 0

## Numeric Comparison

| Metric | Baseline ([P0-T11]) | Post-change ([P4-T5]) | Delta | Threshold | Status |
|---|---|---|---|---|---|
| Line coverage | 97.00% | 97.00% | 0.00 | >= 85% | PASS |
| Branch coverage | 89.06% | 89.06% | 0.00 | >= 75% | PASS |
| Statement coverage | 97.00% | 97.00% | 0.00 | n/a | — |
| Function coverage | 89.28% | 89.28% | 0.00 | n/a | — |

## Test Totals Comparison

| | Baseline | Post-change | Delta |
|---|---|---|---|
| Test suites passed / total | 169 / 169 | 169 / 169 | 0 |
| Tests passed / total | 2032 / 2032 | 2032 / 2032 | 0 |
| Failures | 0 | 0 | 0 |

## Evaluation

Post-change line coverage (97.00%) is equal to the baseline (97.00%), and post-change branch coverage (89.06%) is equal to the baseline (89.06%). Both are `>=` their baseline, so there is no regression, and both remain above the policy thresholds of >=85% line and >=75% branch.

The zero delta is the expected result: #414 changes no source file. The change set is four dependency-manifest and lockfile files only, so the set of instrumented lines and the set of executed lines are both unchanged. The identical test totals (2032/2032 across 169 suites) confirm the forced `minimatch` 9→10 bump did not cause any suite to be skipped, dropped from discovery, or fail.

Output Summary: PASS, zero regression. Baseline line coverage 97.00% and branch coverage 89.06% are exactly matched post-change at line 97.00% and branch 89.06% (delta 0.00 on both), with statements 97.00% and functions 89.28% likewise unchanged. Both metrics remain above the >=85% line / >=75% branch thresholds. Test totals are identical at 2032/2032 tests across 169/169 suites with 0 failures. The zero delta is expected because #414 modifies no source file.
