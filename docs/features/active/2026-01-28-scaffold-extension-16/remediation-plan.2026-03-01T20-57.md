# scaffold-extension remediation - Plan

- **Issue:** 16
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-01T20-57
- **Status:** Planned
- **Version:** 1.0

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)

**Primary remediation spec source:** `docs/features/active/2026-01-28-scaffold-extension-16/remediation-inputs.2026-03-01T20-57.md`

## Implementation Plan (Atomic Tasks)

> Placeholder scaffold created for `atomic_planner` to fill with deterministic phases and `[P#-T#]` tasks.

### Phase 0: Compliance & Context
- [ ] [P0-T1] Confirm policy alignment and remediation scope from remediation-inputs artifact.

### Phase 1: Baseline Diff and Commit Scope Repair
- [ ] [P1-T1] Ensure implementation files are staged/committed and visible in `origin/main...HEAD` range.

### Phase 2: Acceptance Coverage Gaps
- [ ] [P2-T1] Add missing PowerShell runtime error-path tests.
- [ ] [P2-T2] Strengthen cross-platform integration verification.

### Phase 3: Documentation Gaps
- [ ] [P3-T1] Complete README platform notes, first-run workflow, and production-foundation section.

### Phase 4: Final QA
- [ ] [P4-T1] Run format/lint/typecheck/test and record final pass evidence.

## Test Plan

- Unit: missing PowerShell runtime case
- Integration: realistic Windows/POSIX command behavior evidence
- Manual/CLI: verify PR diff scope and README acceptance criteria text

## Open Questions / Notes

- This file is intentionally pre-seeded and requires atomic-planner normalization/finalization.
