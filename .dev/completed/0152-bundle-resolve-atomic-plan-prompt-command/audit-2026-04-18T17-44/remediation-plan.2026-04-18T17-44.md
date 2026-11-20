---
issue: 152
parent: none
owner: drmoisan
last_updated: 2026-04-18T17-44
status: Planned
status_color: blue
version: 1.0
work_mode: full-feature
plan_type: remediation
plan_path: docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/remediation-plan.2026-04-18T17-44.md
---

# Remediation Plan: 2026-04-17-bundle-resolve-atomic-plan-prompt-command-152 (2026-04-18T17-44)

- **Issue:** #152
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-18T17-44
- **Status:** Planned
- **Version:** 1.0
- **Authoritative remediation spec:** `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/remediation-inputs.2026-04-18T17-44.md`
- **Work mode source:** `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/issue.md` (`- Work Mode: full-feature`)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Python Code Change: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Python Suppressions: [`.github/instructions/python-suppressions.instructions.md`](../../../../.github/instructions/python-suppressions.instructions.md)
- Self-Explanatory Python Comments: [`.github/instructions/self-explanatory-code-commenting.instructions.md`](../../../../.github/instructions/self-explanatory-code-commenting.instructions.md)
- PR summary context: `artifacts/pr_context.summary.txt`
- PR appendix context: `artifacts/pr_context.appendix.txt`

**All work must comply with these policies; do not duplicate their content here.**

## Remediation Objective

Restore the feature to reviewable merge readiness by fixing the broken bundled command runtime contract, adding regression coverage that exercises the real wrapper CLI contract, closing the coverage-proof review gate for the changed TypeScript and Python scope, and synchronizing requirement and plan checkboxes only after the refreshed evidence supports them.

## Requirements Traceability

| Requirement ID | Source | Requirement | Planned Coverage |
|---|---|---|---|
| REQ-1 | `remediation-inputs.2026-04-18T17-44.md` item 1 | Align the bundled runtime contract so `resolveAtomicPlanPrompt` executes successfully. | Phase 1, Phase 4 |
| REQ-2 | `remediation-inputs.2026-04-18T17-44.md` item 2 | Add regression coverage that exercises the real wrapper CLI contract. | Phase 2, Phase 4 |
| REQ-3 | `remediation-inputs.2026-04-18T17-44.md` item 3 | Close the changed/new-code coverage proof gap and refresh QA disposition artifacts. | Phase 3, Phase 4 |
| REQ-4 | `remediation-inputs.2026-04-18T17-44.md` item 4 | Synchronize requirement docs, README, and plan checkbox state with refreshed evidence. | Phase 0, Phase 3, Phase 4 |

## Constraint Register

| Constraint ID | Source | Constraint |
|---|---|---|
| CON-1 | `issue.md` work mode marker | Treat `spec.md` and `user-story.md` as authoritative requirement sources because work mode resolves to `full-feature`. |
| CON-2 | `remediation-inputs.2026-04-18T17-44.md` Do Not Do | Do not widen scope into unrelated command-surface or MCP refactors. |
| CON-3 | `remediation-inputs.2026-04-18T17-44.md` Do Not Do | Do not weaken coverage gates or review criteria to force a PASS outcome. |
| CON-4 | review blocker evidence | Keep the runtime contract deterministic across the service, wrapper, and bundled resolver; do not leave partially aligned argv handling. |
| CON-5 | acceptance tracking contract | Perform baseline and final checkbox synchronization for the original feature plan and requirement files only after evidence supports the new state. |

## Atomic Implementation Plan

### Phase 0 — Context, Baseline Sync, and Failing-Proof Capture

- [x] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `AGENTS.md`, `issue.md`, `spec.md`, `user-story.md`, `remediation-inputs.2026-04-18T17-44.md`, `policy-audit.2026-04-18T17-44.md`, `code-review.2026-04-18T17-44.md`, `feature-audit.2026-04-18T17-44.md`, and `plan.2026-04-17T19-54.md`, then record the read order in `evidence/remediation-baseline/phase0-instructions-read.2026-04-18T17-44.md`.
  - Acceptance: The artifact exists with `Timestamp:`, `Policy Order:`, `Resolved Work Mode: full-feature`, and the exact ordered file list.

- [x] [P0-T2] Capture the baseline Python toolchain state under `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/remediation-baseline/python/` by running these exact Phase 4 commands from the workspace root and saving one artifact per command: `poetry run black --check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` to `p0-t2.black-check.2026-04-18T17-44.md`, `poetry run ruff check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` to `p0-t2.ruff-check.2026-04-18T17-44.md`, `poetry run pyright scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` to `p0-t2.pyright.2026-04-18T17-44.md`, and `poetry run pytest --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates -q` to `p0-t2.pytest-coverage.2026-04-18T17-44.md`.
  - Acceptance: Each of the four artifacts exists under `evidence/remediation-baseline/python/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the pytest coverage artifact's `Output Summary:` records numeric coverage headline values.

- [x] [P0-T3] Capture the baseline TypeScript toolchain state under `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/remediation-baseline/typescript/` by running these exact Phase 4 commands from `extensions/drm-copilot/` and saving one artifact per command: `npm run format` to `p0-t3.format.2026-04-18T17-44.md`, `npm run lint` to `p0-t3.lint.2026-04-18T17-44.md`, `npm run typecheck` to `p0-t3.typecheck.2026-04-18T17-44.md`, and `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` to `p0-t3.unit-coverage.2026-04-18T17-44.md`.
  - Acceptance: Each of the four artifacts exists under `evidence/remediation-baseline/typescript/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the unit-test coverage artifact's `Output Summary:` records numeric coverage headline values.

