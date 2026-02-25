---
issue: 43
parent: none
owner: drmoisan
last_updated: 2026-02-22T14-53
status: Planned
status_color: blue
version: 0.1
work_mode: full
---

# 2026-02-22-create-active-folder-bug (Plan)

![Status: Planned](https://img.shields.io/badge/Status-Planned-blue)

- **Issue:** #43
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-22T14-53
- **Status:** Planned
- **Version:** 0.1
- **Work Mode:** full

## Deterministic Scope

- Target feature folder: `docs/features/active/2026-02-22-create-active-folder-bug-43`
- Canonical spec input: `docs/features/active/2026-02-22-create-active-folder-bug-43/spec.md`
- Canonical user-story input: `docs/features/active/2026-02-22-create-active-folder-bug-43/user-story.md`
- Canonical research input: `docs/features/active/2026-02-22-create-active-folder-bug-43/research.md`
- Code paths in scope:
	- `.vscode/tasks.json`
	- `scripts/dev_tools/new_active_feature_folder_flow.py`
	- `scripts/dev_tools/new_active_feature_folder.py`
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py`

## Requirements and Constraints

| ID | Type | Deterministic Statement |
| --- | --- | --- |
| REQ-1 | Functional | Explicit `full` mode must persist exactly one `- Work Mode: full` marker in moved `issue.md`, inserted above the first `##` heading. |
| REQ-2 | Functional | Add auto-resolve CLI option for active-file path that derives feature name from filename stem when path is under `docs/features/potential/promoted` and extension is `.md`. |
| REQ-3 | Functional | Add VS Code task `Dev: 3 Auto Create Folder` that passes active file path to the auto-resolve option. |
| REQ-4 | Functional | Invalid auto-resolve input must produce deterministic actionable error: select promoted markdown in canonical folder or provide feature name directly. |
| REQ-5 | Quality | Existing manual task `Dev: 3 Create Active Folder` remains backward compatible without behavior regression. |
| REQ-6 | Quality | Existing minor-audit routing and fallback behavior remain unchanged. |
| SEC-1 | Safety | Auto-resolve validation must reject paths outside workspace canonical promoted folder and reject non-`.md` extensions. |
| CON-1 | Process | TDD order is mandatory: failing regression evidence must be captured before production-code edits. |
| CON-2 | Process | Final QA loop must pass in one clean pass: format → lint → type-check → test for changed Python scope, plus JSON format/validate for `.vscode/tasks.json`. |

## Requirements Traceability

| Requirement ID | Implemented By Tasks |
| --- | --- |
| REQ-1 | P3-T1, P3-T2, P4-T3 |
| REQ-2 | P2-T1, P3-T3, P4-T4 |
| REQ-3 | P3-T5, P4-T5 |
| REQ-4 | P2-T2, P3-T4, P4-T6 |
| REQ-5 | P2-T3, P4-T7 |
| REQ-6 | P2-T4, P4-T8 |
| SEC-1 | P2-T2, P3-T4, P4-T6 |
| CON-1 | P2-T1, P2-T2, P2-T3, P2-T4 |
| CON-2 | P5-T1, P5-T2, P5-T3, P5-T4 |

### Phase 0 — Context and Baseline Capture

Completion Criteria: policy-read evidence and baseline command artifacts exist with required schema fields under canonical evidence paths.

- [x] [P0-T1] Record policy-read evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/baseline/policy-read.2026-02-22T14-53.md`.
	- Dependencies: none.
	- Acceptance: file exists and contains exact lines `Timestamp: 2026-02-22T14-53`, `Command: policy-read`, and `EXIT_CODE: 0`; file lists `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`.

- [x] [P0-T2] Capture baseline JSON format check evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/baseline/json-format.2026-02-22T14-53.md`.
	- Dependencies: none.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run python -m scripts.dev_tools.format_json`, `EXIT_CODE`, and `Output Summary` fields.

- [x] [P0-T3] Capture baseline JSON schema validation evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/baseline/json-validate.2026-02-22T14-53.md`.
	- Dependencies: none.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run python -m scripts.dev_tools.validate_json`, `EXIT_CODE`, and `Output Summary` fields.

- [x] [P0-T4] Capture baseline Python formatter evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/baseline/black.2026-02-22T14-53.md`.
	- Dependencies: none.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run black .`, `EXIT_CODE`, and `Output Summary` fields.

- [x] [P0-T5] Capture baseline Python lint evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/baseline/ruff.2026-02-22T14-53.md`.
	- Dependencies: none.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run ruff check`, `EXIT_CODE`, and `Output Summary` fields.

- [x] [P0-T6] Capture baseline Python type-check evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/baseline/pyright.2026-02-22T14-53.md`.
	- Dependencies: none.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run pyright`, `EXIT_CODE`, and `Output Summary` fields.

- [x] [P0-T7] Capture baseline Python test evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/baseline/pytest.2026-02-22T14-53.md`.
	- Dependencies: none.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE`, and `Output Summary` fields.

- [x] [P0-T8] Capture full-mode document precondition evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/baseline/full-doc-preconditions.2026-02-22T14-53.md`.
	- Dependencies: none.
	- Acceptance: artifact contains `Timestamp`, `Command: full-doc-check`, `EXIT_CODE: 0`, and exact lines `SpecExists: true` and `UserStoryExists: true`.

### Phase 1 — Deterministic Design Lock

Completion Criteria: implementation contract is frozen with exact option names, exact error text, and explicit file-level touch map.

- [x] [P1-T1] Define auto-resolve CLI option contract in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/other/auto-resolve-contract.2026-02-22T14-53.md`.
	- Dependencies: P0-T1.
	- Acceptance: artifact specifies exact option name `--active-file-for-feature-name`, accepted value type `str`, and derived output rule `Path(active_file).stem`.

- [x] [P1-T2] Define deterministic invalid-input error message in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/other/auto-resolve-error-contract.2026-02-22T14-53.md`.
	- Dependencies: P1-T1.
	- Acceptance: artifact contains exact string `Select a promoted issue markdown file under docs/features/potential/promoted or supply --feature-name directly.`.

- [x] [P1-T3] Define exact file edit map in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/other/edit-map.2026-02-22T14-53.md`.
	- Dependencies: P1-T1.
	- Acceptance: artifact lists only four files: `.vscode/tasks.json`, `scripts/dev_tools/new_active_feature_folder_flow.py`, `scripts/dev_tools/new_active_feature_folder.py`, `tests/scripts/dev_tools/test_new_active_feature_folder.py`.

### Phase 2 — TDD Red Regression Tasks

Completion Criteria: four regression scenarios are added and verified failing with auditable expect-fail evidence artifacts.

- [x] [P2-T1] [expect-fail] Add pytest scenario `test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` covering REQ-2.
	- Dependencies: P1-T1.
	- Acceptance: running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k auto_resolve_feature_name_from_promoted_active_file` fails; evidence file `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/expect-fail-auto-resolve-valid.2026-02-22T14-53.md` exists with `Timestamp`, `Command`, `EXIT_CODE` and non-zero exit code.

- [x] [P2-T2] [expect-fail] Add pytest scenario `test_create_active_folder_auto_resolve_rejects_non_promoted_or_non_markdown_active_file` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` covering REQ-4 and SEC-1.
	- Dependencies: P1-T2.
	- Acceptance: running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k auto_resolve_rejects_non_promoted_or_non_markdown_active_file` fails; evidence file `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/expect-fail-auto-resolve-invalid.2026-02-22T14-53.md` exists with `Timestamp`, `Command`, `EXIT_CODE` and non-zero exit code.

- [x] [P2-T3] [expect-fail] Add pytest scenario `test_create_active_folder_full_mode_persists_full_marker_in_issue_md` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` covering REQ-1.
	- Dependencies: P1-T3.
	- Acceptance: running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k full_mode_persists_full_marker_in_issue_md` fails; evidence file `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/expect-fail-full-marker.2026-02-22T14-53.md` exists with `Timestamp`, `Command`, `EXIT_CODE` and non-zero exit code.

- [x] [P2-T4] [expect-fail] Add pytest scenario `test_create_active_folder_minor_audit_behavior_unchanged_with_auto_resolve_option_absent` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` covering REQ-6.
	- Dependencies: P1-T3.
	- Acceptance: running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k minor_audit_behavior_unchanged_with_auto_resolve_option_absent` fails; evidence file `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/expect-fail-minor-compat.2026-02-22T14-53.md` exists with `Timestamp`, `Command`, `EXIT_CODE` and non-zero exit code.

### Phase 3 — Minimal Implementation (Green)

Completion Criteria: production changes are minimal, each regression scenario transitions from fail to pass, and no out-of-scope file is modified.

- [x] [P3-T1] Implement full-marker persistence in `scripts/dev_tools/new_active_feature_folder_flow.py` inside `create_active_folder` non-minor potential move path.
	- Dependencies: P2-T3.
	- Acceptance: code path writes `upsert_work_mode_marker(moved_content, "full")` whenever selected mode is full; task-specific test `-k full_mode_persists_full_marker_in_issue_md` passes with exit code 0.

- [x] [P3-T2] Enforce single-marker invariant for full-mode moved issue content in `scripts/dev_tools/new_active_feature_folder_flow.py` by reusing existing `upsert_work_mode_marker` helper.
	- Dependencies: P3-T1.
	- Acceptance: `test_create_active_folder_full_mode_persists_full_marker_in_issue_md` asserts exactly one marker line and passes.

- [x] [P3-T3] Add auto-resolve option parsing in `scripts/dev_tools/new_active_feature_folder_flow.py::parse_args` and thread the option through `main()` into `create_active_folder`.
	- Dependencies: P2-T1.
	- Acceptance: parser accepts `--active-file-for-feature-name`; command `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k auto_resolve_feature_name_from_promoted_active_file` exits 0; command `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k parse_args` exits 0.

- [x] [P3-T4] Implement canonical path and extension validation for auto-resolve in `scripts/dev_tools/new_active_feature_folder_flow.py::create_active_folder`.
	- Dependencies: P3-T3, P2-T2.
	- Acceptance: invalid input raises deterministic error exactly matching P1-T2 contract; invalid-case test passes.

- [x] [P3-T5] Add VS Code task `Dev: 3 Auto Create Folder` in `.vscode/tasks.json` using command `poetry run python -m scripts.dev_tools.new_active_feature_folder --active-file-for-feature-name ${file} --type ${input:ActiveWorkType} --issue-number ${input:ActiveIssueNumber} --work-mode ${input:ActiveWorkMode}`.
	- Dependencies: P3-T3.
	- Acceptance: `.vscode/tasks.json` contains one new task label `Dev: 3 Auto Create Folder`; existing `Dev: 3 Create Active Folder` task remains unchanged.

- [x] [P3-T6] Update re-export surface in `scripts/dev_tools/new_active_feature_folder.py` only if new public helper symbol is introduced by implementation.
	- Dependencies: P3-T3.
	- Acceptance: `__all__` remains accurate with no unresolved symbol import errors under `poetry run pyright`.

### Phase 4 — Targeted Verification

Completion Criteria: all new scenario tests pass and targeted behavior checks have dedicated evidence artifacts.

- [x] [P4-T1] Run targeted pytest for valid auto-resolve scenario and store evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-auto-resolve-valid.2026-02-22T14-53.md`.
	- Dependencies: P3-T3.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k auto_resolve_feature_name_from_promoted_active_file`, `EXIT_CODE: 0`.

- [x] [P4-T2] Run targeted pytest for invalid auto-resolve scenario and store evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-auto-resolve-invalid.2026-02-22T14-53.md`.
	- Dependencies: P3-T4.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k auto_resolve_rejects_non_promoted_or_non_markdown_active_file`, `EXIT_CODE: 0`.

- [x] [P4-T3] Run targeted pytest for full-marker persistence scenario and store evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-full-marker.2026-02-22T14-53.md`.
	- Dependencies: P3-T2.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k full_mode_persists_full_marker_in_issue_md`, `EXIT_CODE: 0`.

- [x] [P4-T4] Run targeted pytest for minor-audit compatibility scenario and store evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-minor-compat.2026-02-22T14-53.md`.
	- Dependencies: P3-T4.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k minor_audit_behavior_unchanged_with_auto_resolve_option_absent`, `EXIT_CODE: 0`.

- [x] [P4-T5] Validate task wiring by checking `.vscode/tasks.json` contains exact task label and argument token `${file}` for auto task.
	- Dependencies: P3-T5.
	- Acceptance: `poetry run python -m scripts.dev_tools.validate_json` exits 0 and search evidence file `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/other/task-wiring-check.2026-02-22T14-53.md` contains exact substrings `"label": "Dev: 3 Auto Create Folder"` and `"${file}"`.

- [x] [P4-T6] Verify deterministic invalid-input guidance string exactness and store evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/other/invalid-guidance-check.2026-02-22T14-53.md`.
	- Dependencies: P3-T4.
	- Acceptance: artifact includes exact emitted error line `Select a promoted issue markdown file under docs/features/potential/promoted or supply --feature-name directly.`.

- [x] [P4-T7] Verify manual flow backward compatibility by running existing manual-path test subset and store evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-manual-compat.2026-02-22T14-53.md`.
	- Dependencies: P3-T5.
	- Acceptance: command `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k full_mode_remains_backward_compatible` exits 0 and artifact schema fields are present.

- [x] [P4-T8] Verify minor-audit fallback behavior remains unchanged using existing fallback test subset and store evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-minor-fallback-compat.2026-02-22T14-53.md`.
	- Dependencies: P3-T4.
	- Acceptance: command `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k fallback_reason_output` exits 0 and artifact schema fields are present.

### Phase 5 — Final QA Toolchain Loop

Completion Criteria: one clean end-to-end pass recorded where each command exits 0 and no formatter-induced file changes require restart.

- [x] [P5-T1] Run JSON formatter and record final-gate evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/qa-gates/json-format-final.2026-02-22T14-53.md`.
	- Dependencies: P4-T5.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run python -m scripts.dev_tools.format_json`, `EXIT_CODE: 0`.

- [x] [P5-T2] Run JSON validation and record final-gate evidence in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/qa-gates/json-validate-final.2026-02-22T14-53.md`.
	- Dependencies: P5-T1.
	- Acceptance: artifact contains `Timestamp`, `Command: poetry run python -m scripts.dev_tools.validate_json`, `EXIT_CODE: 0`.

- [x] [P5-T3] Run Python final loop command set and record evidence in four artifacts under `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/qa-gates/`.
	- Dependencies: P4-T1, P4-T2, P4-T3, P4-T4, P4-T7, P4-T8.
	- Acceptance: files `black-final.2026-02-22T14-53.md`, `ruff-final.2026-02-22T14-53.md`, `pyright-final.2026-02-22T14-53.md`, `pytest-final.2026-02-22T14-53.md` exist under `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/qa-gates/`; artifacts include exact commands `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`; each has `EXIT_CODE: 0`.

- [x] [P5-T4] Verify final clean-pass completeness in `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/qa-gates/final-pass-summary.2026-02-22T14-53.md`.
	- Dependencies: P5-T1, P5-T2, P5-T3.
	- Acceptance: summary file lists each final gate artifact path and includes `AllFinalGatesPassed: true`.

### Phase 6 — Documentation and Handoff

Completion Criteria: feature docs are synchronized to delivered behavior and handoff summary is complete with evidence links.

- [x] [P6-T1] Update `docs/features/active/2026-02-22-create-active-folder-bug-43/spec.md` acceptance evidence lines with concrete test names and QA artifact references.
	- Dependencies: P5-T4.
	- Acceptance: `spec.md` Acceptance Criteria section references all three new regression test names and at least one final QA artifact path.

- [x] [P6-T2] Update `docs/features/active/2026-02-22-create-active-folder-bug-43/issue.md` with concise implementation outcome summary.
	- Dependencies: P5-T4.
	- Acceptance: `issue.md` includes a delivered-behavior note for auto task, full marker persistence, and invalid-input guidance string.

- [x] [P6-T3] Add execution handoff artifact `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/other/handoff-summary.2026-02-22T14-53.md`.
	- Dependencies: P6-T1, P6-T2.
	- Acceptance: artifact includes sections `Implemented Files`, `Tests Added`, `Final QA Commands`, and `Known Follow-ups`; all listed paths exist.
