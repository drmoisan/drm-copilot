# TypeScript Coverage Delta (P9-T2, Issue #849)

Timestamp: 2026-10-10T15-10
Command: git diff -U0 --merge-base origin/main -- extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts ; Grep of the `orchestrator-state-issue-adoption.ts` row in `evidence/baseline/ts-coverage-output.2026-10-09T01-33.txt` (P0-T15) and `evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt` (P7-T5)
EXIT_CODE: 0

## Rows (verbatim, trailing padding trimmed)

Baseline (P0-T15, line 205):

`  orchestrator-state-issue-adoption.ts                      |     100 |      100 |     100 |     100 |`

Post-change (P7-T5, line 205):

`  orchestrator-state-issue-adoption.ts                      |     100 |      100 |     100 |     100 |`

| Measure | Baseline | Post-change | Threshold | Result |
|---|---|---|---|---|
| % Lines | 100 (RB_TS_LINE) | 100 | >= 85 | met, not below baseline |
| % Branch | 100 (RB_TS_BRANCH) | 100 | >= 75 | met, not below baseline |

## Changed-line check

Hunk headers from the `-U0` diff (added ranges on the `+` side):

- `@@ -63,0 +64,5 @@` -> 64-68
- `@@ -225,0 +231,7 @@` -> 231-237
- `@@ -228,0 +241,2 @@` -> 241-242
- `@@ -229,0 +244,8 @@` -> 244-251
- `@@ -289 +311,8 @@` -> 311-318

Added line numbers (30): 64-68, 231-237, 241-242, 244-251, 311-318.

P7-T5 Uncovered Line #s for the row: empty. No added line number appears in the Uncovered Line #s column.

Output Summary: PASS. orchestrator-state-issue-adoption.ts % Lines 100 -> 100, % Branch 100 -> 100 (thresholds 85 / 75 met, no regression); Uncovered Line #s empty, so none of the 30 added lines is uncovered (AC-17 coverage leg).
