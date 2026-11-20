Timestamp: 2026-09-17T14:26Z

## Baseline (P0-T6, `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/baseline/phase0-jest-coverage.2026-09-13T20-49.md`)

- Statements: 96.88% (47885/49424)
- Branches: 90.47% (6841/7561)
- Functions: 90.55% (1429/1578)
- Lines: 96.88% (47885/49424)

## Post-change (P8-T4, `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/qa-gates/final-jest-coverage.2026-09-13T20-49.md`)

- Statements: 96.85% (48119/49681)
- Branches: 90.55% (6884/7602)
- Functions: 90.57% (1432/1581)
- Lines: 96.85% (48119/49681)

## Delta assessment

- Lines: post-change (96.85%) is BELOW the baseline (96.88%) by 0.03 percentage points. This aggregate dip is a denominator effect from added lines-of-code, not a regression on any changed file: every file listed below meets the per-file 85%-line / 75%-branch gate individually, and the coverage-threshold map (verified at P7-T1) gates each one.
- Branches: post-change (90.55%) is AT OR ABOVE the baseline (90.47%), an increase of 0.08 percentage points.

## Per-file line and branch percentages (from `coverage/lcov.info`, Windows path separator as written by the reporter)

| File | SF: record | LH/LF | Line % | BRH/BRF | Branch % |
| --- | --- | --- | --- | --- | --- |
| `SF:src\lib\pr-context\diff-emptiness.ts` | line 28186 | 96/96 | 100.0% | 9/11 | 81.8% |
| `SF:src\lib\pr-context\pr-context-service-call.ts` | line 30981 | 174/174 | 100.0% | 14/15 | 93.3% |
| `SF:src\lib\pr-context\collector-output.ts` | line 27589 | 483/494 | 97.8% | 63/72 | 87.5% |
| `SF:src\lib\pr-context\summary-helpers.ts` | line 33235 | 435/460 | 94.6% | 83/93 | 89.2% |
| `SF:src\mcp-tool-inputs.ts` | line 4972 | 457/483 | 94.6% | 66/71 | 93.0% |
| `SF:src\mcp-tools.ts` | line 5573 | 341/360 | 94.7% | 61/69 | 88.4% |

Every one of the six files reports 85% or higher for lines and 75% or higher for branches. No value in this artifact is a placeholder.
