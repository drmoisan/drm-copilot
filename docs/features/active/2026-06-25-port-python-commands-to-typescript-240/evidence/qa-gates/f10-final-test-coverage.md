# Phase 9 — Test + Coverage Final (F10 ts-codex-native-converter)

Timestamp: 2026-06-26T12-20
Command: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" (from extensions/drm-copilot/)
EXIT_CODE: 0
Output Summary:
- Test Suites: 115 passed, 115 total
- Tests: 1387 passed, 1387 total; 0 failed
- All files (src/lib measured): line 97.03%, branch 88.28%, functions 84.57%
- src/lib/codex-native-converter/** per-file coverage (line% / branch%):
  - classifier-claude.ts: 100 / 97.05
  - classifier.ts: 98.63 / 94.44
  - cli.ts: 100 / 94.44
  - codex-native-converter-service-call.ts: 100 / 94.44
  - engine-pipeline.ts: 97.73 / 84
  - engine.ts: 100 / 100
  - index.ts: 100 / 100 (re-export barrel; no executable logic)
  - intermediate-state.ts: 100 / 90
  - inventory.ts: 98.11 / 83.82
  - mapping.ts: 99.1 / 94.73
  - models-intermediate.ts: 100 / 100
  - models.ts: 100 / 95
  - parser.ts: 100 / 83.67
  - pipeline-render.ts: 93.71 / 79.54
  - pipeline-traces.ts: 93.44 / 83.33
  - pipeline.ts: 100 / 92.68
  - reporting-render.ts: 96.65 / 83.78
  - reporting-topology.ts: 100 / 100
  - reporting.ts: 99.16 / 81.03
  - rewrites-rules.ts: 100 / 100
  - rewrites.ts: 100 / 100
  - section-intent.ts: 100 / 100
  - validation.ts: 99.46 / 86.2

Acceptance: EXIT_CODE 0; every `src/lib/codex-native-converter/**` file meets
line >= 85% and branch >= 75%. The lowest branch is pipeline-render.ts at 79.54%
(>= 75%); the lowest line is pipeline-traces.ts at 93.44% (>= 85%).

Note (evidence-path deviation): named `f10-final-test-coverage.md` to avoid
overwriting the F9 `test-coverage-final.md` in the shared qa-gates folder;
remains under the canonical `<FEATURE>/evidence/qa-gates/` location.
