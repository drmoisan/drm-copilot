---
title: "2026-04-04-potential-entry-opening-different-ide"
issue: 116
owner: "drmoisan"
work_mode: "minor-audit"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-04T11-48"
source_of_truth: "docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md"
plan_path: "docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/plan.2026-04-04T11-48.md"
---

# 2026-04-04-potential-entry-opening-different-ide (Plan)

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

## Overview

This plan updates the Python-backed VS Code launchers used by the potential-bug and active-feature-folder workflows so they reuse the current IDE window on Windows, matching the existing PowerShell-backed feature-entry workflow. The plan is constrained to `minor-audit` mode and uses `issue.md` as the only requirements source.

## Deterministic Inputs

- Sole requirements source: `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md`
- Acceptance criteria source: `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md#acceptance-criteria`
- Ignored by plan logic: `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/spec.md`, `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/user-story.md`, `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/research.md`
- Target implementation files:
	- `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`
	- `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`
	- `scripts/dev_tools/new_potential_bug_entry.py`
	- `scripts/dev_tools/new_active_feature_folder_io.py`
- Target regression test files:
	- `tests/scripts/dev_tools/test_new_potential_bug_entry.py`
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py`

## Deterministic Constraints

- `CON-001`: Use `issue.md` only; do not require or cite `spec.md`, `user-story.md`, or `research.md`.
- `CON-002`: Keep exactly three phases in this order: baseline capture, small-path handoff, final QC loop.
- `CON-003`: Limit production-code scope to the four Python launcher files listed above unless the implementation agent records a blocker requiring one additional helper file.
- `CON-004`: Use explicit red-then-green TDD in Phase 1: add or update deterministic regression tests before changing launcher logic, record the failing red run, then implement the fix and record the passing green run.
- `CON-005`: Store baseline evidence under `evidence/baseline/`, targeted verification evidence under `evidence/regression-testing/` or `evidence/other/`, and final QC evidence under `evidence/qa-gates/`.
- `CON-006`: Every command artifact named in this plan must include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- `CON-007`: If any Phase 2 command changes files or fails, rerun Phase 2 from `P2-T1` after correcting the cause.
- `SEC-001`: Do not introduce any new file-opening mechanism outside the existing Python launcher paths; adjust only CLI selection and arguments for the existing launchers.

## Small-Path Directive

`DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`

## Evidence Naming Rules

- Use ISO-8601 timestamps in filenames with the format `yyyy-MM-ddTHH-mm`.
- Use filename patterns exactly as specified in each task.
- When a task requires an artifact pattern ending in `.*.md`, the `*` position must be replaced with one ISO-8601 timestamp.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the mandatory policy files in repository order and write `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/baseline/phase0-instructions-read.md`.
	- Files to read, in order:
		- `.github/copilot-instructions.md`
		- `.github/instructions/general-code-change.instructions.md`
		- `.github/instructions/general-unit-test.instructions.md`
		- `.github/instructions/python-code-change.instructions.md`
		- `.github/instructions/python-unit-test.instructions.md`
		- `.github/instructions/python-suppressions.instructions.md`
		- `.github/instructions/self-explanatory-code-commenting.instructions.md`
	- Acceptance:
		- The artifact exists at the exact path above.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Policy Order:`.
		- The artifact contains the exact list of files read, including `.github/instructions/self-explanatory-code-commenting.instructions.md`.

- [x] [P0-T2] Verify the minor-audit requirements scope and write `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/baseline/p0-t2.requirements-scope.*.md`.
	- The artifact must confirm all of the following:
		- `Work Mode: minor-audit` is present in `issue.md`.
		- `issue.md` contains an explicit `## Acceptance Criteria` section.
		- `issue.md` is the only requirements source used by this plan.
		- `spec.md` and `user-story.md` are not required inputs for this plan.
		- `research.md` is present in the folder but ignored by this plan.
	- Acceptance:
		- Exactly one artifact matching `p0-t2.requirements-scope.*.md` exists.
		- The artifact includes the five confirmations listed above verbatim or with exact file-path references.

