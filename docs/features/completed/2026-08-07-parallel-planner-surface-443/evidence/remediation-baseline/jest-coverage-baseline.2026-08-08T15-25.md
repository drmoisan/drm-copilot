# Remediation Baseline — Jest with Coverage

Timestamp: 2026-08-08T15-25

Task: [P0-T9]
Working directory: REPOSITORY ROOT (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59`)

Command: `npm run test:unit:coverage`

EXIT_CODE: 0

Output Summary: PASS. 182 test suites passed of 182 total; 2443 tests passed of 2443 total; 0 snapshots; runtime 6.978s. Total line coverage is 97.16% and total branch coverage is 89.53% per the Jest `All files` row. Both figures exceed the policy thresholds of >= 85% line and >= 75% branch. The changed-module reference file `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` reports 99.45% line and 87.82% branch, with lines 264-265 uncovered.

## Numeric Coverage Values

| Scope | Line coverage | Branch coverage |
|---|---|---|
| Repository total (`All files`) | 97.16% | 89.53% |
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | 99.45% | 87.82% |

Recomputed independently from `coverage/coverage-final.json` across 188 instrumented files: statements 42646/43892 = 97.1612%, branches 6009/6711 = 89.5396%. This confirms the reported `All files` row and resolves the 89.53%/89.54% discrepancy recorded across the two prior audit documents to 89.5396%, which the Jest reporter truncates to 89.53%.

## Raw Rows

```
All files                                    |   97.16 |    89.53 |   89.82 |   97.16 |
  parallel-kickoff-artifact.ts               |   99.45 |    87.82 |     100 |   99.45 | 264-265
```

## Suite and Test Counts

- Test Suites: 182 passed, 182 total
- Tests: 2443 passed, 2443 total
- Snapshots: 0 total
- Time: 6.978 s
