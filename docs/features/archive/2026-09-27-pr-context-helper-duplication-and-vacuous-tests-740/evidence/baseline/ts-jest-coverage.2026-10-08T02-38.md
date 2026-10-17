# Baseline Full Suite with Coverage (P0-T15)

Timestamp: 2026-10-08T02-38
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary
EXIT_CODE: 0
Output Summary: PASS. No `coverage threshold` failure line.
  Test Suites: 253 passed, 253 total
  Tests:       3852 passed, 3852 total
  Statements   : 97.11% ( 51037/52551 )
  Branches     : 91.53% ( 7503/8197 )
  Functions    : 91.56% ( 1531/1672 )
  Lines        : 97.11% ( 51037/52551 )
  Per-file (SUMMARY, lines.pct (covered/total), branches.pct (covered/total)):
  models.ts: lines 100 (348/348), branches 100 (44/44)
  collector-core.ts: lines 98.44 (380/386), branches 92.45 (49/53)
  render.ts: lines 99 (396/400), branches 90.41 (66/73)
  gh-client-details.ts: lines 96.12 (372/387), branches 91.46 (75/82)
  render-pr-helpers.ts: lines 87.71 (357/407), branches 94.73 (72/76)
  verification-evidence.ts: lines 96.94 (286/295), branches 84.61 (33/39)
  render-feature-excerpts.ts: lines 97.51 (431/442), branches 88.88 (80/90)
  feature-docs-parsers.ts: lines 97.46 (308/316), branches 89.47 (51/57)

Stop-condition check: render.ts, gh-client-details.ts, and verification-evidence.ts are each at or above 85 lines and 75 branches, so P1-T18 is permitted to run.

Per-file values were extracted from extensions/drm-copilot/coverage/coverage-summary.json by a session-scratch Node script that locates each key ending in `pr-context/<file>`.
