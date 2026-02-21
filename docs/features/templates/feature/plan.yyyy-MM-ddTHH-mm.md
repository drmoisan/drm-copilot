# feature-name - Plan

- **Issue:** #0
- **Parent (optional):** none
- **Owner:** owner
- **Last Updated:** 1970-01-01T00-00
- **Status:** Planned
- **Version:** 1.0

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Applicable language policies must be listed explicitly for touched file types.

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

> **Instructions for this section:**
> - Break work into **Phases** (broad buckets) and **Atomic Tasks** (binary, 5-30 min units).
> - Use `- [ ] [P#-T#]` for every task.
> - Start every task with a **strong verb** (Implement, Create, Update, Verify).
> - No "bucket" tasks like "Refactor module" or "Write tests"; split them into specific, verifiable steps.
> - **Self-Validating Phases:** Include necessary test creation/update tasks *within* the phase that implements the code. Do not defer verification to a final "Testing" phase.

### Phase 0 — Compliance & Context
- [ ] [P0-T1] Confirm alignment with repo policies by reading `.github/instructions/general-code-change.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, and `.github/instructions/python-unit-test.instructions.md` before touching code
  - Acceptance: Development log contains policy review timestamp prior to Phase 1 commits

### Phase 1 — Implement Scoped Change
- [ ] [P1-T1] Implement one production-file behavior change with a single deterministic outcome
- [ ] [P1-T2] Add one scenario-specific test that verifies the Phase 1 behavior change
  - Preconditions: Target function/module exists and acceptance criteria are documented
  - Acceptance: Targeted test command exits with code 0

### Phase 2 — Verification & QA
- [ ] [P2-T1] Run formatter for touched language toolchain and confirm exit code 0
- [ ] [P2-T2] Run lint, type-check, and tests in repo-required order and confirm all pass in one clean loop

## Test Plan

- Unit: List exact unit test commands for touched modules
- Integration: List exact integration test commands when applicable
- Manual/CLI: List exact deterministic command checks when required

## Open Questions / Notes

- None.
