# Remediation Plan: 2026-02-21-bootstrap-utility-scripts-40 (2026-02-21T22-24)

- **Issue:** #40
- **Owner:** Dan Moisan
- **Last Updated:** 2026-02-21T22-24
- **Status:** Planned
- **Version:** 2.0
- **Authoritative remediation spec:** `docs/features/active/2026-02-21-bootstrap-utility-scripts-40/remediation-inputs.2026-02-21T22-24.md`
- **Work mode source:** `docs/features/active/2026-02-21-bootstrap-utility-scripts-40/issue.md` (`- Work Mode: minor-audit`)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- PowerShell Code Change: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- TypeScript Code Change: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- PR summary context: `artifacts/pr_context.summary.txt`
- PR appendix context: `artifacts/pr_context.appendix.txt`

## Atomic Implementation Plan

### Phase 0 — Context, Baseline Evidence, and Preflight Gate
- [x] [P0-T1] Read and acknowledge `.github/copilot-instructions.md` in this branch as the first policy source
	- Acceptance: `evidence/other/remediation-context.2026-02-21T22-24.md` contains exact line `PolicyRead: .github/copilot-instructions.md`.
- [x] [P0-T2] Read and acknowledge `.github/instructions/general-code-change.instructions.md` in this branch
	- Acceptance: `evidence/other/remediation-context.2026-02-21T22-24.md` contains exact line `PolicyRead: .github/instructions/general-code-change.instructions.md`.
- [x] [P0-T3] Read and acknowledge `.github/instructions/general-unit-test.instructions.md` in this branch
	- Acceptance: `evidence/other/remediation-context.2026-02-21T22-24.md` contains exact line `PolicyRead: .github/instructions/general-unit-test.instructions.md`.
- [x] [P0-T4] Read and acknowledge applicable language policy files for Python, PowerShell, and TypeScript in this branch
	- Acceptance: `evidence/other/remediation-context.2026-02-21T22-24.md` contains exact lines `PolicyRead: .github/instructions/python-code-change.instructions.md`, `PolicyRead: .github/instructions/python-unit-test.instructions.md`, `PolicyRead: .github/instructions/powershell-code-change.instructions.md`, `PolicyRead: .github/instructions/powershell-unit-test.instructions.md`, `PolicyRead: .github/instructions/typescript-code-change.instructions.md`, and `PolicyRead: .github/instructions/typescript-unit-test.instructions.md`.
- [x] [P0-T5] Validate authoritative inputs by reading `remediation-inputs.2026-02-21T22-24.md` and recording `minor-audit` mode from `issue.md` in `evidence/other/remediation-context.2026-02-21T22-24.md`
	- Acceptance: `remediation-context.2026-02-21T22-24.md` exists and contains exact lines `Work Mode: minor-audit` and `Source of Truth: remediation-inputs.2026-02-21T22-24.md`.
- [x] [P0-T6] Capture base/head metadata, commits in range, changed-files overview, and diff-stat totals from `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` into `evidence/baseline/pr-context-baseline.2026-02-21T22-24.md`
	- Acceptance: artifact includes exact fields `BaseRef: origin/development@818743838d44e29936965dc868fcfaeb01edd592`, `HeadRef: bootstrap-utilities-#40@e467a0e8b49f7c5222f747c39b15fc4209dc5015`, `CommitCount: 2`, and `DiffStat: 125 files changed, 40761 insertions(+), 2 deletions(-)`.
- [x] [P0-T7] Execute baseline plan-status sync immediately after plan generation by reconciling checkboxes against current delivered state in this remediation plan
	- Acceptance: a single baseline sync commit/diff exists where this file marks `[P0-T7]` complete and no future-phase task is marked complete before its evidence artifact exists.
- [x] [P0-T8] Capture baseline Python gate evidence in `evidence/baseline/python-baseline.2026-02-21T22-24.md`
	- Acceptance: artifact contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:` with current failure/pass status.
- [x] [P0-T9] Capture baseline PowerShell gate evidence in `evidence/baseline/powershell-baseline.2026-02-21T22-24.md`
	- Acceptance: artifact contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T10] Capture baseline TypeScript gate evidence in `evidence/baseline/typescript-baseline.2026-02-21T22-24.md`
	- Acceptance: artifact contains `Timestamp:`, `Command: npm run test:unit`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T11] Create preflight handoff artifact `evidence/other/preflight-request.2026-02-21T22-24.md` with directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY` and path to this remediation plan
	- Acceptance: artifact contains exact line `DIRECTIVE: PREFLIGHT VALIDATION ONLY` and exact line `PlanFile: docs/features/active/2026-02-21-bootstrap-utility-scripts-40/remediation-plan.2026-02-21T22-24.md`.
