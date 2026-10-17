# Baseline: Full test suite with coverage (P0-T15)

Timestamp: 2026-10-09T21-15
Command: cd extensions/drm-copilot && npm run test:coverage; then LCOV (extensions/drm-copilot/coverage/lcov.info) read per file with a scratchpad parser (LH/LF, BRH/BRF, DA hit 0, BRDA taken 0 or -)
EXIT_CODE: 0
Output Summary:
- Test Suites: 257 passed, 257 total  (BASE_SUITES = 257)
- Tests:       3927 passed, 3927 total  (BASE_TOTAL = 3927)
- Statements   : 97.16% ( 51037/52524 )
- Branches     : 91.73% ( 7523/8201 )
- Functions    : 91.59% ( 1525/1665 )
- Lines        : 97.16% ( 51037/52524 )
- Lines containing "coverage threshold": 0
- BASELINE-SHORTFALL: none (every CHANGED-PROD file is >= 85% lines and >= 75% branches).

Per-file baseline for the 26 CHANGED-PROD files (line pct (LH/LF), uncovered LF-LH; branch pct (BRH/BRF), uncovered BRF-BRH):

| File (under extensions/drm-copilot/) | Lines | LF-LH | Branches | BRF-BRH |
| --- | --- | --- | --- | --- |
| src/lib/pr-context/models.ts | 100.00 (391/391) | 0 | 100.00 (49/49) | 0 |
| src/lib/pr-context/verification-evidence.ts | 99.23 (258/260) | 2 | 93.94 (31/33) | 2 |
| src/lib/pr-context/feature-docs.ts | 94.55 (295/312) | 17 | 87.27 (48/55) | 7 |
| src/lib/pr-context/feature-docs-parsers.ts | 98.08 (306/312) | 6 | 91.23 (52/57) | 5 |
| src/lib/pr-context/render-pr-helpers.ts | 87.08 (337/387) | 50 | 94.29 (66/70) | 4 |
| src/lib/pr-context/render-feature-excerpts.ts | 97.91 (421/430) | 9 | 89.66 (78/87) | 9 |
| src/lib/pr-context/collector-core.ts | 98.43 (376/382) | 6 | 92.31 (48/52) | 4 |
| src/lib/pr-context/autoclose.ts | 100.00 (294/294) | 0 | 100.00 (43/43) | 0 |
| src/lib/pr-context/collector-output.ts | 97.77 (483/494) | 11 | 89.33 (67/75) | 8 |
| src/lib/codex-native-converter/engine-pipeline.ts | 97.73 (302/309) | 7 | 84.00 (42/50) | 8 |
| src/lib/codex-native-converter/reporting-render.ts | 96.65 (202/209) | 7 | 83.78 (31/37) | 6 |
| src/lib/codex-native-converter/reporting.ts | 99.16 (237/239) | 2 | 81.03 (47/58) | 11 |
| src/lib/codex-native-converter/validation.ts | 99.46 (370/372) | 2 | 86.21 (50/58) | 8 |
| src/lib/codex-native-converter/intermediate-state.ts | 100.00 (153/153) | 0 | 90.00 (18/20) | 2 |
| src/lib/codex-native-converter/inventory.ts | 98.12 (313/319) | 6 | 83.82 (57/68) | 11 |
| src/lib/codex-native-converter/models.ts | 100.00 (280/280) | 0 | 95.00 (19/20) | 1 |
| src/lib/codex-native-converter/pipeline.ts | 100.00 (155/155) | 0 | 92.68 (38/41) | 3 |
| src/lib/codex-native-converter/pipeline-traces.ts | 93.44 (114/122) | 8 | 83.33 (15/18) | 3 |
| src/lib/push-down/claude-blast-radius-derive-manifests.ts | 100.00 (200/200) | 0 | 95.65 (22/23) | 1 |
| src/lib/push-down/claude-blast-radius-derive-core.ts | 100.00 (394/394) | 0 | 97.50 (39/40) | 1 |
| src/lib/push-down/claude-blast-radius-overlay.ts | 99.55 (445/447) | 2 | 95.88 (93/97) | 4 |
| src/lib/push-down/claude-blast-radius-derive.ts | 97.39 (298/306) | 8 | 94.12 (32/34) | 2 |
| src/lib/push-down/filesystem-adapter.ts | 98.04 (200/204) | 4 | 88.46 (23/26) | 3 |
| src/lib/push-down/copilot-customizations-engine.ts | 97.99 (439/448) | 9 | 84.31 (43/51) | 8 |
| src/lib/subagent-tree/tree-assembler.ts | 94.71 (179/189) | 10 | 89.47 (17/19) | 2 |
| src/lib/subagent-tree/quick-pick-labels.ts | 100.00 (133/133) | 0 | 94.44 (17/18) | 1 |

Baseline uncovered line numbers at comparator sites (informational for P4-T6): tree-assembler.ts 97-105 (compareByAgentId body), pipeline-traces.ts 112-113 and 117-120 (G2 branches), claude-blast-radius-derive.ts 123-128 (realDirectoryLister, I13).
