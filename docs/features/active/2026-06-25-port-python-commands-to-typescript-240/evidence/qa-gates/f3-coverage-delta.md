# F3 Coverage Delta / Threshold Verification

Timestamp: 2026-06-26T01-37

Baseline source: evidence/baseline/f3-baseline-ts-test-coverage.md
Final source: evidence/qa-gates/f3-final-ts-test-coverage.md

## Overall `src/lib/**` coverage

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Line   | 96.33% | 96.97% | +0.64 |
| Branch | 87.87% | 87.93% | +0.06 |

No regression: both overall line% and branch% are at or above the baseline.

## New-code (each `src/lib/push-down/*.ts`) coverage

| File | Line% | Branch% | Meets line>=85 / branch>=75 |
|---|---|---|---|
| claude-customizations.ts           | 100   | 83.33 | yes / yes |
| claude-filesystem-adapter.ts       | 94.38 | 83.33 | yes / yes |
| claude-memory-scope.ts             | 100   | 86.36 | yes / yes |
| claude-pack-selection.ts           | 100   | 98    | yes / yes |
| codex-agents-customizations.ts     | 100   | 100   | yes / yes |
| copilot-customizations-engine.ts   | 97.99 | 82    | yes / yes |
| copilot-customizations.ts          | 100   | 100   | yes / yes |
| filesystem-adapter.ts              | 98.03 | 86.95 | yes / yes |
| push-down-service-call.ts          | 100   | 86.66 | yes / yes |
| reference-rewrites.ts              | 99.17 | 93.75 | yes / yes |

Outcome: PASS. No overall coverage regression versus the baseline, and every
new push-down file meets line >= 85% and branch >= 75%.
