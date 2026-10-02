# TypeScript Coverage Comparison (P8-T14)

Timestamp: 2026-09-30T15-10
Task: [P8-T14]
Scope: `extensions/drm-copilot/src/lib/validate/`
Inputs: baseline `evidence/baseline/ts-coverage.2026-09-30T13-51.md` (P0-T11); post-change `evidence/qa-gates/ts-coverage.2026-09-30T14-46.md` (P8-T4). No command ran in this task.

## Output Summary

Overall `text-summary` percentages:

| Metric | Baseline (P0-T11) | Post-change (P8-T4) | Difference |
| --- | --- | --- | --- |
| Statements | 97.03 | 97.05 | +0.02 |
| Branches | 91.19 | 91.26 | +0.07 |
| Functions | 90.88 | 90.93 | +0.05 |
| Lines | 97.03 | 97.05 | +0.02 |

`orchestrator-state-routing.ts` row:

| Metric | Baseline | Post-change | Difference |
| --- | --- | --- | --- |
| % Stmts | 95.82 | 95.93 | +0.11 |
| % Branch | 92.15 | 92.30 | +0.15 |
| % Funcs | 93.75 | 93.75 | 0.00 |
| % Lines | 95.82 | 95.93 | +0.11 |

The uncovered line ranges after the change are the baseline ranges shifted by one line (the added import), so no changed line is uncovered.

New-code figures (`orchestrator-state-issue-adoption.ts`, new file, no baseline): % Stmts 100, % Branch 100, % Funcs 100, % Lines 100.

Gate evaluation:
- Every post-change routing-row value is at least its baseline: yes (three increases, one equal).
- New row meets 85 lines and 75 branches: yes (100 and 100).

Result: PASS.
