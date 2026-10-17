# Coverage Baseline (P0-T8)

Timestamp: 2026-10-12T15-03
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage --coverageReporters=text --coverageReporters=text-summary
EXIT_CODE: 0
Output Summary:
- `Test Suites: 267 passed, 267 total`
- `Tests:       3981 passed, 3981 total`
- Coverage summary: `Statements   : 97.25% ( 51131/52575 )`, `Branches     : 92.07% ( 7532/8180 )`, `Functions    : 91.63% ( 1523/1662 )`, `Lines        : 97.25% ( 51131/52575 )`
- Lines: 97.25%; Branches: 92.07%

Note: the full-suite output exceeded the tool output limit, so it was redirected to a scratch file outside the repository (session scratchpad `889/issue-889-p0t8-coverage.txt`, not committed) and the rows below were extracted from it.

Per-file rows (paths relative to extensions/drm-copilot/src/lib/):

| File | % Lines | % Branch | Uncovered Line #s |
|---|---|---|---|
| push-down/claude-pack-selection.ts | 100 | 98 | 89 |
| push-down/codex-pack-selection.ts | 98.33 | 97.14 | 197-200 |
| subagent-tree/tree-assembler.ts | 99.45 | 90 | 119 |
| subagent-tree/tree-formatter.ts | 100 | 100 | (none) |
| resolve/file-prompt-transforms.ts | 100 | 86.66 | 41,103,159,192 |
| validate/codex-topology-resolver.ts | 97.38 | 94.73 | 89-90,94-98 |
| validate/epic-orchestrator-state-core.ts | 97.96 | 91.2 | 181-182,190-191,290-291,359-360,364-365 |
| validate/epic-planner-git-integrity.ts | 100 | 93.9 | 53,60,67,206,222 |
| validate/orchestrator-state-codex-model-routing.ts | 95.67 | 93.96 | 162-163,323-327,337-340,350-354,358,360-363 |
| validate/orchestrator-state-codex-topology.ts | 96.27 | 95.04 | 43-44,55-56,60-67 |
| validate/orchestrator-state-core.ts | 98.9 | 96.25 | 308,310-313 |
| validate/orchestrator-state-model-routing-existence.ts | 100 | 100 | (none) |
| codex-native-converter/reporting-render.ts | 100 | 88.63 | 83,184,189 |
| codex-native-converter/reporting.ts | 100 | 88 | 85-86,152,157,232 |
| codex-native-converter/validation.ts | 99.46 | 84.9 | 195-196 |
| codex-native-converter/engine-pipeline.ts | 98 | 84.78 | 127-128,142-143,194-195 |

- All 12 TARGET-PROD files report % Lines >= 85 and % Branch >= 75. All 16 rows recorded with numbers. PASS.
