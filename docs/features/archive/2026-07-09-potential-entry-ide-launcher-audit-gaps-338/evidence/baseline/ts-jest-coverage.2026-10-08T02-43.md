Timestamp: 2026-10-08T02-43
Command: npm run test:unit -- --coverage --coverageReporters=text --coverageReporters=lcov (run from extensions/drm-copilot; output redirected to a scratchpad log, then read back)
EXIT_CODE: 0
Output Summary: Test Suites: 253 passed, 253 total
Tests:       3852 passed, 3852 total
BASELINE TYPESCRIPT PASS COUNT N = 3852.
Coverage rows (verbatim):
  new-potential-bug-entry.ts                                |   95.87 |    82.97 |   91.66 |   95.87 | 263-272,348-351,404-408
  io-launcher.ts                                            |   97.87 |    84.61 |      80 |   97.87 | 81-84
Columns: % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s. new-potential-bug-entry.ts: % Branch 82.97, % Lines 95.87. io-launcher.ts: % Branch 84.61, % Lines 97.87. Exit 0 also confirms repo-wide per-file coverageThreshold entries hold.