- [x] [P0-T12] Run validation-only handoff with `atomic_executor` and store response in `evidence/other/preflight-response.2026-02-21T22-24.md`
	- Acceptance: response artifact contains exact line `PREFLIGHT: ALL CLEAR`.

### Phase 1 — Fix Python Type-Check Scope (AC1/AC4 blocker)
- [x] [P1-T1] Update `[tool.pyright]` in `pyproject.toml` to analyze only repository Python paths and exclude vendored `node_modules` Python content
	- Acceptance: `poetry run pyright` output contains zero diagnostics for `node_modules/` paths.
- [x] [P1-T2] Update pyright invocation behavior in `scripts/dev_tools/fix_all.py` to use the repository pyright scope contract without reintroducing `node_modules` diagnostics
	- Acceptance: running the pyright path from `fix_all.py` exits with code `0` and does not print diagnostics for files under `node_modules/`.
- [x] [P1-T3] Update pyright invocation behavior in `scripts/dev_tools/shell_qc.py` to use the same repository pyright scope contract
	- Acceptance: running the pyright path from `shell_qc.py` exits with code `0` and does not print diagnostics for files under `node_modules/`.
- [x] [P1-T4] Record Python gate evidence in `evidence/qa-gates/python.2026-02-21T22-24.md` after pyright-scope remediation
	- Acceptance: artifact contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:` without `node_modules` diagnostics.

### Phase 2 — Decompose Oversized Production Files to <=500 Lines
- [x] [P2-T1] Create decomposition map `evidence/other/decomposition-map.2026-02-21T22-24.md` defining target module boundaries for each oversized production file
	- Acceptance: map artifact lists each required file exactly once: `atomic_executor/cli.py`, `new_active_feature_folder.py`, `fix_all.py`, `atomic_executor/qc_runner.py`, `potential_to_issue.py`, `pr_context/render.py`.
- [x] [P2-T2] Decompose `scripts/dev_tools/atomic_executor/cli.py` into cohesive modules while preserving CLI behavior and reduce `cli.py` to <=500 lines
	- Acceptance: `scripts/dev_tools/atomic_executor/cli.py` line count is `<=500` and targeted CLI tests pass.
- [x] [P2-T3] Decompose `scripts/dev_tools/new_active_feature_folder.py` into cohesive modules and reduce file size to <=500 lines
	- Acceptance: `scripts/dev_tools/new_active_feature_folder.py` line count is `<=500` and existing tests targeting this functionality pass.
- [x] [P2-T4] Decompose `scripts/dev_tools/fix_all.py` into cohesive modules and reduce file size to <=500 lines
	- Acceptance: `scripts/dev_tools/fix_all.py` line count is `<=500` and existing tests targeting this functionality pass.
- [x] [P2-T5] Decompose `scripts/dev_tools/atomic_executor/qc_runner.py` into cohesive modules and reduce file size to <=500 lines
	- Acceptance: `scripts/dev_tools/atomic_executor/qc_runner.py` line count is `<=500` and existing tests targeting this functionality pass.
- [x] [P2-T6] Decompose `scripts/dev_tools/potential_to_issue.py` into cohesive modules and reduce file size to <=500 lines
	- Acceptance: `scripts/dev_tools/potential_to_issue.py` line count is `<=500` and existing tests targeting this functionality pass.
- [x] [P2-T7] Decompose `scripts/dev_tools/pr_context/render.py` into cohesive modules and reduce file size to <=500 lines
	- Acceptance: `scripts/dev_tools/pr_context/render.py` line count is `<=500` and existing tests targeting this functionality pass.

### Phase 3 — Decompose Oversized Test Files to <=500 Lines
- [ ] [P3-T1] Split `tests/scripts/dev_tools/atomic_executor/test_cli.py` into smaller focused test modules while preserving current assertions
	- Acceptance: no resulting test file exceeds `500` lines and all moved tests are collected by `pytest`.
- [ ] [P3-T2] Split `tests/scripts/dev_tools/test_new_active_feature_folder.py` into smaller focused test modules while preserving current assertions
	- Acceptance: no resulting test file exceeds `500` lines and all moved tests are collected by `pytest`.
- [ ] [P3-T3] Split `tests/scripts/dev_tools/test_collect_pr_context.py` into smaller focused test modules while preserving current assertions
	- Acceptance: no resulting test file exceeds `500` lines and all moved tests are collected by `pytest`.
- [ ] [P3-T4] Split `tests/scripts/dev_tools/test_github.py` into smaller focused test modules while preserving current assertions
	- Acceptance: no resulting test file exceeds `500` lines and all moved tests are collected by `pytest`.
- [ ] [P3-T5] Split `tests/scripts/dev_tools/test_resolve_execute_plan_prompt.py` into smaller focused test modules while preserving current assertions
	- Acceptance: no resulting test file exceeds `500` lines and all moved tests are collected by `pytest`.
- [ ] [P3-T6] Run scripted line-count verification over all changed production/test/reusable-script files and record results in `evidence/qa-gates/line-counts.2026-02-21T22-24.md`
	- Acceptance: artifact contains `EXIT_CODE: 0` and no listed tracked file has a line count greater than `500`.

### Phase 4 — Targeted Verification and QA-Gate Evidence Stabilization
- [ ] [P4-T1] Run Python targeted verification command `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and append results to `evidence/qa-gates/python.2026-02-21T22-24.md`
	- Acceptance: artifact includes a second run block with `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and `EXIT_CODE: 0`.
- [ ] [P4-T2] Run PowerShell targeted verification command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` and append results to `evidence/qa-gates/powershell.2026-02-21T22-24.md`
	- Acceptance: artifact contains `Timestamp:`, exact command, and `EXIT_CODE: 0`.
