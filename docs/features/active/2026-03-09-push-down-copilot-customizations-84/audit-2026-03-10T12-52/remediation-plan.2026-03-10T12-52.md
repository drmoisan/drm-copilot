# Remediation Plan: push-down-copilot-customizations (#84)

- **Issue:** #84
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-10T12-52
- **Status:** Planned
- **Version:** 0.1

## Required References

- Copilot Instructions: [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Python Suppression Policy: [`.github/instructions/python-suppressions.instructions.md`](../../../../.github/instructions/python-suppressions.instructions.md)
- Intent-First Python Commenting Policy: [`.github/instructions/self-explanatory-code-commenting.instructions.md`](../../../../.github/instructions/self-explanatory-code-commenting.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- TypeScript Suppression Policy: [`.github/instructions/typescript-suppressions.instructions.md`](../../../../.github/instructions/typescript-suppressions.instructions.md)
- Workspace Instructions: [`AGENTS.md`](../../../../AGENTS.md)
- Remediation Inputs: [`remediation-inputs.2026-03-10T12-52.md`](./remediation-inputs.2026-03-10T12-52.md)

**All work must comply with these policies; do not duplicate their content here.**

## Requirements Sources

- Work mode source: [`issue.md`](./issue.md) (`Work Mode: full`)
- Full-mode requirements: [`spec.md`](./spec.md) and [`user-story.md`](./user-story.md)
- Remediation scope: [`remediation-inputs.2026-03-10T12-52.md`](./remediation-inputs.2026-03-10T12-52.md)
- Review constraints: [`policy-audit.2026-03-10T12-52.md`](./policy-audit.2026-03-10T12-52.md) and [`code-review.2026-03-10T12-52.md`](./code-review.2026-03-10T12-52.md)

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline Evidence
- [x] [P0-T1] Read `.github/copilot-instructions.md` as the first mandatory policy file for this remediation.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/copilot-instructions.md` as item `1` under `Policy Order:`.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` as the second mandatory policy file for this remediation.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/general-code-change.instructions.md` as item `2` under `Policy Order:`.
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` as the third mandatory policy file for this remediation.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/general-unit-test.instructions.md` as item `3` under `Policy Order:`.
- [x] [P0-T4] Read `.github/instructions/python-code-change.instructions.md` as the Python code policy for the remediation implementation work.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/python-code-change.instructions.md` as item `4` under `Policy Order:`.
- [x] [P0-T5] Read `.github/instructions/python-unit-test.instructions.md` as the Python unit-test policy for the remediation implementation work.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/python-unit-test.instructions.md` as item `5` under `Policy Order:`.
- [x] [P0-T6] Read `.github/instructions/python-suppressions.instructions.md` before editing any touched Python file that could trigger Ruff or Pyright suppressions.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/python-suppressions.instructions.md` as item `6` under `Policy Order:`.
- [x] [P0-T7] Read `.github/instructions/self-explanatory-code-commenting.instructions.md` before editing the typed Python remediation modules.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/self-explanatory-code-commenting.instructions.md` as item `7` under `Policy Order:`.
- [x] [P0-T8] Read `.github/instructions/typescript-code-change.instructions.md` before running the required extension-package QA commands.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/typescript-code-change.instructions.md` as item `8` under `Policy Order:`.
- [x] [P0-T9] Read `.github/instructions/typescript-unit-test.instructions.md` before running the required extension-package unit-test baseline and final QA commands.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/typescript-unit-test.instructions.md` as item `9` under `Policy Order:`.
- [x] [P0-T10] Read `.github/instructions/typescript-suppressions.instructions.md` before reconciling any extension-package diagnostics surfaced during the required QA commands.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `.github/instructions/typescript-suppressions.instructions.md` as item `10` under `Policy Order:`.
- [x] [P0-T11] Read `AGENTS.md` as the final workspace-level instruction source for this remediation.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` exists and lists `AGENTS.md` as item `11` under `Policy Order:`.
- [x] [P0-T12] Write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.md` after reviewing the mandatory policy files and the authoritative full-mode inputs.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Policy Order:`, `Work Mode Source: issue.md`, and `Resolved Work Mode: full`, plus explicit entries for `spec.md`, `user-story.md`, `remediation-inputs.2026-03-10T12-52.md`, `policy-audit.2026-03-10T12-52.md`, and `code-review.2026-03-10T12-52.md`.
- [x] [P0-T13] Capture the Python baseline formatting state in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/py-format.md` by running `poetry run black --check .`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T14] Capture the Python baseline lint state in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/py-lint.md` by running `poetry run ruff check`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T15] Capture the Python baseline type-check state in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/py-typecheck.md` by running `poetry run pyright`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T16] Capture the Python baseline test-and-coverage state in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/py-test-cov.md` by running `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:`, and the `Output Summary:` records numeric coverage values for the overall run and for `scripts/dev_tools/push_down_copilot_customizations.py` or its extracted push-down successor modules when reported.
- [x] [P0-T17] Capture the TypeScript baseline formatting state for the extension package in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/ts-format.md` by running `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T18] Capture the TypeScript baseline lint state for the extension package in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/ts-lint.md` by running `npm --prefix extensions/drm-copilot run lint`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T19] Capture the TypeScript baseline type-check state for the extension package in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/ts-typecheck.md` by running `npm --prefix extensions/drm-copilot run typecheck`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T20] Capture the TypeScript baseline unit-test state for the extension package in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/ts-test-unit.md` by running `npm --prefix extensions/drm-copilot run test:unit`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Reduce Module Size Without Changing Behavior
- [x] [P1-T1] Extract the filesystem protocol and real filesystem adapter from `scripts/dev_tools/push_down_copilot_customizations.py` into a dedicated helper module while preserving type signatures used by the tests
  - Acceptance: A new helper module exists beside `scripts/dev_tools/push_down_copilot_customizations.py`, and `scripts/dev_tools/push_down_copilot_customizations.py` still contains the exact symbol names `parse_args`, `main`, and `push_down_customizations`.
- [x] [P1-T2] Extract the rewrite catalog and text-rewrite helpers into a dedicated helper module so `scripts/dev_tools/push_down_copilot_customizations.py` is reduced to orchestration and CLI responsibilities
  - Acceptance: A line-count check shows every touched production Python file created or edited by this remediation is `<=500` lines, and the rewrite catalog no longer resides in `scripts/dev_tools/push_down_copilot_customizations.py`.
- [x] [P1-T3] Update imports and focused tests so the split implementation remains Black/Ruff/Pyright clean
  - Acceptance: The touched Python files contain no new `# noqa` or `# type: ignore` suppressions, and `scripts/dev_tools/push_down_copilot_customizations.py` imports the extracted helper modules by explicit module path.

