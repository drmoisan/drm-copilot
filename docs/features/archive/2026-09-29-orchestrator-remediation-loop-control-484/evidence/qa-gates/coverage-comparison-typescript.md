# TypeScript Coverage Comparison (P11-T3)

Timestamp: 2026-10-01T23-08
Task: P11-T3
Inputs: `evidence/baseline/jest-coverage-remediation-derived-baseline.md` (P0-T27), `evidence/qa-gates/jest-coverage-derived-final.md` (P9-T6), `extensions/drm-copilot/coverage/lcov.info` written by P9-T5.
Adjustment (deviation D11, following D4): the task names `orchestrator-state-remediation.ts` only; because the P4-T4 split applied, `orchestrator-state-remediation-accounting.ts` is compared as well.

Command: git diff -U0 40faab4136d72512e20b50b5193a14dd4e78eaf2 -- extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation-accounting.ts
EXIT_CODE: 0

## Whole-file ratios

| File | Baseline LH/LF | Post LH/LF | Baseline BRH/BRF | Post BRH/BRF | Result |
|---|---|---|---|---|---|
| `orchestrator-state-remediation.ts` | 136/136 = 100.00% | 283/283 = 100.00% | 18/18 = 100.00% | 56/56 = 100.00% | PASS |
| `orchestrator-state-remediation-accounting.ts` (new) | n/a (file absent at baseline) | 217/221 = 98.19% | n/a | 43/45 = 95.56% | PASS |

## Changed-line `DA:` records

`orchestrator-state-remediation.ts` added ranges (from the hunk headers): 5-7, 9-10, 16-22, 29-43, 60-71, 82-102, 157-241, 246-249, 252, 264-277, 280-281 (166 lines).

- `DA:` records in added ranges: 166; with count above 0: 166.
- Ratio: 166/166 = 1.0000 (100.00%).

`orchestrator-state-remediation-accounting.ts` added range: 1-221 (`@@ -0,0 +1,221 @@`, new file).

- `DA:` records in added ranges: 221; with count above 0: 217.
- Ratio: 217/221 = 0.9819 (98.19%).
- Records with count 0: lines 89, 90, 92, 93 (the `return "True";` and `return "False";` statements and their closing braces in the file-local `str()`-semantics display helper; the zero counts show that no Jest case passed a Boolean through this helper).

## Output Summary:

- Post-change ratios meet 85 (lines) and 75 (branches) for both files; the `orchestrator-state-remediation.ts` line ratio is not below its baseline (100.00% -> 100.00%).
- Changed-line `DA:` ratios: 1.0000 and 0.9819, both at least 0.85.
- Result: PASS.
