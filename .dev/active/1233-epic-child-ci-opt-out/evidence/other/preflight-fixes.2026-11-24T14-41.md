# Preflight Fixes - Issue #1233 remediation cycle 1

Timestamp: 2026-11-24T14-41
Plan: .dev/active/1233-epic-child-ci-opt-out/remediation-plan.2026-11-24T14-21.md
Inputs: .dev/active/1233-epic-child-ci-opt-out/remediation-inputs.2026-11-24T13-43.md
Signal: PREFLIGHT: ALL CLEAR
Validator: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exit 0 before and after the fixes.

## Design check (inputs F1, Minor, Nit, Nit)

- F1 ordinal reads of `local_qc_gate` fields, `remediation_loop`, `review_outcomes`, and the last outcome `head_sha`: P1-T2; failing tests are the four `OCC-CORPUS-*` rows of the new fixtures (fail-before recorded in P1-T2).
- F1 ordinal presence check without changing `ci_gate` and `pr_gate` callers: P1-T2 (`Get-MissingOrdinalGateKey`); `OrchestratorStateCompletionChecks.Tests.ps1` guards the unchanged callers; the field-key fixture fails if the presence check stays case-insensitive.
- F1 corpus fixture pinned in Python, TypeScript, PowerShell: P1-T2 fixtures, P1-T8 to P1-T10 counts.
- F1 bundle re-mirror and 0014 block update: P1-T2, checked by the Set Y contract tests and Set L in P1-T6.
- Nit `$ciGate = (`: P1-T2, recorded in the 0014 block update.
- Minor (merge-gate ordinal reads, rows in both runtimes): P1-T3; failing rows `OPT-ORD-*` and `CLAUDE-OPT-ORD-*` (fail-before recorded in P1-T3).
- Nit (Codex gate blank line and bundle copy): P1-T5; acceptance by the blank-line-only diff and bundle identity.
- S7 and U7 re-check: P1-T13.

No rule, parameter, or boundary without an implementing task and a test.

## Fixes

1. [P0-T1] | count and file-set citation | "the seven files this cycle edits" listed three sources, "their bundle copies", and two tests, which is ten files once the `.codex/hooks/` twin of the helper and the four bundle copies are counted. The task now names the ten existing files explicitly. Meaning unchanged.
2. [P1-T7] | count citation | "the seven files of P0-T1" changed to "the ten files of P0-T1" to match fix 1.
3. `## Targeted Selections` (Set P) and [P1-T3] acceptance | selection citation aligned with the task-check rule | `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` and its sibling suites read every test file that dot-sources a merge gate (directory glob), including both opt-out suites that P1-T3 edits, and require their closure-seam mocks. Set P and the P1-T3 task-check list now include every `enforce-gate-suites.EpicStateIsolation.*.Tests.ps1`. No assertion changes.
4. [P1-T13] acceptance | literal conflict with the `acceptance-criteria-tracking` preserve-text rule | "each names the four new fixtures" could be read as editing the criterion text, which the same acceptance and the tracking skill forbid. Both criteria already name the corpus directory `tests/fixtures/orchestrator_state_child_ci/`; the acceptance now states that this corpus holds the four new fixtures and that the check-off changes only `- [ ]` to `- [x]`. The asserted outcome (S7 and U7 checked, verified by the extended corpus) is unchanged.

## Probes recorded during the pass (no change needed)

- The three corpus suites call only the gate selection (`Get-OrchestratorStateCompletionCiGateError`, `validate_completion_gate_evidence`, `validateCompletionGateEvidence`), so the pre-#1233 concurrent-review check C8 does not add an error for the `Remediation_Loop` fixture; the "only the head-binding string" expectations hold.
- The review guard reads `remediation_loop`, `head_sha`, and `feature-folder` by member access (case-insensitive) and `review_mode` ordinally, so the Claude L2 and L1 case-variant rows reach the helper; the Claude gate branch 1 reads `epic_mode` case-insensitively, so the Claude `Epic_Mode` predicate row reaches the helper before the fix and fails as P1-T3 states.
- `"head_sha"` occurs twice in the `Get-OptOutJson` output, so the two `Head_Sha` rows use literal checkpoint JSON under the case-variant convention.
