# Final TypeScript Test and Coverage Gate

Timestamp: `2026-08-13T15-38`

Plan task: `[P7-T3]`

Working directory: `extensions/drm-copilot`

Command: `npm run test -- --coverage`

- Exit code: `0`.
- Test suites: `194/194` passed.
- Tests: `2,690/2,690` passed.
- Snapshots: `0`.
- Duration: `10.372` seconds.

## Repository coverage

| Counter | Covered/total | Percent | Threshold | Result |
|---|---:|---:|---:|:---:|
| Statements | 44,127/45,740 | 96.47% | >=85% | PASS |
| Lines | 44,127/45,740 | 96.47% | >=85% | PASS |
| Branches | 6,589/7,338 | 89.79% | >=75% | PASS |
| Functions | 1,304/1,434 | 90.93% | supporting metric | PASS |

## Modified-owner no-regression matrix

| Production path | P0 baseline lines | Final lines | Result |
|---|---:|---:|:---:|
| `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | 466/491 = 94.908350% | 484/491 = 98.574338% | PASS |
| `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` | 308/320 = 96.250000% | 315/320 = 98.437500% | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 354/360 = 98.333333% | 360/360 = 100.000000% | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | 466/497 = 93.762575% | 478/497 = 96.177062% | PASS |
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | 409/417 = 98.081535% | 417/417 = 100.000000% | PASS |

- Modified owners non-regressing: `5/5`.
- Current coverage-summary SHA-256: `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0`.
- This equals the prior audit-confirmed summary hash, so the audited changed-executable-line result remains `419/424 = 98.820755%` with no owner regression.
- Current LCOV SHA-256: `C8F736630D09BDCB210EE194EB0F04983D1D72316F6CBE62960903C206E5C585`.
- Clean consecutive loop: Prettier `PASS` -> ESLint `PASS` -> TSC `PASS` -> Jest/coverage `PASS`.

`P7_T3_TEST_STATUS: PASS`
