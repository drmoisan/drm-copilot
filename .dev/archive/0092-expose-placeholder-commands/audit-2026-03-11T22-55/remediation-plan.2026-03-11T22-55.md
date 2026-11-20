# Remediation Plan: 2026-03-11-expose-placeholder-commands-92

- **Issue:** #92
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-11T22-55
- **Status:** Remediation Requested
- **Version:** 1.0

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- PowerShell Code Change Policy: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**Authoritative remediation spec:** `docs/features/active/2026-03-11-expose-placeholder-commands-92/remediation-inputs.2026-03-11T22-55.md`

## Implementation Plan (Atomic Tasks)

> This file was created from the repo feature-plan template as the remediation target.
>
> Automatic delegation to `atomic_planner` is required by the review workflow, but the current tool set exposed in this session does not provide a planner-delegation entry point. The authoritative remediation requirements are recorded in `remediation-inputs.2026-03-11T22-55.md`; fill this section with deterministic `[P#-T#]` tasks once planner delegation is available.

### Phase 0: Compliance & Context
- [ ] [P0-T1] Atomic planner fill pending
  - Acceptance: Replace this placeholder with concrete remediation tasks derived from `remediation-inputs.2026-03-11T22-55.md`

## Test Plan

- TypeScript: `npm --prefix extensions/drm-copilot run format`, `lint`, `typecheck`, `test:unit`
- Python: `poetry run black .`, `ruff check`, `pyright`, `pytest --cov-report=term-missing`
- PowerShell: direct `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCTest`
- Packaging/runtime validation: verify the built extension entry point no longer contains placeholder registrations

## Open Questions / Notes

- The highest-priority remediation target is the packaged runtime drift in `extensions/drm-copilot/out/extension.js`.
- The second blocker is rewrite-catalog drift in `push_down_copilot_customizations_rewrites.py`.
- The file-picker default-folder gap should be fixed in the same remediation pass.
