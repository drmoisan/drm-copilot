# Coverage No-Regression Comparison — `extensions/drm-copilot` (#414, [P5-T6])

Timestamp: 2026-07-25T22-12

Both sides of this comparison use invocation (b), the rootDir-free jest run, because invocation (a) (`npm run test:coverage`) produces no coverage numbers from this worktree path. The two runs use the same jest binary, the same jest configuration, the same `testMatch` pattern, and the same coverage reporters; only the dependency tree differs.

## Sources

| Side | Task | Artifact |
|---|---|---|
| Baseline (pre-edit) | [P0-T13] | `evidence/baseline/test-coverage-extension.2026-07-25T17-08.md` |
| Post-change | [P5-T5] | `evidence/qa-gates/final-test-coverage-extension.2026-07-25T22-11.md` |

Invocation (b) command, identical on both sides:
`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --testMatch "**/test/**/*.test.ts"`
EXIT_CODE on both sides: 0

## Numeric Comparison

| Metric | Baseline ([P0-T13]) | Post-change ([P5-T5]) | Delta | Threshold | Status |
|---|---|---|---|---|---|
| Line coverage | 96.33% (37643/39074) | 96.33% (37643/39074) | 0.00 | >= 85% | PASS |
| Branch coverage | 89.21% (5201/5830) | 89.21% (5201/5830) | 0.00 | >= 75% | PASS |
| Statement coverage | 96.33% (37643/39074) | 96.33% (37643/39074) | 0.00 | n/a | — |
| Function coverage | 89.50% (1100/1229) | 89.50% (1100/1229) | 0.00 | n/a | — |

The absolute counts match exactly on both sides of every metric, not merely the rounded percentages.

## Test Totals Comparison

| | Baseline | Post-change | Delta |
|---|---|---|---|
| Test suites passed / total | 168 / 168 | 168 / 168 | 0 |
| Tests passed / total | 2031 / 2031 | 2031 / 2031 | 0 |
| Failures | 0 | 0 | 0 |

## Evaluation

Post-change line coverage (96.33%) is equal to the baseline (96.33%), and post-change branch coverage (89.21%) is equal to the baseline (89.21%). Both are `>=` their baseline, so there is no regression, and both remain above the policy thresholds of >=85% line and >=75% branch.

The zero delta is the expected result: #414 changes no source file. The change set is four dependency-manifest and lockfile files only, so the set of instrumented lines and the set of executed lines are both unchanged — confirmed here by the identical absolute counts (37643/39074 covered lines, 5201/5830 covered branches). The identical test totals (2031/2031 across 168 suites) confirm the forced `minimatch` 9→10 bump did not cause any suite to be skipped, dropped from discovery, or fail.

Output Summary: PASS, zero regression. Baseline line coverage 96.33% (37643/39074) and branch coverage 89.21% (5201/5830) are exactly matched post-change, including absolute counts, with statements 96.33% and functions 89.50% (1100/1229) likewise unchanged (delta 0.00 on every metric). Both metrics remain above the >=85% line / >=75% branch thresholds. Test totals are identical at 2031/2031 tests across 168/168 suites with 0 failures. The zero delta is expected because #414 modifies no source file.
