# TypeScript Coverage Delta (P7-T13)

Timestamp: 2026-10-02T05-19
Command: git diff -U0 74e1d674 -- extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts
EXIT_CODE: 0
Output Summary:
src/lib/validate/parallel-planner-state-core.ts
Baseline (P0-T23, evidence/baseline/ts-jest-coverage.2026-10-02T04-29.md): lines.pct 100 (453/453); branches.pct 97.95 (48/49; uncovered branch at line 435)
Final (P7-T9, evidence/qa-gates/ts-jest-coverage.2026-10-02T05-19.md): lines.pct 100 (464/464); branches.pct 97.95 (48/49; uncovered branch at line 446)
Delta: lines +0.00 points, branches +0.00 points; final is not below baseline. The uncovered branch at 446 is the baseline branch at 435 shifted by the 11 lines added above it (hunk @@ -420 +431 @@); it is not a changed line.
Routing module (P7-T9): src/lib/validate/parallel-planner-state-routing.ts lines.pct 100 (225/225); branches.pct 92.59 (25/27)
Changed hunks (new-side line numbers): 9-14 header comment, 55 import of validateReadyItemRouting, 140 doc comment, 259-261 comment, 377 and 380-382 and 385-387 doc comment, 402-405 ready-gate loop body, 431 doc comment.
Changed executable lines: 55 (import), 402 (entryContext assignment), 404 (validateReadyItem push), 405 (validateReadyItemRouting push); line 403 is a comment.
lcov record for the core file in extensions/drm-copilot/coverage/lcov.info (SF:src\lib\validate\parallel-planner-state-core.ts): LF 464, LH 464, BRF 49, BRH 48; DA records with zero hits: none; zero-hit branch record: BRDA:446,43,0,0.
Changed executable lines with a DA:<line>,0 record: 0.
PLAN DEVIATION DEV-1 - the plan's diff anchor b7b4a2dc is executed as the merge-base 74e1d674.