- [x] [P0-T3] Capture branch and commit baseline in `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/baseline/p0-t3.git-baseline.*.md` using the exact PowerShell command `git rev-parse --abbrev-ref HEAD; git rev-parse HEAD`.
	- Acceptance:
		- Exactly one artifact matching `p0-t3.git-baseline.*.md` exists.
		- The artifact contains `Command: git rev-parse --abbrev-ref HEAD; git rev-parse HEAD`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` includes the current branch name and commit SHA.

- [x] [P0-T4] Capture the baseline formatting state in `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/baseline/p0-t4.black-check.*.md` using the exact command `poetry run black .`.
	- Acceptance:
		- Exactly one artifact matching `p0-t4.black-check.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` states whether the repo-wide Black run reported files requiring reformatting.

- [x] [P0-T5] Capture the baseline lint state in `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/baseline/p0-t5.ruff-check.*.md` using the exact command `poetry run ruff check`.
	- Acceptance:
		- Exactly one artifact matching `p0-t5.ruff-check.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` lists pass status or the first failing Ruff rule.

- [x] [P0-T6] Capture the baseline type-check state in `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/baseline/p0-t6.pyright.*.md` using the exact command `poetry run pyright`.
	- Acceptance:
		- Exactly one artifact matching `p0-t6.pyright.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` reports either zero diagnostics or the first blocking Pyright diagnostic.

- [x] [P0-T7] Capture the baseline regression-and-coverage state in `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/baseline/p0-t7.pytest-coverage.*.md` using the exact command `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
	- Acceptance:
		- Exactly one artifact matching `p0-t7.pytest-coverage.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` includes numeric coverage headline values for the repo-standard coverage run.

### Phase 1 — Constrained small-path implementation

- [x] [P1-T1] [expect-fail] Add or update the constrained regression scenarios in the two listed pytest modules, run the targeted pytest command before launcher code changes, and write `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/regression-testing/p1-t1.red-pytest.*.md`.
	- Add or update these exact regression scenarios before launcher code changes:
		- `tests/scripts/dev_tools/test_new_potential_bug_entry.py`: normal VS Code CLI resolution, Insiders-aware CLI resolution, inclusion of `--reuse-window`, and graceful fallback when no CLI executable is available.
		- `tests/scripts/dev_tools/test_new_active_feature_folder.py`: normal VS Code CLI resolution, Insiders-aware CLI resolution, inclusion of `--reuse-window`, and graceful fallback when no CLI executable is available.
	- Use the exact red-run command `poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder.py -q` before any launcher code changes.
	- Acceptance:
		- Exactly one artifact matching `p1-t1.red-pytest.*.md` exists.
		- The artifact contains `Command: poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder.py -q`.
		- `EXIT_CODE:` is non-zero.
		- `Output Summary:` names the failing scenario set and both pytest modules.

- [x] [P1-T2] Implement the constrained small-path change after `P1-T1` using `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md` as the only requirements source, keep code changes limited to the four launcher files plus the two listed pytest modules unless one additional helper file is justified in `P1-T3`, and write `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/regression-testing/p1-t2.targeted-pytest.*.md` using the exact command `poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder.py -q`.
	- Implement these exact outcomes:
		- Update `default_code_launcher` in `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`.
		- Update `default_code_launcher` in `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`.
		- Keep `scripts/dev_tools/new_potential_bug_entry.py` behaviorally aligned with the bundled launcher.
		- Keep `scripts/dev_tools/new_active_feature_folder_io.py` behaviorally aligned with the bundled launcher.
	- Acceptance:
		- The implementation changes are limited to the four listed launcher files and two listed pytest modules, or one additional helper file is explicitly justified in `P1-T3`.
		- The changed files are the exact files reported in `P1-T3`.
		- Exactly one artifact matching `p1-t2.targeted-pytest.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` names both pytest modules and includes the final passed-test count.

