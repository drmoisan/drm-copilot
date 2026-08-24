# Coverage Delta — Remediation Cycle 2 Baseline Versus Final ([P4-T9])

Timestamp: 2026-08-20T17-17

Sources:

- Python baseline: `evidence/remediation-baseline/python-test.2026-08-20T16-36.md` ([P0-T2], EXIT_CODE 0)
- Python final: `evidence/qa-gates/python-test-final.2026-08-20T17-07.md` ([P4-T4], EXIT_CODE 0)
- TypeScript baseline: `evidence/remediation-baseline/typescript-test.2026-08-20T16-38.md` ([P0-T3], EXIT_CODE 0)
- TypeScript final: `evidence/qa-gates/typescript-test-final.2026-08-20T17-15.md` ([P4-T8], EXIT_CODE 0)

## Line Coverage

| File | Baseline line % | Final line % | Signed delta | Verdict |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/plan_gate_discrimination.py` | 98.214% | 98.276% | **+0.062** | PASS (non-negative) |
| `src/lib/validate/plan-gate-rules.ts` | 97.712% | 97.712% | **0.000** | PASS (non-negative) |
| `src/lib/validate/plan-gate-discrimination.ts` | 100.000% | 100.000% | **0.000** | PASS (non-negative) |

## Branch Coverage

| File | Baseline branch % | Final branch % | Signed delta | Verdict |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/plan_gate_discrimination.py` | 90.541% | 90.541% | **0.000** | PASS (non-negative) |
| `src/lib/validate/plan-gate-rules.ts` | 89.552% | 89.552% | **0.000** | PASS (non-negative) |
| `src/lib/validate/plan-gate-discrimination.ts` | 97.917% | 97.917% | **0.000** | PASS (non-negative) |

## Underlying Counts

| File | Baseline (covered/total) | Final (covered/total) |
| --- | --- | --- |
| `scripts/dev_tools/plan_gate_discrimination.py` lines | 165/168 | 171/174 |
| `scripts/dev_tools/plan_gate_discrimination.py` branches | 67/74 | 67/74 |
| `src/lib/validate/plan-gate-rules.ts` lines | 427/437 | 427/437 |
| `src/lib/validate/plan-gate-rules.ts` branches | 60/67 | 60/67 |
| `src/lib/validate/plan-gate-discrimination.ts` lines | 269/269 | 269/269 |
| `src/lib/validate/plan-gate-discrimination.ts` branches | 47/48 | 47/48 |

## Verdict

**PASS.** Every file shows a non-negative delta on both metrics, so the no-regression rule holds.
Every final value also clears the absolute thresholds (line >= 85%, branch >= 75%).

Notes:

- The Python module gained six statements (168 to 174) from the extracted helper and the guarded
  invocation, and all six are covered, which is why the line percentage rose slightly. Its three
  uncovered statements are the same three as at baseline, shifted by the inserted lines.
- The branch count for the Python module is unchanged at 74: the `try` / `except Exception` guard
  adds an exception path, not a conditional branch arc, so branch coverage is flat rather than
  diluted.
- Both TypeScript files are unchanged this cycle, and both reproduce their baseline figures exactly.
