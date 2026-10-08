# Coverage Delta and Changed-Line Coverage (P2-T9, AC-13)

Timestamp: 2026-10-08T02-38
Command: git diff -U0 6dac65b0930b299dc7b3c3925a607735a05fca35 -- extensions/drm-copilot/src/lib/pr-context (added-line numbers from each `@@ ... +start,count @@` header), then LCOV `DA:` records from extensions/drm-copilot/coverage/lcov.info (P2-T8 run)
EXIT_CODE: 0
Output Summary: PASS. Every post-change value is >= 85 lines and >= 75 branches. Aggregate changed-line coverage across PROD-FILES is 76/76 = 100.00%. One lines.pct drop exceeds 0.5 pp (render-pr-helpers.ts, -0.63 pp) and has a recorded cause below.

| File | Baseline lines (P0-T15) | Baseline branches | Post lines (P2-T8) | Post branches | Changed-line coverage |
| --- | --- | --- | --- | --- | --- |
| models.ts | 100 (348/348) | 100 (44/44) | 100 (391/391) | 100 (49/49) | 53/53 |
| collector-core.ts | 98.44 (380/386) | 92.45 (49/53) | 98.42 (376/382) | 92.3 (48/52) | 1/1 |
| render.ts | 99 (396/400) | 90.41 (66/73) | 99.73 (374/375) | 92.3 (60/65) | 2/2 |
| gh-client-details.ts | 96.12 (372/387) | 91.46 (75/82) | 96.04 (364/379) | 91.35 (74/81) | 6/6 |
| render-pr-helpers.ts | 87.71 (357/407) | 94.73 (72/76) | 87.08 (337/387) | 94.28 (66/70) | 1/1 |
| verification-evidence.ts | 96.94 (286/295) | 84.61 (33/39) | 99.23 (258/260) | 93.93 (31/33) | 2/2 |
| render-feature-excerpts.ts | 97.51 (431/442) | 88.88 (80/90) | 97.9 (421/430) | 89.65 (78/87) | 2/2 |
| feature-docs-parsers.ts | 97.46 (308/316) | 89.47 (51/57) | 98.07 (306/312) | 91.22 (52/57) | 9/9 |

Changed-line coverage counts added lines that carry a `DA:` record; every added line in every file carried one.

## Recorded cause for lines.pct drops

- render-pr-helpers.ts (-0.63 pp): the uncovered line count is 50 before and after. The file lost its private `splitLines` (20 covered lines) and gained one covered import line, so covered fell from 357 to 337 and total from 407 to 387 with no new uncovered line. The drop is a denominator effect, not lost coverage.
- collector-core.ts (-0.02 pp) and gh-client-details.ts (-0.08 pp): below the 0.5 pp tolerance; same mechanism (removed private `sortedSet` lines were covered; uncovered counts 6 and 15 unchanged).

## Hunk headers used

```
collector-core.ts: @@ -22,0 +23 @@ ; @@ -382,5 +382,0 @@
feature-docs-parsers.ts: @@ -20,0 +21 @@ ; @@ -293 +294,5 @@ ; @@ -296,2 +301,3 @@ ; @@ -307,10 +312,0 @@
gh-client-details.ts: @@ -18,2 +18,6 @@ ; @@ -115,12 +118,0 @@
models.ts: @@ -18,0 +19,3 @@ ; @@ -212 +215 @@ ; @@ -214,3 +217,5 @@ ; @@ -339 +344,11 @@ ; @@ -341,2 +356,7 @@ ; @@ -344,2 +364,2 @@ ; @@ -347 +367,24 @@
render-feature-excerpts.ts: @@ -18,0 +19 @@ ; @@ -20,0 +22 @@ ; @@ -429,14 +430,0 @@
render-pr-helpers.ts: @@ -26,0 +27 @@ ; @@ -387,21 +387,0 @@
render.ts: @@ -19 +18,0 @@ ; @@ -23,0 +23,2 @@ ; @@ -375,26 +375,0 @@
verification-evidence.ts: @@ -22 +22,2 @@ ; @@ -260,36 +260,0 @@
```

The diff output was written to a session scratch file and parsed, together with lcov.info, by a session-scratch Node script; neither file is committed.

Loop note: this command ran on loop pass 2 and again on loop pass 3, the final clean pass of P2-T1 through P2-T15 with no file changed (after the DEV-8 compaction of models.test.ts). Both passes gave identical results; the values above are from loop pass 3.
