# Remediation Coverage Comparison (issue #671, R1)

Timestamp: 2026-09-17T10-09
Task: [P6-T4]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/p6-parse.ps1` — reads `artifacts/pester/powershell-coverage.xml` written by the [P6-T3] run (LastWriteTimeUtc 2026-09-17T14:08:04.6398181Z). It selects the D4 `.claude/hooks` helpers `sourcefile` and the `line` children whose `nr` is in the [P5-T2] `Changed-line set:`.
EXIT_CODE: 0

Hash check before computing: the current `.claude/hooks` helpers hash `AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989` equals the [P5-T2] `Helpers hash at capture:` value, so [P5-T2] was not re-run.

Output Summary:

| Measure | Baseline ([P0-T7], `evidence/remediation-baseline/poshqc-test-coverage.2026-09-17T08-50.md`) | Post-change ([P6-T3], `evidence/qa-gates/remediation-poshqc-test-coverage.2026-09-17T10-30.md`) |
| --- | --- | --- |
| Report-level LINE covered / missed | 8970 / 432 | 8986 / 418 |
| Report-level LINE percentage | 95.4052% | 95.5551% |
| `.claude/hooks` helpers covered / missed | 140 / 11 | 147 / 5 |
| `.claude/hooks` helpers percentage | 92.7152% | 96.7105% |

Reference: the pre-change (merge-base) per-file baseline named by spec criterion 19 is 112 / 118 = 94.92%. The post-change ratio 147 / 152 = 96.71% is above it (147 × 118 = 17346 >= 112 × 152 = 17024).

Changed-line coverage (`.claude/hooks` copy):
- Changed-line set size ([P5-T2]): 100 post-image lines.
- Of those, lines present as instrumented `line` children: 38.
- Of those, lines with `ci` > 0: 38.
- Changed-line ratio: 38 / 38 = 100%.
- Instrumented changed lines as `nr:ci`: 43:1, 245:1, 246:1, 247:1, 248:1, 250:4, 251:1, 252:1, 254:1, 255:1, 256:1, 258:1, 259:1, 260:1, 261:1, 264:1, 265:1, 266:2, 267:1, 268:1, 270:1, 271:1, 272:1, 273:1, 275:3, 276:1, 277:1, 278:1, 280:1, 311:1, 312:2, 313:1, 317:4, 431:1, 432:2, 433:2, 434:1, 438:1.
- Changed lines with `ci` 0: none.

The other 62 changed lines are comments, blank lines, help text, or structural lines (`param`, braces, `try`, `} catch {`) that Pester does not instrument.

Acceptance: the restated pairs match their source artifacts; post-change report-level percentage 95.5551% >= 85; post-change per-file ratio 147/152 >= 112/118; changed-line ratio 100%. PASS.
