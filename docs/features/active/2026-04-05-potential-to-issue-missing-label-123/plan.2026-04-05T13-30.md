---
title: "2026-04-05-potential-to-issue-missing-label"
issue: 123
owner: "drmoisan"
work_mode: "minor-audit"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-05T13-30"
source_of_truth: "docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md"
plan_path: "docs/features/active/2026-04-05-potential-to-issue-missing-label-123/plan.2026-04-05T13-30.md"
---

# 2026-04-05-potential-to-issue-missing-label (Minimal-Audit Plan)

## Overview

This minor-audit plan constrains the bugfix to one production Python file and one pytest module so `drmCopilotExtension.potentialToIssue` can promote a `feature` entry even when the repository does not already contain a `feature` label. `issue.md` is the only requirements and acceptance-criteria source; `spec.md` and `user-story.md` must remain absent and are not plan inputs.

## Deterministic Inputs

- Sole requirements source: `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`
- Acceptance criteria source: `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md#acceptance-criteria`
- Required absence: `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/spec.md` and `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/user-story.md`
- Constrained production target: `scripts/dev_tools/potential_to_issue.py`
- Constrained regression target: `tests/scripts/dev_tools/test_potential_to_issue.py`
- Small-path budget: exactly 1 production Python file plus exactly 1 pytest module

## Deterministic Constraints

- `CON-001`: Use `issue.md` only; do not require, cite, or create `spec.md`, `user-story.md`, or `research.md`.
- `CON-002`: Keep exactly three phases in this order: baseline capture, constrained implementation placeholder, final QC loop.
- `CON-003`: Keep production-code scope limited to `scripts/dev_tools/potential_to_issue.py`; any second production Python file is out of scope for this plan.
- `CON-004`: Keep regression scope limited to `tests/scripts/dev_tools/test_potential_to_issue.py`; do not create a new pytest module.
- `CON-005`: Add deterministic `[expect-fail]` regression coverage before any production-code change, record the red run, then implement the minimal fix, then record the green run.
- `CON-006`: Every command artifact named in this plan must include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- `CON-007`: Baseline and final QC pytest commands must run in coverage mode and record numeric coverage headlines in `Output Summary:`.
- `CON-008`: Phase 2 command tasks are unconditional; if any Phase 2 command changes files or fails, resume the QC loop from `[P2-T1]` after corrections, and no planned command task may be marked skipped.
- `CON-009`: Only the checkbox items under `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md` → `## Acceptance Criteria` may be checked off, and only after the evidence named in this plan exists; preserve each checkbox line’s text exactly.

## Small-Path Directives

`DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

## Evidence Naming Rules

- Store baseline artifacts under `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/baseline/`.
- Store targeted regression artifacts under `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/regression-testing/`.
- Store implementation and acceptance-checkoff artifacts under `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/other/`.
- Store final QC artifacts under `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/qa-gates/`.
- Use ISO-8601 timestamps in filenames with the format `yyyy-MM-ddTHH-mm`.

### Phase 0 — Baseline capture

- [x] [P0-T1] Read the mandatory policy files in repository order and write `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/baseline/phase0-instructions-read.md`.
	- Acceptance:
		- The artifact exists at the exact path above.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Policy Order:`.
		- The artifact lists these exact files in order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`.

- [x] [P0-T2] Verify the minor-audit requirements scope and write `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/baseline/p0-t2.requirements-scope.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t2.requirements-scope.*.md` exists.
		- The artifact contains `Work Mode: minor-audit`.
		- The artifact contains `Acceptance Criteria Source: docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md#acceptance-criteria`.
		- The artifact contains `Required Absence: docs/features/active/2026-04-05-potential-to-issue-missing-label-123/spec.md = absent`.
		- The artifact contains `Required Absence: docs/features/active/2026-04-05-potential-to-issue-missing-label-123/user-story.md = absent`.
		- The artifact contains `Plan uses issue.md as the sole requirements source.`

- [x] [P0-T3] Run the baseline Python format check command `poetry run black --check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/baseline/p0-t3.black-check.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t3.black-check.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run black --check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` states either `already formatted` or `would reformat`.

- [x] [P0-T4] Run the baseline Python lint command `poetry run ruff check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/baseline/p0-t4.ruff.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t4.ruff.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run ruff check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` states either `passed` or names the first Ruff diagnostic.

- [x] [P0-T5] Run the baseline Python type-check command `poetry run pyright scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/baseline/p0-t5.pyright.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t5.pyright.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run pyright scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` states either `0 errors, 0 warnings, 0 informations` or names the first blocking Pyright diagnostic.

- [x] [P0-T6] Run the baseline coverage-enabled pytest command `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/baseline/p0-t6.pytest-coverage.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t6.pytest-coverage.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` includes numeric `Coverage Total:` and numeric `Coverage File: scripts/dev_tools/potential_to_issue.py =` headline values.

- [x] [P0-T7] Record the constrained small-path budget in `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/baseline/p0-t7.small-path-scope.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t7.small-path-scope.*.md` exists.
		- The artifact contains `Production Target: scripts/dev_tools/potential_to_issue.py`.
		- The artifact contains `Regression Target: tests/scripts/dev_tools/test_potential_to_issue.py`.
		- The artifact contains `Budget: 1 production Python file + 1 pytest module`.
		- The artifact copies the exact three checkbox texts from `issue.md` under `## Acceptance Criteria`.

### Phase 1 — Constrained implementation placeholder

