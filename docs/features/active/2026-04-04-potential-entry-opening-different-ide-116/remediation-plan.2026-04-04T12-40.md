# Remediation Plan: 2026-04-04-potential-entry-opening-different-ide-116

- **Issue:** #116
- **Parent (optional):** none
- **Owner:** Dan Moisan
- **Last Updated:** 2026-04-04T12-40
- **Status:** Planned
- **Version:** remediation-1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Primary remediation source: [`remediation-inputs.2026-04-04T12-40.md`](./remediation-inputs.2026-04-04T12-40.md)
- Sole requirements source: [`issue.md`](./issue.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

> Manual seed created by the reviewer because no direct `atomic_planner` handoff channel is exposed in this session. Treat this file as a planner-ready scaffold that still requires planner/executor preflight before execution.

### Phase 0: Remediation Context and Integrity
- [ ] [P0-T1] Verify the minor-audit folder still satisfies its integrity contract before remediation begins.
  - Acceptance:
    - `issue.md` still contains `- Work Mode: minor-audit`.
    - `issue.md` still contains the explicit `## Acceptance Criteria` section.
    - `spec.md` and `user-story.md` do not exist in the active folder.
    - Existing Phase 0, Phase 1, and Phase 2 evidence artifacts remain present.
- [ ] [P0-T2] Create timestamped remediation evidence targets under `evidence/qa-gates/` for live Windows verification and changed/new-code coverage closure.
  - Acceptance:
    - Planned filenames are documented before any remediation evidence is captured.

### Phase 1: Live Windows Verification Closure
- [ ] [P1-T1] Execute `drmCopilotExtension.newPotentialBugEntry` from an already-open Windows workspace and record whether the created markdown file opens in the originating VS Code or VS Code Insiders window.
  - Acceptance:
    - The remediation evidence artifact records the short name used, the created file path, and whether the originating window was reused.
    - If the workflow still opens a new window, the artifact records FAIL evidence instead of claiming PASS.
- [ ] [P1-T2] Execute `drmCopilotExtension.newActiveFeatureFolder` from the same already-open Windows workspace and record whether the generated files open in the originating VS Code or VS Code Insiders window.
  - Acceptance:
    - The remediation evidence artifact records the prompt inputs, generated file paths, and whether the originating window was reused.
    - If the workflow still opens a new window, the artifact records FAIL evidence instead of claiming PASS.
- [ ] [P1-T3] Update `issue.md` acceptance checkboxes only for criteria that have explicit passing evidence.
  - Acceptance:
    - AC-1 is checked only if `P1-T1` passes.
    - AC-2 is checked only if `P1-T2` passes.
    - Criterion text remains unchanged.

### Phase 2: Coverage Closure and Audit Refresh
- [ ] [P2-T1] Produce deterministic changed/new-code coverage evidence for the four launcher files and the targeted pytest modules.
  - Acceptance:
    - The remediation artifact states the exact command used.
    - The artifact records numeric changed/new-code coverage or documents a policy-compliant exception path.
- [ ] [P2-T2] Refresh the end-state summary with the new live-verification and coverage evidence.
  - Acceptance:
    - AC-1 and AC-2 status in the summary matches the new evidence.
    - Changed/new-code coverage status no longer reads `remediation required` unless the evidence still fails to close the gap.
- [ ] [P2-T3] Refresh the reduced-audit artifacts so the final status matches the remediated evidence.
  - Acceptance:
    - `feature-audit`, `policy-audit`, and `code-review` each cite the new remediation evidence.
    - If all required evidence passes, the refreshed artifacts report a PASS-style outcome.

## Test Plan

- Unit: reuse the targeted pytest launcher suite to confirm existing regression coverage still passes.
- Integration: live Windows execution of the two extension commands from an already-open workspace.
- Manual/CLI: verify the resulting file paths and same-window behavior in VS Code or VS Code Insiders.

## Open Questions / Notes

- Planner preflight is still required because this file was seeded manually instead of being produced by a live `atomic_planner` handoff.
- The current merge blockers are evidence gaps, not a recorded failing unit-test or QC command.
