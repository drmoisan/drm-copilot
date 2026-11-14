# Preflight Record: Owner Decision H3 Scope Revision (Issue #1032)

Timestamp: 2026-10-31T17-26
Scope: one authorized planner revision of the main plan for owner decision H3, followed by one preflight of each plan the revision changed.

## Signals

| Plan | Changed by H3 revision | Final signal | Convergence |
| --- | --- | --- | --- |
| `plan.2026-10-30T18-39.md` | yes | PREFLIGHT: REVISIONS REQUIRED | CONVERGENCE: NO FURTHER ROUNDS EXPECTED |
| `plan-agents-branch-a.md` | no | PREFLIGHT: ALL CLEAR (round 2, `preflight-round2.2026-10-31T04-59.md`; not re-run) | NO FURTHER ROUNDS EXPECTED |
| `plan-agents-branch-b.md` | no | PREFLIGHT: ALL CLEAR (round 2, `preflight-round2.2026-10-31T04-59.md`; not re-run) | NO FURTHER ROUNDS EXPECTED |

## Main Plan Result

- In-place trivial fixes: three, recorded in `preflight-fixes-h3.2026-10-31T17-24.md` ([P5-T1] citation, [P5-T2] test disposition for `repo-automation-command-registration-admin.test.ts`, `## Edit Set` preamble blast-radius note for open item #1013).
- PREFLIGHT-DEFECT: [P6-T10] | unsatisfiable acceptance condition | The coverage-delta task judges each file on whole-file "no decrease". Removing covered lines (`registerSyncAgentsFromInstructionsCommand` in P5-T2, catalog entries in P5-T3, the root entry in P1-T3) can lower the whole-file percentage while no defect exists. Required change: assert no coverage regression on changed lines (removal-only edits record `no added lines`) and that each file's final line and branch coverage meets the 85% and 75% thresholds, recording the baseline and final values; apply the same wording to the Pre-Mortem `Coverage` bullet.
- The branch plans reference only main-plan task IDs and evidence names that still exist (P0-T4, P0-T5, P0-T7 and the named artifacts).

## Outcome

The scope-revision run allows one preflight and no further round, so the run stops with `blocked_reason: validator_failed`. The defect requires one acceptance-text change in [P6-T10]; no task is added, removed or reordered.
