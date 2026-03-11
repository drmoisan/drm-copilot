# blank-pr-context-81 remediation - Plan

- **Issue:** #81
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-05T11-15
- **Status:** Planned
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

> This file is pre-created as the remediation plan target for atomic planner completion.

### Phase 0: Compliance & Context
- [ ] [P0-T1] Confirm remediation scope from `remediation-inputs.2026-03-05T11-15.md` and map each required fix to acceptance criteria AC #4 and AC #6

### Phase 1: Strengthen regression test enforcement
- [ ] [P1-T1] Update `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts` to validate placeholder rejection on command-path produced outputs
- [ ] [P1-T2] Update `extensions/scaffold-extension/test/extension.integration.test.ts` to assert substantive section content and reject placeholder-only patterns

### Phase 2: Verification and acceptance closure
- [ ] [P2-T1] Run extension toolchain checks for changed test files (format/lint/type-check/test)
- [ ] [P2-T2] Record acceptance-criteria verification evidence and update feature audit status for AC #4 and AC #6

## Test Plan

- Unit: extension command behavior tests in `extension.collect-pr-context.test.ts`
- Integration: extension integration assertions in `extension.integration.test.ts`
- Manual/CLI: destination-workspace command run on Windows host to close AC #6 or document approved deferment

## Open Questions / Notes

- Atomic planner should refine these placeholders into deterministic atomic tasks with acceptance criteria and explicit file-level validations.