- [ ] [P4-T3] Run TypeScript targeted verification commands and write results to `evidence/qa-gates/typescript.2026-02-21T22-24.md`
	- Acceptance: artifact contains command/result blocks for `npm run format:check`, `npm run lint`, `npm run typecheck`, and `npm run test:unit` with `EXIT_CODE: 0` for each command.
- [ ] [P4-T4] Enforce blocked-gate documentation schema in every `evidence/qa-gates/*.2026-02-21T22-24.md` artifact
	- Acceptance: each artifact includes either `GateStatus: PASS` or, when non-zero exit exists, includes exact fields `GateStatus: BLOCKED`, `BlockedReason:`, `RemediationOwner:`, and `NextAction:`.

### Phase 5 — Final Full Toolchain QA Loop
- [ ] [P5-T1] Run Python full QA loop until one clean pass completes in order: `poetry run black .` -> `poetry run ruff check` -> `poetry run pyright` -> `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
	- Acceptance: a final Python loop run is recorded in `evidence/qa-gates/python.2026-02-21T22-24.md` with `EXIT_CODE: 0` for all four commands in one uninterrupted pass.
- [ ] [P5-T2] Run PowerShell full QA loop until one clean pass completes in order: `Invoke-PoshQCFormat -Root .` -> `Invoke-PoshQCAnalyze -Root .` -> `Invoke-PoshQCTest -Root .`
	- Acceptance: a final PowerShell loop run is recorded in `evidence/qa-gates/powershell.2026-02-21T22-24.md` with `EXIT_CODE: 0` for all three commands in one uninterrupted pass.
- [ ] [P5-T3] Run TypeScript full QA loop until one clean pass completes in order: `npm run format` -> `npm run lint` -> `npm run typecheck` -> `npm run test:unit`
	- Acceptance: a final TypeScript loop run is recorded in `evidence/qa-gates/typescript.2026-02-21T22-24.md` with `EXIT_CODE: 0` for all four commands in one uninterrupted pass.

### Phase 6 — Plan Status and Delivery Closure
- [ ] [P6-T1] Execute final plan-status sync at remediation completion by reconciling all completed tasks to concrete evidence artifacts
	- Acceptance: each checked task in this plan has a referenced evidence artifact path committed in the same change set.
- [ ] [P6-T2] Publish remediation completion summary in `evidence/other/remediation-closeout.2026-02-21T22-24.md`
	- Acceptance: closeout artifact contains exact fields `Timestamp:`, `AC1Status:`, `AC4Status:`, `AC5Status:`, and `PreflightSignal: PREFLIGHT: ALL CLEAR`.

## Mandatory Preflight Validation Contract

- The preflight handoff MUST be validation-only and include the exact directive line:
	- `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- The accepted completion signal for planning preflight is:
	- `PREFLIGHT: ALL CLEAR`
- If preflight returns `PREFLIGHT: REVISIONS REQUIRED`, update this plan with a precise delta and rerun preflight until `PREFLIGHT: ALL CLEAR` is produced.