### Phase 2 — Raise Coverage and Repair Audit Trail
- [x] [P2-T1] Add targeted Python tests that cover the remaining uncovered paths needed to raise `scripts/dev_tools/push_down_copilot_customizations.py` (or its extracted successors) to `>=90%` coverage
  - Acceptance: The final pytest coverage artifact from [P3-T8] records numeric post-change coverage of `>=90%` for `scripts/dev_tools/push_down_copilot_customizations.py` and for each extracted push-down helper module touched by this remediation.
- [x] [P2-T2] Reconcile `plan.2026-03-09T23-14.md` line items for `P1-T10` and add the missing `p1-t10-placeholder-error.2026-03-09T23-14.md` evidence artifact or an explicit audited replacement note
  - Acceptance: `plan.2026-03-09T23-14.md` records a non-stale status for `P1-T10`, and either `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t10-placeholder-error.2026-03-09T23-14.md` exists or an explicit replacement note exists in the same folder with the reason the original fail-before artifact cannot exist.
- [x] [P2-T3] Record the repo-order final QA command manifest in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/final-qa-manifest.md` before remediation closure.
  - Acceptance: The manifest file exists and lists the exact commands and target evidence files for [P3-T1] through [P3-T8].

### Phase 3 — Final QA Loop & Coverage Gates
- [x] [P3-T1] Run the final TypeScript formatting command and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-format.md` using `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P3-T2] Run the final TypeScript lint command and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-lint.md` using `npm --prefix extensions/drm-copilot run lint`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P3-T3] Run the final TypeScript type-check command and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-typecheck.md` using `npm --prefix extensions/drm-copilot run typecheck`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P3-T4] Run the final TypeScript unit-test command and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-test-unit.md` using `npm --prefix extensions/drm-copilot run test:unit`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P3-T5] Run the final Python formatting command and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-format.md` using `poetry run black --check .`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P3-T6] Run the final Python lint command and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-lint.md` using `poetry run ruff check`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P3-T7] Run the final Python type-check command and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-typecheck.md` using `poetry run pyright`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P3-T8] Run the final Python coverage-test command and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-test-cov.md` using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: The evidence file exists and contains exact lines beginning with `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:`, and the `Output Summary:` records numeric post-change coverage values plus an explicit confirmation that the extracted push-down modules are each `>=90%` covered.
- [x] [P3-T9] Verify one clean final QA pass after any required reruns and record the final-pass manifest in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/qa-loop-summary.md`.
  - Acceptance: The summary file exists and contains exact lines beginning with `Final Clean Pass: yes`, `TypeScript Loop Reruns:`, and `Python Loop Reruns:`, and it lists the exact evidence files used for the clean pass for [P3-T1] through [P3-T8].

## Test Plan

- Unit: expand Python unit coverage for the extracted publisher pieces and keep the existing Jest placeholder-command tests green.
- Integration: no new live-workspace integration run is required unless remediation changes behavior rather than only structure/coverage.
- Manual/CLI: if `main()` behavior changes, verify the CLI still reports the summary artifact path on success and deterministic validation errors on invalid destinations.

## Executor Preflight Requirement (Validate-Only)

Use this exact handoff directive for preflight validation before execution:

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

Required terminal signal before execution:

`PREFLIGHT: ALL CLEAR`

## Preflight Checklist

- [x] Phase headings follow the canonical `### Phase N — <Title>` format.
- [x] Task IDs are sequential and phase-aligned.
- [x] Phase 0 includes policy reads in mandatory order, `phase0-instructions-read.md`, and per-command baseline evidence tasks.
- [x] Every baseline and final-QA command task requires an artifact with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] The baseline pytest task requires numeric coverage values.
- [x] The final QA phase runs TypeScript commands first in repo order, then Python commands in repo order.
- [x] The final pytest coverage task requires numeric post-change coverage and explicit `>=90%` confirmation for the extracted push-down modules.
- [x] The remediation intent remains limited to module size, coverage, and stale evidence reconciliation.

## Open Questions / Notes

- This remediation plan has been normalized in place for the repo's full-mode atomic execution contract.
- Keep remediation narrowly scoped to the three issues identified in the review artifacts: module size, new-module coverage, and stale plan/evidence state.
