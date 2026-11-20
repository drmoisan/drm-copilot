# Acceptance Criteria Verification (P4-T8)

Timestamp: 2026-11-04T02-19
Command: none (AC check-off record per acceptance-criteria-tracking; source spec.md `## Acceptance Criteria`)
EXIT_CODE: 0
Output Summary: AC1 to AC10 checked in spec.md; AC11 unchecked as pending-CI. Plan references: R = remediation-plan.2026-11-04T01-03.md, A = plan.2026-11-03T17-43.md (APPROVED). Evidence paths are relative to the feature folder.

| AC | Criterion (spec.md) | Verifying tasks | Evidence | Result |
|---|---|---|---|---|
| AC1 | The leaking test no longer leaves `$env:PATH` changed (single-process run) | A P0-T10, A P2-T1, R P2-T4, R P3-T6 | evidence/regression-testing/global-state-fail-before.2026-11-04T00-37.md; evidence/regression-testing/global-state-pass-after.2026-11-04T01-20.md | PASS |
| AC2 | A save/restore of `$env:PATH` covers every Context (Describe level) | A P2-T1, R P2-T1 | evidence/other/target-rd1.2026-11-04T01-20.md | PASS |
| AC3 | Every other unrestored process-global mutation is saved and restored; no other variable, location, alias, or global state remains altered | R P1-T3, R P1-T4, R P2-T1, R P2-T4 | evidence/regression-testing/fail-before-lastexitcode.2026-11-04T01-19.md; evidence/regression-testing/global-state-pass-after.2026-11-04T01-20.md | PASS |
| AC4 | A guard fails if the suite changes any environment variable (full, case-insensitive), with no temporary files and no production edit | A P1-T1, A P1-T2, R P1-T1, R P1-T2 | evidence/regression-testing/fail-before-guard.2026-11-04T00-53.md; evidence/regression-testing/fail-before-guard-globals.2026-11-04T01-18.md | PASS |
| AC5 | The guard passes on the fixed tree, also in the same process with other dev-tools suites, and leaves the environment unchanged itself | R P2-T3, R P2-T4, R P3-T1 to R P3-T6 | evidence/regression-testing/pass-after-guard.2026-11-04T01-20.md; evidence/regression-testing/global-state-pass-after.2026-11-04T01-20.md; evidence/regression-testing/order-leak.2026-11-04T01-44.md | PASS |
| AC6 | The guard is shown to fail against the pre-fix leak, with fail-before evidence | A P1-T2, R P1-T3, R P1-T4 | evidence/regression-testing/fail-before-guard.2026-11-04T00-53.md; evidence/regression-testing/fail-before-guard-globals.2026-11-04T01-18.md; evidence/regression-testing/fail-before-lastexitcode.2026-11-04T01-19.md | PASS |
| AC7 | The plan records which guard form was chosen | A P1-T5, R P1-T5 | evidence/other/guard-decision.2026-11-04T00-56.md (GuardForm b); evidence/other/lastexitcode-guard-decision.2026-11-04T01-19.md (LastExitCodeGuardForm p) | PASS |
| AC8 | Single-process runs in forward, reversed, and three seeded orders show victims removed and no new failures | A P0-T17 (fail-before), R P3-T1 to R P3-T6 (pass-after) | evidence/regression-testing/repro-victim-set.2026-11-04T00-49.md; evidence/regression-testing/order-forward.2026-11-04T01-25.md; order-reversed.2026-11-04T01-29.md; order-seed-1066.2026-11-04T01-33.md; order-seed-20261103.2026-11-04T01-36.md; order-seed-7.2026-11-04T01-40.md; order-leak.2026-11-04T01-44.md (all under evidence/regression-testing/) | PASS |
| AC9 | The seven-stage toolchain passes in a single pass; coverage not reduced; no exclude entry added | R P4-T1 to R P4-T7 | evidence/qa-gates/qa-loop.2026-11-04T02-19.md; evidence/qa-gates/pester-scripts-coverage.2026-11-04T02-10.md | PASS |
| AC10 | Changed and new test files stay under 700 lines each | R P4-T6 | evidence/qa-gates/size-and-scope.2026-11-04T02-18.md (TARGET 554, GUARD 210) | PASS |
| AC11 | CI required checks are green on the PR head | orchestrator at S9 | none yet | pending-CI |

Notes:
- AC4: the guard's environment comparison uses an `OrdinalIgnoreCase` dictionary over `[System.Environment]::GetEnvironmentVariables()`; the guard uses no temporary-file facility.
- AC11 is checked off by the item's orchestrator run at S9 after the CI green gate records success.
