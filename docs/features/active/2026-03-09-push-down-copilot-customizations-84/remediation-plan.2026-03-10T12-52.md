# Remediation Plan: push-down-copilot-customizations (#84)

- **Issue:** #84
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-10T12-52
- **Status:** Planned
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Remediation Inputs: [`remediation-inputs.2026-03-10T12-52.md`](./remediation-inputs.2026-03-10T12-52.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Remediation Context
- [ ] [P0-T1] Review `remediation-inputs.2026-03-10T12-52.md`, `policy-audit.2026-03-10T12-52.md`, and `code-review.2026-03-10T12-52.md` before making any remediation changes
  - Acceptance: Developer notes or commit message references all three artifacts.
- [ ] [P0-T2] Reconfirm the current failure targets before edits by recording the line count of `scripts/dev_tools/push_down_copilot_customizations.py`, the module coverage percentage from the repo-standard Pytest coverage command, and the stale `P1-T10` plan status
  - Acceptance: Remediation work starts from the same three issues called out in the review artifacts.

### Phase 1 — Reduce Module Size Without Changing Behavior
- [ ] [P1-T1] Extract the filesystem protocol and real filesystem adapter from `scripts/dev_tools/push_down_copilot_customizations.py` into a dedicated helper module while preserving type signatures used by the tests
  - Acceptance: The public publisher module still exposes the same entry points, and the extracted file is cohesive.
- [ ] [P1-T2] Extract the rewrite catalog and text-rewrite helpers into a dedicated helper module so `scripts/dev_tools/push_down_copilot_customizations.py` is reduced to orchestration and CLI responsibilities
  - Acceptance: The resulting production files are each `<=500` lines and functional behavior is unchanged.
- [ ] [P1-T3] Update imports and focused tests so the split implementation remains Black/Ruff/Pyright clean
  - Acceptance: No new suppressions are introduced and existing tests still compile/import cleanly.

### Phase 2 — Raise Coverage and Repair Audit Trail
- [ ] [P2-T1] Add targeted Python tests that cover the remaining uncovered paths needed to raise `scripts/dev_tools/push_down_copilot_customizations.py` (or its extracted successors) to `>=90%` coverage
  - Acceptance: Repo-standard coverage output shows the new/changed Python modules at `>=90%`.
- [ ] [P2-T2] Reconcile `plan.2026-03-09T23-14.md` line items for `P1-T10` and add the missing `p1-t10-placeholder-error.2026-03-09T23-14.md` evidence artifact or an explicit audited replacement note
  - Acceptance: The plan and regression-evidence folder accurately represent the fail-before and pass-after history.
- [ ] [P2-T3] Rerun the full Python and TypeScript toolchains in repo order and capture final clean results before closing remediation
  - Acceptance: The following commands all pass in a clean final pass:
    - `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
    - `npm --prefix extensions/drm-copilot run lint`
    - `npm --prefix extensions/drm-copilot run typecheck`
    - `npm --prefix extensions/drm-copilot run test:unit`
    - `poetry run black --check .`
    - `poetry run ruff check`
    - `poetry run pyright`
    - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

## Test Plan

- Unit: expand Python unit coverage for the extracted publisher pieces and keep the existing Jest placeholder-command tests green.
- Integration: no new live-workspace integration run is required unless remediation changes behavior rather than only structure/coverage.
- Manual/CLI: if `main()` behavior changes, verify the CLI still reports the summary artifact path on success and deterministic validation errors on invalid destinations.

## Open Questions / Notes

- This remediation plan was created directly during the review because a separate `atomic_planner` delegation interface was not available in the current tool environment.
- Keep remediation narrowly scoped to the three issues identified in the review artifacts: module size, new-module coverage, and stale plan/evidence state.