- [x] [P1-T3] Write the implementation-plus-Windows-verification summary artifact `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/other/p1-t3.implementation-summary.*.md`.
	- The artifact must list:
		- each modified file,
		- which issue acceptance criterion each file supports,
		- whether `code-insiders` preference logic was added or updated,
		- whether `--reuse-window` is present in both affected launcher paths,
		- the evidence used to evaluate issue acceptance criterion 1,
		- the evidence used to evaluate issue acceptance criterion 2,
		- whether each workflow reused the originating VS Code or VS Code Insiders window,
		- the control-path comparison against `drmCopilotExtension.newPotentialEntry`,
		- if deterministic live Windows verification cannot be executed, an explicit `UNVERIFIED` / `remediation required` status for acceptance criteria 1 and 2 instead of a pass claim.
	- Acceptance:
		- Exactly one artifact matching `p1-t3.implementation-summary.*.md` exists.
		- The artifact includes a dedicated verification-status section for issue acceptance criteria 1 and 2.
		- The artifact does not mark either workflow acceptance criterion as passed without explicit live-verification evidence.
		- The artifact includes all nine required lists or confirmations.

### Phase 2 — Final QC loop

- [x] [P2-T1] Run the final formatting pass and write `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t1.black.*.md` using the exact command `poetry run black .`.
	- Acceptance:
		- Exactly one artifact matching `p2-t1.black.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states either `formatted` or `already formatted` for the repo-wide Black run.

- [x] [P2-T2] Run the final lint pass and write `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t2.ruff.*.md` using the exact command `poetry run ruff check`.
	- Acceptance:
		- Exactly one artifact matching `p2-t2.ruff.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states that Ruff passed with no remaining diagnostics.

- [x] [P2-T3] Run the final type-check pass and write `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t3.pyright.*.md` using the exact command `poetry run pyright`.
	- Acceptance:
		- Exactly one artifact matching `p2-t3.pyright.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states that Pyright passed with zero blocking diagnostics.

- [x] [P2-T4] Run the final coverage-enabled pytest pass and write `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t4.pytest-coverage.*.md` using the exact command `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
	- Acceptance:
		- Exactly one artifact matching `p2-t4.pytest-coverage.*.md` exists.
		- The artifact contains the exact `Command:` line above.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` includes numeric post-change coverage headline values from the repo-standard coverage run.

- [x] [P2-T5] Write the end-state summary artifact `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/evidence/qa-gates/p2-t5.end-state-summary.*.md`.
	- The artifact must include:
		- the artifact paths produced by `P2-T1` through `P2-T4`,
		- the final PASS/FAIL/UNVERIFIED status for each of the three issue acceptance criteria, with a citation to the supporting evidence artifact for each status,
		- the numeric coverage values reported by `P2-T4`,
		- the baseline coverage value from `P0-T7`, the post-change coverage value from `P2-T4`, and an explicit coverage disposition stating whether coverage regressed and whether changed/new-code coverage obligations were satisfied; if changed/new-code coverage cannot be determined deterministically from the recorded evidence, the artifact must state `remediation required` rather than reporting a pass,
		- for issue acceptance criteria 1 and 2, cite the live Windows verification section from `P1-T3`; if that evidence is absent, the artifact must report `UNVERIFIED` and `remediation required`, not `PASS`,
		- a statement that Phase 2 was rerun from `P2-T1` if any earlier Phase 2 command changed files or failed.
	- Acceptance:
		- Exactly one artifact matching `p2-t5.end-state-summary.*.md` exists.
		- The artifact contains all six required sections listed above.
		- The artifact does not report `PASS` for issue acceptance criterion 1 or 2 unless it cites explicit live Windows verification evidence from `P1-T3`.
		- The artifact explicitly reports the final coverage disposition by comparing `P0-T7` and `P2-T4`, and it records `remediation required` if changed/new-code coverage cannot be determined from the available evidence.
