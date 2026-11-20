# Acceptance Criteria Status ([P7-T12])

Timestamp: 2026-11-04T02-07
Command: grep -c of the checkbox lines under `## Acceptance Criteria` in spec.md (S1-S33) and user-story.md (U1-U23), after the one-at-a-time check-offs recorded per task in the plan and the evidence files below
EXIT_CODE: 0
Output Summary: 56 criteria; 54 checked off with evidence on disk; 2 remain unchecked as pending-CI (S32, U23), because each states the `windows-latest` coverage report of `poshqc / PowerShell QC` as its proof and that report exists only after CI runs on the PR head. No criterion text was changed; no criterion was added.

## Check-off record (criterion, mapped tasks, evidence)

Criteria S1-S27 and U1-U20 were checked off in Phases 1-5 as their suites passed (see the plan's `## Acceptance Criteria Traceability` and the `regression-testing/p1-*` to `p5-*` evidence files). Phase 6-7 check-offs:

| Criterion | Mapped tasks | Evidence | State |
|---|---|---|---|
| S28 (property test per pure function; traceability map) | P1-T2 through P4-T3, P7-T6 | `## Pure Function Property Map` (48 functions), the module evidence files, `qa-gates/qa-test-purity.2026-11-04T02-03.md` | checked |
| S29 (byte-identical bundle copies, `core.json` lines, same three rows, manifest and push-down suites pass) | P6-T1, P6-T2, P7-T7, P7-T8 | `other/bundle-mirror.2026-11-04T01-12.md`, `regression-testing/p6-registration.2026-11-04T01-15.md`, `qa-gates/qa-push-down-contracts.2026-11-04T02-03.md`, `qa-gates/qa-jest-pack-completeness.2026-11-04T02-03.md` | checked |
| S30 (module convention, no dynamic invocation, analyzer zero findings) | P6-T2, P7-T2 | `regression-testing/p6-registration.2026-11-04T01-15.md`, `qa-gates/qa-pssa.2026-11-04T01-22.md` | checked |
| S31 (purity tokens, `AfterAll`, three seeded shuffled runs, fresh single-process run) | P7-T5, P7-T6, P7-T3 | `regression-testing/isolation-shuffled-pester.2026-11-04T02-02.md`, `qa-gates/qa-test-purity.2026-11-04T02-03.md`, `qa-gates/qa-pester-coverage.2026-11-04T01-51.md` | checked |
| S32 (line coverage >= 85 per new production file, read from the `poshqc / PowerShell QC` `windows-latest` report) | P7-T3, P7-T4 | local figures in `qa-gates/qa-pester-coverage.2026-11-04T01-51.md` and `qa-gates/coverage-delta.2026-11-04T01-51.md` (lowest 96.84); the CI report is the stated proof | pending-CI |
| S33 (no file above 800 lines; repository gate passes) | P7-T9 | `qa-gates/qa-file-size.2026-11-04T02-04.md` | checked |
| U21 (mirrored, listed in `core.json`, push-down contract tests pass) | P6-T1, P6-T2, P7-T7, P7-T8 | as S29 | checked |
| U22 (property test per pure function; no temporary file) | P1-T2 through P4-T3, P7-T6 | as S28 | checked |
| U23 (line coverage >= 85 per new production file on `windows-latest` in `poshqc / PowerShell QC`) | P7-T3, P7-T4 | as S32 | pending-CI |

## Pending-CI criteria

Per the `acceptance-criteria-tracking` skill section `### CI-Dependent Criteria`, S32 and U23 stay unchecked until the item's orchestrator run reads the `poshqc / PowerShell QC` result on the PR head (S9 CI green gate) and then checks them off, pushes, and re-verifies the head SHA. The local figures that the CI report is expected to reproduce are in `qa-gates/coverage-delta.2026-11-04T01-51.md`.

### Acceptance Criteria Status

- Source: `spec.md` `## Acceptance Criteria` (S1-S33) and `user-story.md` `## Acceptance Criteria` (U1-U23)
- Total AC items: 56
- Checked off (delivered): 54
- Remaining (unchecked): 2
- Items remaining: S32 "Pester line coverage is >= 85% for each new production file, read per file from the Pester coverage report of `poshqc / PowerShell QC` (`windows-latest`), with no production file excluded from measurement; figures recorded under `evidence/qa-gates/`." (pending-CI); U23 "Pester line coverage is >= 85% for each new production file on `windows-latest` in `poshqc / PowerShell QC`." (pending-CI)

| Source File | Total AC | Checked | Unchecked | Notes |
|---|---|---|---|---|
| `spec.md` | 33 | 32 | 1 (S32) | checkbox-backed; S32 pending-CI |
| `user-story.md` | 23 | 22 | 1 (U23) | checkbox-backed; U23 pending-CI |

The `## Definition of Done` and `## Seeded Test Conditions (from potential)` checkboxes in `spec.md` are outside the `## Acceptance Criteria` section and are not acceptance criteria under the work-mode rule; they are left for the reviewer.