- [x] [P0-T4] Perform baseline status synchronization for `plan.2026-04-17T19-54.md`, `spec.md`, and `user-story.md` against the current review findings, then record the before-state in `evidence/remediation-baseline/p0-t4.status-sync-baseline.2026-04-18T17-44.md`.
  - Acceptance: The artifact lists every currently checked item that is unsupported by the review evidence and every unchecked item that already has verified evidence.

- [x] [P0-T5] Re-run and persist the failing direct wrapper invocation in `evidence/regression-testing/p0-t5.resolve-atomic-plan-prompt-fail-before.2026-04-18T17-44.md` using the production argv contract from `repo-automation-service.ts`.
  - Acceptance: The artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 1`, and `Output Summary:` naming the `--workspace` argument rejection.

### Phase 1 — Repair the Runtime Contract

- [x] [P1-T1] Decide and implement one authoritative runtime contract for `resolveAtomicPlanPrompt` across `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py`, and `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py` so the extension and bundled CLI agree on supported arguments.
  - Acceptance: The three layers share a single deterministic contract that succeeds for an eligible plan file without invoking repo-local scripts.

- [x] [P1-T2] Ensure the repaired contract preserves workspace-relative resolution semantics and does not break clipboard fallback behavior.
  - Acceptance: The resolved prompt still uses the correct workspace-relative substitutions, and the command either copies to the clipboard or prints the resolved prompt when clipboard integration is unavailable.

- [x] [P1-T3] Capture the repaired direct invocation result in `evidence/regression-testing/p1-t3.resolve-atomic-plan-prompt-pass-after.2026-04-18T17-44.md`.
  - Acceptance: The artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:` showing successful prompt resolution.

### Phase 2 — Raise Regression-Test Fidelity

- [x] [P2-T1] Add or update Python tests under `tests/extensions/drm_copilot/resources/templates/` so at least one test executes the real bundled wrapper with the production argv contract and fails if the CLI rejects `--workspace` or any other service-emitted argument.
  - Acceptance: The new test fails on the original blocker and passes after the contract fix.

- [x] [P2-T2] Add or update TypeScript tests under `extensions/drm-copilot/test/` so the command/service layer is verified against the repaired runtime contract rather than mocked spawn arguments alone.
  - Acceptance: The TypeScript regression suite proves the command reaches the repaired wrapper contract and surfaces failures accurately.

- [x] [P2-T3] Refresh the targeted regression evidence in `evidence/regression-testing/ts-resolve-atomic-plan-prompt.2026-04-17T19-54.md` and `evidence/regression-testing/py-resolve-atomic-plan-prompt.2026-04-17T19-54.md`, or create superseding timestamped equivalents if the existing filenames are intentionally immutable.
  - Acceptance: Updated evidence cites the repaired tests and their pass counts.

### Phase 3 — Close Review Gates and Sync Documentation

- [x] [P3-T1] Produce deterministic changed/new-code coverage proof for the changed TypeScript and Python scope, or record an approved exception dossier if reviewer-approved proof remains structurally impossible.
  - Acceptance: The resulting coverage-proof artifact is sufficient to remove the `remediation required` disposition from the coverage summaries or to cite an explicit accepted exception.
- [x] [P3-T2] Refresh `evidence/qa-gates/py-coverage-summary.2026-04-17T19-54.md`, `evidence/qa-gates/ts-coverage-summary.2026-04-17T19-54.md`, and `evidence/qa-gates/qa-loop-summary.2026-04-17T19-54.md` so they match the final repaired evidence set.
  - Acceptance: The three QA summary artifacts cite the final proof result consistently.
- [x] [P3-T3] Update `extensions/drm-copilot/README.md` if the new command remains part of the user-visible extension surface.
  - Acceptance: User-facing command documentation matches the shipped behavior and command name.
- [x] [P3-T4] Perform final status synchronization for `plan.2026-04-17T19-54.md`, `spec.md`, and `user-story.md` only after the repaired runtime path and QA evidence support the new state.
  - Acceptance: No PASS item remains unchecked, and no FAIL/PARTIAL item remains checked.

### Phase 4 — Final QA Loop and Review Handoff

- [x] [P4-T1] Run the Python toolchain from the workspace root in this exact order: `poetry run black --check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, `poetry run ruff check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, `poetry run pyright scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, and `poetry run pytest --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates -q`.
  - Acceptance: All four steps pass in a single final loop and fresh QA artifacts are recorded.

- [x] [P4-T2] Run the TypeScript toolchain from `extensions/drm-copilot/` in this exact order: `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`.
  - Acceptance: All four steps pass in a single final loop and fresh QA artifacts are recorded.

- [x] [P4-T3] Validate the refreshed acceptance state by updating or superseding `policy-audit.2026-04-18T17-44.md`, `code-review.2026-04-18T17-44.md`, and `feature-audit.2026-04-18T17-44.md` through a re-review.
  - Acceptance: The follow-up review can report `Go` only if the runtime blocker is closed, the coverage-proof gate is resolved, and the acceptance sources are synchronized.

## Test Plan

- Python wrapper and bundled resolver CLI regression tests under `tests/extensions/drm_copilot/resources/templates/`
- TypeScript command and repo-automation regression tests under `extensions/drm-copilot/test/`
- Direct CLI verification using the repaired bundled wrapper contract
- Final Python and TypeScript toolchain loops with coverage enabled

## Open Questions / Notes

- This remediation plan is written to the required target path and follows the atomic planner task structure expected by the review workflow.
- If the changed/new-code coverage proof remains structurally impossible after the runtime fix, record the exception dossier explicitly rather than leaving the QA summaries in an indeterminate state.
