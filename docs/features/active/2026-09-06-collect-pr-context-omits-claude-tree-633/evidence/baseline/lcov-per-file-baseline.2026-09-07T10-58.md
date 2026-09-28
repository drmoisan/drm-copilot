Timestamp: 2026-09-07T10-58

Source: extensions/drm-copilot/coverage/lcov.info (produced by P0-T10's `npm run test:coverage` run)

## collector-core.ts (SF:src\lib\pr-context\collector-core.ts)
- LF: 472, LH: 461 -> Lines: 97.67%
- BRF: 67, BRH: 58 -> Branches: 86.57%

## collector-output.ts (SF:src\lib\pr-context\collector-output.ts)
- LF: 485, LH: 474 -> Lines: 97.73%
- BRF: 79, BRH: 65 -> Branches: 82.28%

## summary-helpers.ts (SF:src\lib\pr-context\summary-helpers.ts)
- LF: 388, LH: 363 -> Lines: 93.56%
- BRF: 74, BRH: 65 -> Branches: 87.84%

## Threshold Note
`extensions/drm-copilot/jest.config.cjs`'s `coverageThreshold` map (confirmed by direct
read: lines 33-40) gates `collector-output.ts` (lines 33-36) and `summary-helpers.ts`
(lines 37-40) today. It carries no entry for `collector-core.ts` at this point in the
plan, so `collector-core.ts`'s baseline percentages above are descriptive only and not
yet gated by a threshold.
