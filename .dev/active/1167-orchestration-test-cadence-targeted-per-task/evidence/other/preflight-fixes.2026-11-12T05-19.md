# Preflight Fixes — Remediation Plan R1, Issue 1167

Timestamp: 2026-11-12T05-19
Plan: docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/remediation-plan.2026-11-12T04-53.md
Validator: branch Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan` exited 0 before and after the fix.

## Fixes

1. [P1-T2] | literal formatting | The two checklist literals quoted as `end with a [phase-gate] task?` and `a [phase-gate] task ending every phase` omitted the backticks around `[phase-gate]` that the Copilot planner checklist lines carry in the tree. The literals now match the tree text (`` end with a `[phase-gate]` task? `` and `` a `[phase-gate]` task ending every phase ``). The anchored lines and the inserted text are unchanged.

## Design Check

Each D15 provision and CR item maps to an implementing task and a test that fails if it is broken: D15a and D15b canonical bullets ([P1-T1]) to `TCW-CANONICAL-*` and `TCW-CANONICAL-DISCRIMINATES` ([P1-T5]); planner surfaces ([P1-T2]) to `TCW-PLANNER-*`; bug template layout ([P1-T3]) to `TCW-TEMPLATE-*` with `GateCount`, `ExpectFailGate`, and `NoChangePhase`; CR2 ([P1-T4]) to the `TCW-POLICY` `Extra` checks; CR3 sweep roots ([P1-T5]) to `TCW-SWEEP-SURFACES`; ledger refresh ([P1-T6]) to the five process-reduction suites. No substantive defect found.
