# Decisions (remediation cycle 3, P1-T3 and P1-T4)

Timestamp: 2026-11-24T03-56
Command: n/a (decision record)
EXIT_CODE: 0
Output Summary: one deviation recorded, P1-T3 full Pester gate replaced by a targeted run; one non-blocking integration-lane exclusion.

## D1: P1-T3 full Pester gate replaced by a targeted selection

- Plan text: P1-T3 acceptance names one full parallel Pester gate with repo-wide and per-file coverage comparison.
- Basis: owner instruction dated 2026-11-23, in the owner's words: "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests." The coordinating orchestrator directed that it be applied to P1-T3.
- Decision (autonomous mode, recommended option): run one targeted parallel Pester selection through the launcher plus the harness generator check and the push-down contract pytest files. Evidence: `evidence/qa-gates/pester-gate.2026-11-24T03-56.md` and `evidence/qa-gates/contracts.2026-11-24T03-56.md`.
- Coverage: not re-measured. Coverage evidence remains the cycle-2 full gate `evidence/qa-gates/pester-gate.2026-11-23T14-00.md`. Cycle 3 changed no PowerShell production file, and the merge left the three item modules unchanged.
- The plan file is not edited; this record is the deviation record.

## D2: Integration-lane files excluded from the selection

- `DocsCompleteIntegration.Tests.ps1` and `DocsReferenceIntegration.Tests.ps1` matched the selection search but are integration-lane files. The launcher refuses them locally (`TEST_EXECUTION_POLICY_BLOCKED`). They run in CI. Recorded as a non-blocking deviation.