- [x] [P1-T1] [expect-fail] Add the regression test `test_promote_potential_feature_missing_label_recovers_and_moves_file` to `tests/scripts/dev_tools/test_potential_to_issue.py` before any production-code change.
	- Acceptance:
		- `tests/scripts/dev_tools/test_potential_to_issue.py` contains the exact function definition `def test_promote_potential_feature_missing_label_recovers_and_moves_file() -> None:`.
		- The new test configures a missing-label failure for a `feature` promotion and asserts that promotion still completes with a moved potential file after recovery.
		- No production file is modified by this task.

- [x] [P1-T2] [expect-fail] Add the regression test `test_promote_potential_feature_existing_label_uses_single_issue_create_attempt` to `tests/scripts/dev_tools/test_potential_to_issue.py` before any production-code change.
	- Acceptance:
		- `tests/scripts/dev_tools/test_potential_to_issue.py` contains the exact function definition `def test_promote_potential_feature_existing_label_uses_single_issue_create_attempt() -> None:`.
		- The new test asserts that an already-present `feature` label still uses the normal create path without changing the selected promotion label.
		- No production file is modified by this task.

- [x] [P1-T3] [expect-fail] Run the targeted red coverage command `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q -k "feature_missing_label or existing_label_uses_single_issue_create_attempt" --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` before changing `scripts/dev_tools/potential_to_issue.py` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/regression-testing/p1-t3.red-pytest.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p1-t3.red-pytest.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q -k "feature_missing_label or existing_label_uses_single_issue_create_attempt" --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`.
		- `EXIT_CODE:` is non-zero.
		- The artifact contains `Failure:` text naming `test_promote_potential_feature_missing_label_recovers_and_moves_file`.

- [x] [P1-T4] Apply the minimal production change in `scripts/dev_tools/potential_to_issue.py` so `RealGhClient` reconciles a missing `feature` label and retries issue creation once while preserving the existing-label path.
	- Acceptance:
		- No production Python file outside `scripts/dev_tools/potential_to_issue.py` is modified.
		- `scripts/dev_tools/potential_to_issue.py` contains a `RealGhClient` code path that handles a missing-label create failure for `promotion_type == "feature"` by ensuring the label exists and retrying `issue_create` once.
		- The selected promotion label remains `feature` on the successful create path.

- [x] [P1-T5] Run the targeted green coverage command `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q -k "feature_missing_label or existing_label_uses_single_issue_create_attempt" --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/regression-testing/p1-t5.green-pytest.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p1-t5.green-pytest.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q -k "feature_missing_label or existing_label_uses_single_issue_create_attempt" --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` names both regression tests and includes numeric `Coverage Total:` and `Coverage File: scripts/dev_tools/potential_to_issue.py =` headline values.

- [x] [P1-T6] Write the acceptance-criteria and checkoff expectations artifact `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/other/p1-t6.acceptance-checkoff.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p1-t6.acceptance-checkoff.*.md` exists.
		- The artifact contains `Requirements Source: docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`.
		- The artifact copies the exact three checkbox texts from `issue.md` under `## Acceptance Criteria`.
		- The artifact maps each checkbox text to supporting evidence from `p1-t5.green-pytest.*.md` and the final QC artifact from `[P2-T4]`.
		- The artifact contains the exact sentence `Only issue.md acceptance-criteria checkboxes may be changed from - [ ] to - [x] after supporting evidence exists; preserve the checkbox text exactly.`
		- The artifact contains `Required Absence Confirmed: spec.md absent; user-story.md absent`.

### Phase 2 — Final QC loop

- [x] [P2-T1] Run the final Python format command `poetry run black scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/qa-gates/p2-t1.black.*.md`; if this command changes files or exits non-zero, resume the QC loop from `[P2-T1]` after corrections.
	- Acceptance:
		- Exactly one artifact matching `p2-t1.black.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run black scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states either `formatted` or `already formatted`.

- [x] [P2-T2] Run the final Python lint command `poetry run ruff check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/qa-gates/p2-t2.ruff.*.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections.
	- Acceptance:
		- Exactly one artifact matching `p2-t2.ruff.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run ruff check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states that Ruff passed with no remaining diagnostics.

- [x] [P2-T3] Run the final Python type-check command `poetry run pyright scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/qa-gates/p2-t3.pyright.*.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections.
	- Acceptance:
		- Exactly one artifact matching `p2-t3.pyright.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run pyright scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states that Pyright passed with zero blocking diagnostics.

- [x] [P2-T4] Run the final coverage-enabled pytest command `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` and save the result to `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/qa-gates/p2-t4.pytest-coverage.*.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections.
	- Acceptance:
		- Exactly one artifact matching `p2-t4.pytest-coverage.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` includes numeric `Coverage Total:` and numeric `Coverage File: scripts/dev_tools/potential_to_issue.py =` headline values.

- [x] [P2-T5] Write the clean-pass QC and acceptance summary artifact `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/evidence/qa-gates/p2-t5.clean-pass-summary.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p2-t5.clean-pass-summary.*.md` exists.
		- The artifact cites the exact artifact paths produced by `[P2-T1]`, `[P2-T2]`, `[P2-T3]`, and `[P2-T4]`.
		- The artifact reports final PASS or FAIL status for each of the three acceptance criteria copied from `issue.md`, with a citation to `p1-t5.green-pytest.*.md` and `p2-t4.pytest-coverage.*.md` for each status.
		- The artifact records the baseline coverage values from `[P0-T6]`, the post-change coverage values from `[P2-T4]`, and an explicit coverage disposition.
		- The artifact contains the exact sentence `No Phase 2 command task was skipped.`
		- The artifact contains `Required Absence Confirmed: spec.md absent; user-story.md absent`.
