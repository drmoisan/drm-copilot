# Final TypeScript Coverage Gate

Timestamp: `2026-08-11T16:09:30.1473983-04:00`

Command: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageDirectory=../../docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-coverage.2026-08-10T20-25`

EXIT_CODE: `0`

Output Summary: Jest coverage completed successfully as the fourth command in one clean P6-T2 through P6-T5 TypeScript pass. All discovered suites and tests passed.

## Test result

- Test suites: `193 passed / 193 total`.
- Tests: `2,665 passed / 2,665 total`.
- Snapshots: `0`.
- Jest-reported time: `13.544 seconds`.
- Elapsed wall time: `14.6 seconds`.
- Error diagnostics: `0`.
- Warning diagnostics: `0`.

## Repository coverage

| Metric | Covered / total | Percent |
| --- | ---: | ---: |
| Statements | `44,004 / 45,739` | `96.20%` |
| Branches | `6,515 / 7,300` | `89.24%` |
| Functions | `1,304 / 1,434` | `90.93%` |
| Lines | `44,004 / 45,739` | `96.20%` |

Coverage output directory: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-coverage.2026-08-10T20-25`.

`lcov.info` SHA-256: `3583BE671E8A5BEF1CAA8C0428CF9539B3506C07D6C777F729B4DADA1C280F8C`.

## New and changed TypeScript coverage

The changed-code calculation used added line ranges relative to the P0-T7 baseline plus every source line in new untracked TypeScript modules, intersected with the final LCOV `DA` records.

- Changed source files: `21`.
- Added or changed physical lines: `2,962`.
- Instrumented added or changed lines: `2,961`.
- Covered added or changed lines: `2,726`.
- Uncovered added or changed lines: `235`.
- New/changed-code line coverage: `92.06%`.
- Lowest changed-file line coverage: `82.39%` (`extensions/drm-copilot/src/lib/validate/parallel-orchestrator-readiness.ts`, `393 / 477`).
- Changed files below the repository's `80%` line threshold: `0`.

## Ordered-loop and policy verification

- Pre/post formatter path/SHA manifest: unchanged at `B655EA342FEB4A4411E84C168E2673A49DF3B1C66009EDE85BBC36B28FFF2C98`.
- Formatter source writes: `0`.
- Changed TypeScript production/test files checked for size: `44`.
- Files above `500` lines: `0`; maximum: `500` lines.
- New TypeScript suppression additions: `0`.
- `.claude` baseline/current files: `150 / 150`; manifest mismatches: `0`; tracked or untracked `.claude` delta: `0`.
- `.codex/state`: absent.
- `git diff --check`: exit `0`, no output.

`P6_T5_STATUS: COMPLETE`
