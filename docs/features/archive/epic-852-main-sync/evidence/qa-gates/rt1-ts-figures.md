# RT-1 TypeScript Coverage Figures

Timestamp: 2026-10-11T01-30
Task: [P1-T2]
Command: Glob coverage/lcov.info; Grep coverage/lcov.info pattern `^SF:` (count mode)
EXIT_CODE: 0

## Output location

- `coverage/lcov.info`: present. [P0-T3] recorded it absent before the run, so this file is the [P1-T1] run's output.
- `^SF:` record count: 212 (greater than 0).

## Repo-wide figures (from the [P1-T1] text-summary)

| Metric | hit/total | Percent |
|---|---|---|
| Lines (LH/LF) | 51131/52575 | 97.25 |
| Branches (BRH/BRF) | 7532/8180 | 92.07 |

Note: istanbul-reports lcovonly writes each file's `LF`/`LH`/`BRF`/`BRH` from the same per-file summary that text-summary aggregates (`node_modules/istanbul-reports/lib/lcovonly/index.js` lines 53-54 and 67-68, verified by Grep: `writer.println('LF:' + summary.lines.total)`, `writer.println('LH:' + summary.lines.covered)`, `writer.println('BRF:' + summary.branches.total)`, `writer.println('BRH:' + summary.branches.covered)`).

Output Summary: coverage/lcov.info produced by this run with 212 SF records. Repo-wide line 97.25% (51131/52575) >= 85.00; branch 92.07% (7532/8180) >= 75.00.

## Per-changed-file figures

Task: [P1-T3]
Command: Grep coverage/lcov.info pattern `^(SF|LF|LH|BRF|BRH):` (content mode, no head limit); rows assembled per `SF:` record after normalizing `\` to `/` (exact equality, no prefix change). Arithmetic: `round(hit*100/found, 2)`.
EXIT_CODE: 0
TS_IDENTITY_EXIT (from [P0-T6]): 0

| # | Path | LH/LF | Line % | BRH/BRF | Branch % | Verdict |
|---|---|---|---|---|---|---|
| 1 | extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts | 295/301 | 98.01 | 39/46 | 84.78 | PASS |
| 2 | extensions/drm-copilot/src/lib/codex-native-converter/intermediate-state.ts | 154/154 | 100.00 | 15/16 | 93.75 | PASS |
| 3 | extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts | 308/314 | 98.09 | 50/57 | 87.72 | PASS |
| 4 | extensions/drm-copilot/src/lib/codex-native-converter/models.ts | 279/279 | 100.00 | 16/16 | 100.00 | PASS |
| 5 | extensions/drm-copilot/src/lib/codex-native-converter/pipeline-traces.ts | 122/122 | 100.00 | 20/20 | 100.00 | PASS |
| 6 | extensions/drm-copilot/src/lib/codex-native-converter/pipeline.ts | 154/154 | 100.00 | 29/29 | 100.00 | PASS |
| 7 | extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts | 199/199 | 100.00 | 39/44 | 88.64 | PASS |
| 8 | extensions/drm-copilot/src/lib/codex-native-converter/reporting.ts | 237/237 | 100.00 | 44/50 | 88.00 | PASS |
| 9 | extensions/drm-copilot/src/lib/codex-native-converter/validation.ts | 370/372 | 99.46 | 45/53 | 84.91 | PASS |
| 10 | extensions/drm-copilot/src/lib/pr-context/autoclose.ts | 294/294 | 100.00 | 43/43 | 100.00 | PASS |
| 11 | extensions/drm-copilot/src/lib/pr-context/collector-core.ts | 376/382 | 98.43 | 48/52 | 92.31 | PASS |
| 12 | extensions/drm-copilot/src/lib/pr-context/collector-output.ts | 481/491 | 97.96 | 67/74 | 90.54 | PASS |
| 13 | extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts | 302/308 | 98.05 | 52/57 | 91.23 | PASS |
| 14 | extensions/drm-copilot/src/lib/pr-context/feature-docs.ts | 291/308 | 94.48 | 48/55 | 87.27 | PASS |
| 15 | extensions/drm-copilot/src/lib/pr-context/models.ts | 366/366 | 100.00 | 38/38 | 100.00 | PASS |
| 16 | extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts | 421/430 | 97.91 | 78/87 | 89.66 | PASS |
| 17 | extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts | 337/387 | 87.08 | 66/70 | 94.29 | PASS |
| 18 | extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts | 259/261 | 99.23 | 31/33 | 93.94 | PASS |
| 19 | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts | 392/392 | 100.00 | 39/40 | 97.50 | PASS |
| 20 | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts | 192/192 | 100.00 | 21/21 | 100.00 | PASS |
| 21 | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts | 303/305 | 99.34 | 36/37 | 97.30 | PASS |
| 22 | extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts | 445/447 | 99.55 | 93/97 | 95.88 | PASS |
| 23 | extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts | 322/332 | 96.99 | 60/67 | 89.55 | PASS |
| 24 | extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts | 439/448 | 97.99 | 39/45 | 86.67 | PASS |
| 25 | extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts | 199/203 | 98.03 | 20/22 | 90.91 | PASS |
| 26 | extensions/drm-copilot/src/lib/string-ordering.ts | 66/66 | 100.00 | 20/20 | 100.00 | PASS |
| 27 | extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts | 135/135 | 100.00 | 17/17 | 100.00 | PASS |
| 28 | extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts | 183/184 | 99.46 | 18/20 | 90.00 | PASS |
| 29 | extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | 466/474 | 98.31 | 106/113 | 93.81 | PASS |
| 30 | extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts | 386/390 | 98.97 | 65/71 | 91.55 | PASS |
| 31 | extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts | 138/138 | 100.00 | 39/39 | 100.00 | PASS |
| 32 | extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts | 155/155 | 100.00 | 31/31 | 100.00 | PASS |
| 33 | extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts | 489/494 | 98.99 | 86/88 | 97.73 | PASS |
| 34 | extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts | 324/324 | 100.00 | 63/63 | 100.00 | PASS |

Rows: 34 of 34 TS set members; every member has an `SF:` record; 0 FAIL rows, 0 NO-REGRESSION rows. Lowest line: render-pr-helpers.ts 87.08. Lowest branch: engine-pipeline.ts 84.78.

Cross-check: the counters for engine-pipeline.ts (LF 301, LH 295, BRF 46, BRH 39), render-pr-helpers.ts (LF 387, LH 337, BRF 70, BRH 66), and string-ordering.ts (LF 66, LH 66, BRF 20, BRH 20) were re-read from the Grep output and match the rows above.

Note on [P1-T1] EXIT_CODE 1: no test failed (3981 passed). The non-zero exit comes from the extension config's per-file `coverageThreshold` keys (`./src/...`), which Jest resolves against the process working directory (`node_modules/@jest/reporters/build/index.js` line 424). From the workspace root they do not resolve to measured files. The lcov figures above show every one of those threshold files in the changed set is at or above 85/75 when measured. The Verdict Rules make RT-1 FAIL only on a failing test, a repo-wide shortfall, or a FAIL row, and none occurred.

Output Summary: 34/34 rows PASS; repo-wide line 97.25%, branch 92.07%; 0 failed tests.

RT-1 VERDICT: PASS
