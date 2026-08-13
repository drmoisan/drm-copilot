# TypeScript Tests and Coverage Baseline

Timestamp: 2026-08-12T05-24

Command: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageDirectory=../../docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/typescript/coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=json-summary`

EXIT_CODE: 0

Output Summary: Jest passed 193 test suites and 2,678 tests with 0 failures in 14.459 seconds. Repository coverage was 96.36% lines (44,076/45,740), 96.36% statements (44,076/45,740), 89.57% branches (6,562/7,326), and 90.93% functions (1,304/1,434). LCOV, HTML, and JSON summary outputs were retained below this canonical evidence directory.

## Reviewed modified-file baselines

| Production path | Covered/total lines | Baseline line coverage | Exact uncovered lines | Review regression reconciliation |
|---|---:|---:|---|---|
| `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | 466/491 | 94.90% | 121-122, 146-147, 173-179, 201-202, 216, 218-219, 226-228, 271-276 | Reproduces the reviewed 94.91% value within report rounding |
| `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` | 308/320 | 96.25% | 108-109, 113-117, 241-245 | Reproduces the reviewed 96.25% value |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 354/360 | 98.33% | 341-346 | Reproduces the reviewed 98.33% value |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | 466/497 | 93.76% | 164-165, 230-234, 239-243, 339-343, 353-356, 366-370, 374, 376-379 | Reconciles the reviewed 93.75% value to Jest's current two-decimal 93.76% result |
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | 409/417 | 98.08% | 387-390, 392-395 | Reproduces the reviewed 98.08% value |

These five percentages are the individual no-regression thresholds for P11-T4.

