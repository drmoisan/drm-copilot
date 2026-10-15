# Python Coverage Comparison (P11-T1, P11-T2)

Timestamp: 2026-09-30T15-54
Command: comparison of `evidence/baseline/python-coverage-derived-baseline.md` (P0-T11) against `evidence/qa-gates/python-coverage-derived-final.md` (P8-T6, loop iteration 2); then git diff -U0 origin/epic/orchestrator-state-contract-correctness-integration -- scripts/dev_tools/validate_orchestrator_state.py
EXIT_CODE: 0
Output Summary: `validate_orchestrator_state.py` line 98.82% -> 98.82% and branch 97.56% -> 97.56% (not below baseline). New module `_orchestrator_state_blocked_reason.py` line 100.00%, branch 100.00% (>= 85 / >= 75). Changed-line intersection with `missing_lines` is empty.

## P11-T1 — Baseline versus post-change

| Module | Metric | Baseline (P0-T11) | Post-change (P8-T6) | Threshold | Result |
|---|---|---|---|---|---|
| `scripts/dev_tools/validate_orchestrator_state.py` | Line | 168/170 = 98.82% | 168/170 = 98.82% | not below baseline; >= 85 | PASS |
| `scripts/dev_tools/validate_orchestrator_state.py` | Branch | 80/82 = 97.56% | 80/82 = 97.56% | not below baseline; >= 75 | PASS |
| `scripts/dev_tools/_orchestrator_state_blocked_reason.py` (new) | Line | n/a (new module) | 15/15 = 100.00% | >= 85 | PASS |
| `scripts/dev_tools/_orchestrator_state_blocked_reason.py` (new) | Branch | n/a (new module) | 8/8 = 100.00% | >= 75 | PASS |

## P11-T2 — Changed-line coverage for `validate_orchestrator_state.py`

Command: git diff -U0 origin/epic/orchestrator-state-contract-correctness-integration -- scripts/dev_tools/validate_orchestrator_state.py (EXIT_CODE: 0)

Hunk headers and added-line ranges:

- `@@ -9,0 +10 @@` -> added line 10 (count omitted: single line). Content: the `from scripts.dev_tools._orchestrator_state_blocked_reason import VALID_BLOCKED_REASONS` import.
- `@@ -87,9 +87,0 @@` -> no added lines (removal of the former set literal).
- `@@ -348 +340,4 @@` -> added lines 340 through 343. Content: the `not isinstance(blocked_reason, str)` membership guard.

Added-line set: {10, 340, 341, 342, 343}
P8-T6 `missing_lines`: [116, 130]
Intersection: {} (empty). Every executable changed line is covered. The whole new module is governed by its P8-T6 percentages (100.00% line, 100.00% branch).
