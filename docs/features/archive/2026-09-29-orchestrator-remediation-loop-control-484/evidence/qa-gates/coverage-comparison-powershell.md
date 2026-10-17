# PowerShell Coverage Comparison (P11-T4)

Timestamp: 2026-10-01T23-08
Task: P11-T4
Inputs: `evidence/baseline/pester-receipts-coverage-baseline.md` (P0-T30), `evidence/qa-gates/pester-receipts-coverage-final.md` (P10-T7), `evidence/qa-gates/pester-accounting-coverage-final.md` (P10-T6), `artifacts/pester/coverage-484-receipts-final.xml`.

Command: git diff -U0 40faab4136d72512e20b50b5193a14dd4e78eaf2 -- .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1
EXIT_CODE: 0

## Line percentages

| Module | Baseline | Post-change | Threshold | Result |
|---|---|---|---|---|
| `OrchestratorStateReceipts.psm1` | 113/113 = 100.00% (P0-T30) | 117/117 = 100.00% (P10-T7) | >= 85, not below baseline | PASS |
| `OrchestratorStateRemediationAccounting.psm1` (new) | n/a | 100/100 = 100.00% (P10-T6) | >= 85 | PASS |

## Changed `line` elements

Added ranges from the hunk headers: 40 (`+40`), 294 (`+294`), 297-302 (`+297,6`), 320-332 (`+320,13`), 337 (`+337`) — 22 added lines.

`line` elements of `OrchestratorStateReceipts.psm1` whose `nr` falls in those ranges (`nr`, `mi`, `ci`):

```
(40, 0, 2), (320, 0, 1), (321, 0, 1), (322, 0, 1), (325, 0, 1), (326, 0, 2), (327, 0, 2), (328, 0, 1), (329, 0, 1), (332, 0, 2), (337, 0, 2)
```

## Output Summary:

- Changed `line` elements: 11; with `ci` above 0: 11. Ratio 11/11 = 1.0000 (100.00%), at least 0.85.
- Receipts post-change 100.00%, not below the 100.00% baseline; new module 100.00%.
- Result: PASS.
