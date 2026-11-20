# Remediation Plan: 2026-03-14-bundle-hard-lock-resolver-into-extension-103 (2026-03-15T00-14)

- **Issue:** #103
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-15T00-14
- **Status:** Draft
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

> Placeholder plan created from the repo template for remediation follow-up.
> Intended source of truth for task generation: `remediation-inputs.2026-03-15T00-14.md`.
> In this review session, no dedicated `atomic_planner` tool/interface was available to auto-populate the atomic task list, so the task breakdown remains intentionally pending.

### Phase 0: Compliance & Context
- [ ] [P0-T1] Confirm alignment with repo policies by reading the required general, Python, and TypeScript instruction files before modifying remediation code.

### Phase 1: Pending atomic_planner population
- [ ] [P1-T1] Populate this remediation plan from `remediation-inputs.2026-03-15T00-14.md` using the repo's atomic planning workflow.

## Test Plan

- Unit: Re-run `poetry run pytest` and `npm --prefix extensions/drm-copilot run test:unit`.
- Integration/CLI: Re-run the bundled wrapper against a missing target and confirm a non-zero exit status.
- Validation: Re-run `poetry run black --check .`, `poetry run ruff check`, `poetry run pyright`, `npm --prefix extensions/drm-copilot run format -- --check`, `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, and `python -m scripts.dev_tools.validate_json`.

## Open Questions / Notes

- The blocker is narrow and should be fixable without changing the overall architecture.
- Split the oversized Python test module as part of remediation to restore policy compliance.
