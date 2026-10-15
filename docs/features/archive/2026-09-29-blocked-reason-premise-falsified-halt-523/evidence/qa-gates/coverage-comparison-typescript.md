# TypeScript Coverage Comparison (P11-T3)

Timestamp: 2026-09-30T15-55
Command: comparison of `evidence/baseline/jest-coverage-core-derived-baseline.md` (P0-T19) against `evidence/qa-gates/jest-coverage-derived-final.md` (P9-T6, loop iteration 2); git diff -U0 origin/epic/orchestrator-state-contract-correctness-integration -- extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts; then poetry run python -c "t=open('extensions/drm-copilot/coverage/lcov.info', encoding='utf-8').read(); b=[r for r in t.split('end_of_record') if any(l.startswith('SF:') and l.replace(chr(92), '/').endswith('/validate/orchestrator-state-core.ts') for l in r.splitlines())]; print(len(b)); print([l for l in b[0].splitlines() if l.startswith('DA:') and int(l[3:].split(',')[0]) in (2, 32)])"
EXIT_CODE: 0
Output Summary: `orchestrator-state-core.ts` line 98.93% -> 98.91%, branch 96.15% -> 96.25% (both above 85/75). `orchestrator-state-blocked-reason.ts` line 100.00%, branch 100.00%. Added lines {2, 32} both have hit count 1; no `DA:<line>,0` record falls in an added range.

## Ratios

| File | Metric | Baseline (P0-T19) | Post-change (P9-T6) | Threshold | Result |
|---|---|---|---|---|---|
| `orchestrator-state-core.ts` | Line (LH/LF) | 462/467 = 98.93% | 453/458 = 98.91% | >= 85 | PASS |
| `orchestrator-state-core.ts` | Branch (BRH/BRF) | 75/78 = 96.15% | 77/80 = 96.25% | >= 75 | PASS |
| `orchestrator-state-blocked-reason.ts` (new) | Line (LH/LF) | n/a | 74/74 = 100.00% | >= 85 | PASS |
| `orchestrator-state-blocked-reason.ts` (new) | Branch (BRH/BRF) | n/a | 10/10 = 100.00% | >= 75 | PASS |

The core line ratio moved from 98.93% to 98.91% because 9 covered set-literal lines moved out of the file (LF 467 -> 458, LH 462 -> 453); the uncovered count is unchanged at 5 lines. Changed-line coverage is checked below.

## Changed lines

Hunk headers from the anchored `git diff -U0`:

- `@@ -1,0 +2 @@` -> added line 2 (count omitted: single line): `import { VALID_BLOCKED_REASONS } from "./orchestrator-state-blocked-reason";`
- `@@ -30,0 +32 @@` -> added line 32 (count omitted: single line): `export { VALID_BLOCKED_REASONS };`
- `@@ -95,11 +96,0 @@` -> no added lines (removal of the former set literal).

`DA:` records from the lcov record whose `SF:` ends with `/validate/orchestrator-state-core.ts` (one record selected; not the `epic-` or `parallel-` record), restricted to the added lines:

```
1
['DA:2,1', 'DA:32,1']
```

No `DA:<line>,0` record falls in an added range.
