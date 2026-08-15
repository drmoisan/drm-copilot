# Cycle 1 TypeScript Test and Coverage Gate

Timestamp: `2026-08-15T00:22:57.3057226-04:00`

Plan task: `[P5-T12]`

Command: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=lcov --coverageReporters=text --coverageReporters=json-summary`

- EXIT_CODE: `0`
- Output Summary: `194/194` test suites and `2,690/2,690` tests passed; `0` snapshots; `0` failures.
- Coverage-summary SHA-256: `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0`.

## Repository thresholds

| Counter | Result | Threshold | Disposition |
|---|---:|---:|:---:|
| Lines | 44,127/45,740 = 96.47% | >=85% | PASS |
| Branches | 6,589/7,338 = 89.79% | >=75% | PASS |

## Modified-owner reconciliation

The P0 baseline values are retained in `evidence/qa-gates/typescript-test-coverage.2026-08-13T15-38.md`. The current JSON summary was parsed after this run.

| Production path | P0 baseline lines | Current lines | Result |
|---|---:|---:|:---:|
| `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | 466/491 = 94.908350% | 484/491 = 98.574338% | PASS |
| `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` | 308/320 = 96.250000% | 315/320 = 98.437500% | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 354/360 = 98.333333% | 360/360 = 100.000000% | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | 466/497 = 93.762575% | 478/497 = 96.177062% | PASS |
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | 409/417 = 98.081535% | 417/417 = 100.000000% | PASS |

- Modified owners non-regressing: `5/5`.
- The current coverage-summary hash equals the prior accepted hash.

Acceptance result: `PASS`. The test command exited zero, repository line and branch thresholds passed, and all five modified owners retained or exceeded their P0 baseline line coverage.
