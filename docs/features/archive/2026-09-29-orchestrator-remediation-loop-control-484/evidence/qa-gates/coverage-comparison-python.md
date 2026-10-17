# Python Coverage Comparison (P11-T1, P11-T2)

Timestamp: 2026-10-01T23-08
Tasks: P11-T1, P11-T2
Module: `scripts/dev_tools/_orchestrator_state_remediation_loop.py` (no split module; P3-T6 `Split: not applied`)

## P11-T1 — Baseline versus post-change

Command: none (values read from `evidence/baseline/python-coverage-derived-baseline.md` (P0-T17) and `evidence/qa-gates/python-coverage-derived-final.md` (P8-T7))
EXIT_CODE: 0

| Metric | Baseline (P0-T17) | Post-change (P8-T7) | Threshold | Result |
|---|---|---|---|---|
| Line | 35/36 = 97.22% | 138/138 = 100.00% | >= 85, not below baseline | PASS |
| Branch | 14/16 = 87.50% | 73/74 = 98.65% | >= 75 | PASS |

## P11-T2 — Changed-line coverage

Command: git diff -U0 40faab4136d72512e20b50b5193a14dd4e78eaf2 -- scripts/dev_tools/_orchestrator_state_remediation_loop.py
EXIT_CODE: 0

Hunk headers (added side):

```
@@ -14,2 +14,5 @@   -> lines 14-18
@@ -23 +26,4 @@     -> lines 26-29
@@ -31,0 +38,10 @@  -> lines 38-47
@@ -42,0 +59,68 @@  -> lines 59-126
@@ -78,0 +163,133 @@ -> lines 163-295
@@ -79,0 +297,6 @@  -> lines 297-302
@@ -89,11 +312,14 @@ -> lines 312-325
@@ -100,0 +327,2 @@ -> lines 327-328
```

Intersection: the 242 added lines intersected with the executable lines (`executed_lines` plus `missing_lines` of the module record in `artifacts/python/coverage-484-final.json`), computed by a scratch script outside the repository.

## Output Summary:

- Added lines: 242. Executable added lines: 111. Covered executable added lines: 111.
- Changed-line coverage: 111/111 = 1.0000 (100.00%), at least 0.85.
- Uncovered added lines: none.
- Line coverage did not regress (97.22% -> 100.00%). Result: PASS.
