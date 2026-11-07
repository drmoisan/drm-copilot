# <feature-name> - Plan

- **Issue:** <issue>
- **Parent (optional):** <parent-id>
- **Owner:** <name>
- **Last Updated:** <yyyy-MM-ddTHH-mm>
- **Status:** <template>
- **Version:** <version_number>

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- (Add language-specific policies as needed, e.g. `python-code-change.instructions.md`)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

> **Instructions for this section:**
> - Break work into **Phases** (broad buckets) and **Atomic Tasks** (binary, 5-30 min units).
> - Use `- [ ] [P#-T#]` for every task.
> - Start every task with a **strong verb** (Implement, Create, Update, Verify).
> - No "bucket" tasks like "Refactor module" or "Write tests"; split them into specific, verifiable steps.
> - **Self-Validating Phases:** Include necessary test creation/update tasks *within* the phase that implements the code. Do not defer verification to a final "Testing" phase.
> - Include explicit static baseline tasks, final-QA tasks, and a per-file threshold task for every language in scope when policy requires coverage.
> - Name the expected artifact path or location in each evidence-producing task's acceptance criteria.
> - If any required static baseline artifact, QA artifact, or per-file coverage figure is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

### Phase 0: Context & Inputs
- [ ] [P0-T1] <Atomic task>

### Phase 1: <Phase Name>
- [ ] [P1-T1] <Atomic task with strong verb>
- [ ] [P1-T2] <Atomic task>
  - Preconditions: <optional>
  - Acceptance: <optional>

### Phase 2: <Phase Name>
- [ ] [P2-T1] <Atomic task>
- [ ] [P2-T2] <Atomic task>

## Pre-Mortem

<!-- One bullet per label; state how the next review or CI run could fail on that dimension and the mitigation, or "not applicable" with the reason. -->
- Review checklists:
- Coverage:
- Mirror parity:
- File size:
- Test isolation:
- CI-only behavior:
- Evidence:

## Test Plan

- Unit: ...
- Integration: ...
- Manual/CLI: ...
- Coverage evidence: list the static baseline artifact paths, the final-QA artifact paths, and the per-file threshold results from the single gate run for each in-scope language

## Open Questions / Notes

- ...
