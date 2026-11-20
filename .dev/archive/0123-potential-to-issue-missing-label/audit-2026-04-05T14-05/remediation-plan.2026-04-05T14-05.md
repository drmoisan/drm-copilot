# potential-to-issue-missing-label - Remediation Plan

- **Issue:** 123
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-05T14-15
- **Status:** Completed
- **Version:** 1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0: Compliance & Context
- [x] [P0-T1] Confirm the remediation scope against `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/remediation-inputs.2026-04-05T14-05.md`, `issue.md`, and the 2026-04-05 review artifacts before editing code.
  - Acceptance: Working notes record that `issue.md` remains the sole requirements source and `spec.md` / `user-story.md` remain absent.
- [x] [P0-T2] Baseline-sync the original feature plan and acceptance checklist state.
  - Acceptance: The executor records which items in `plan.2026-04-05T13-30.md` and `issue.md` are currently satisfied versus still blocked.

### Phase 1: Fix the Bundled Runtime Path
- [x] [P1-T1] Compare `scripts/dev_tools/potential_to_issue.py` with `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` and identify the exact missing-label recovery deltas that must be mirrored into the bundled runtime implementation.
  - Acceptance: A delta note lists the missing constants, protocol/member additions, helper function, and retry branch required in the bundled file.
- [x] [P1-T2] Update `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` so the bundled runtime handles the known missing `feature` label failure by ensuring the label exists and retrying issue creation exactly once.
  - Acceptance: The bundled script contains the same runtime-path behavior required by AC1 while preserving the existing-label path required by AC2.
- [x] [P1-T3] Verify whether `extensions/drm-copilot/resources/templates/potential_to_issue.py` needs any wrapper change; leave it untouched if the wrapper contract already remains correct.
  - Acceptance: The wrapper still delegates to the bundled runtime implementation without changing CLI arguments.
  - Result: Wrapper inspection confirmed no template changes were required.

### Phase 2: Add Runtime-Path Regression Coverage
- [x] [P2-T1] Add focused regression coverage for the bundled runtime path or extension command path that proves the missing-label scenario fails before the fix and passes after the fix.
  - Acceptance: A focused test covers the missing-label recovery path actually used by `drmCopilotExtension.potentialToIssue`.
- [x] [P2-T2] Add focused coverage for the existing-label path on the same runtime route to prove the selected `feature` label still passes through unchanged.
  - Acceptance: The focused runtime-path test confirms a single create attempt with the `feature` label when the label already exists.
- [x] [P2-T3] Reconcile any root-path tests only as needed to keep duplicated behavior and expectations aligned.
  - Acceptance: Root and bundled tests do not assert conflicting behavior.
  - Result: Root tests remained unchanged because the bundled runtime now matches the already-fixed root behavior.

### Phase 3: Final QA and Evidence Regeneration
- [x] [P3-T1] Run the Python QC loop for all touched Python files starting with format, then lint, then type-check, then focused pytest coverage.
  - Acceptance: The final pass completes cleanly and any touched evidence artifacts record the exact commands, timestamps, exit codes, and concise output summaries.
- [x] [P3-T2] If any TypeScript extension tests are added or changed, run the extension QC loop: format, lint, typecheck, and unit tests.
  - Acceptance: All touched extension quality gates pass in a single final pass.
- [x] [P3-T3] Regenerate the feature evidence artifacts and update `issue.md` acceptance checkboxes only for criteria that are now proven by the bundled runtime-path evidence.
  - Acceptance: AC1 and AC3 are checked only if the new runtime-path evidence exists; AC2 remains accurate.
- [x] [P3-T4] Final-sync the original feature plan and remediation status.
  - Acceptance: The original plan and issue checklist reflect the actual delivered state at the end of remediation.
  - Result: No TypeScript files changed, so the conditional extension QC loop was not triggered.

## Test Plan

- **Unit:** Focused tests for the bundled Python runtime path and any necessary root-path parity coverage.
- **Integration:** Extension command-path verification if the selected test home exercises `drmCopilotExtension.potentialToIssue` through the bundled script.
- **Manual/CLI:** Re-run the feature promotion scenario against a repository without a pre-existing `feature` label only if automated coverage cannot fully prove the runtime path.

## Open Questions / Notes

- This remediation plan artifact was created directly in the current tool environment because the configured automatic `atomic_planner` handoff surface was not available here.
- The remediation scope should prefer the smallest change that restores correctness for the bundled runtime path while keeping the minor-audit requirements intact.
