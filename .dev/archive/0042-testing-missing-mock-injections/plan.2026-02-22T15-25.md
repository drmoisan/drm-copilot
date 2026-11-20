# 2026-02-22-testing-missing-mock-injections (Plan)

- **Issue:** #42
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-22T15-25
- **Status:** Planned
- **Status Color:** blue
- **Version:** 1.0
- **Work Mode:** full

## Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan remediates missing `code_launcher` mock injections in `tests/scripts/dev_tools/test_new_active_feature_folder.py` and adds deterministic test guardrails in `tests/conftest.py` to prevent real VS Code launcher subprocess side effects.

## Requirements and Constraints

### Requirements

- **REQ-001:** Inject `code_launcher=FakeCodeLauncher()` into all 11 identified `mod.create_active_folder(...)` callsites in `tests/scripts/dev_tools/test_new_active_feature_folder.py`.
- **REQ-002:** Add a scoped guard fixture in `tests/conftest.py` that fails when scoped unit tests attempt unmocked launcher subprocess calls (`code`, `code.cmd`, `code.exe`).
- **REQ-003:** Add one deterministic negative regression scenario proving guard fail-before behavior and one green-path scenario proving allowlisted launcher tests remain valid.
- **REQ-004:** Preserve existing launcher-specific behavior tests for `default_code_launcher(...)` that explicitly mock subprocess interactions.
- **REQ-005:** Pass targeted test commands for both module-level and folder-level dev-tools test runs.
- **REQ-006:** Pass the full Python toolchain loop in required order: Black, Ruff, Pyright, Pytest coverage command.

### Security Requirements

- **SEC-001:** Prevent real editor-launch subprocess execution from scoped unit-test modules.

### Constraints

- **CON-001:** Do not modify production files under `scripts/dev_tools/new_active_feature_folder_*.py` for this bugfix.
- **CON-002:** Do not add new runtime or test dependencies.
- **CON-003:** Use TDD sequencing: create failing regression evidence before implementation.
- **CON-004:** Store baseline/regression/QA evidence artifacts under canonical feature-local `evidence/` folders.

## Requirements Traceability

| Requirement ID | Description | Implemented By Tasks | Verification Task |
|---|---|---|---|
| REQ-001 | Inject fake launcher in 11 missing callsites | P3-T1, P3-T2, P3-T3, P3-T4, P3-T5, P3-T6, P3-T7, P3-T8, P3-T9, P3-T10, P3-T11 | P4-T1 |
| REQ-002 | Add scoped subprocess guard fixture | P3-T12 | P4-T2 |
| REQ-003 | Add deterministic fail-before and pass-after guard scenarios | P2-T1, P2-T2, P4-T2 | P4-T2 |
| REQ-004 | Preserve launcher-specific mocked behavior tests | P3-T13 | P4-T3 |
| REQ-005 | Pass targeted dev-tools test commands | P4-T1, P4-T3 | P4-T3 |
| REQ-006 | Pass full Python toolchain loop | P5-T1, P5-T2, P5-T3, P5-T4 | P5-T5 |
| SEC-001 | Block real launcher subprocess side effects | P3-T12 | P4-T2 |
| CON-001 | Keep production behavior unchanged | P3-T14 | P6-T1 |
| CON-002 | No dependency additions | P1-T2 | P6-T1 |
| CON-003 | TDD fail-before before fix | P2-T1, P2-T2 | P2-T2 |
| CON-004 | Canonical evidence paths and schema | P0-T4, P0-T5, P2-T2, P5-T5 | P6-T2 |

### Phase 0 — Context & Inputs

Completion Criteria (machine-verifiable): All referenced policy/spec/research/work-mode inputs are recorded in this plan and baseline evidence files exist under `evidence/baseline/` for formatter, linter, type-check, and test commands, each with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` fields.

- [x] [P0-T1] Read and link authoritative inputs in this order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `docs/features/active/2026-02-22-testing-missing-mock-injections-42/issue.md`, `docs/features/active/2026-02-22-testing-missing-mock-injections-42/spec.md`, `docs/features/templates/user-story.md`, `docs/features/active/2026-02-22-testing-missing-mock-injections-42/research.md`.
	- Acceptance: Plan text includes all ten file paths exactly once in the listed order.
- [x] [P0-T2] Resolve work mode from `docs/features/active/2026-02-22-testing-missing-mock-injections-42/issue.md` metadata line `- Work Mode: full` and record `Work Mode: full` in plan front matter.
	- Acceptance: Plan front matter contains exact line `- **Work Mode:** full`.
- [x] [P0-T3] Record baseline repo state as `Branch: main` and current HEAD commit SHA in `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/baseline/repo-baseline.2026-02-22T15-25.md`.
	- Acceptance: Evidence file contains `Timestamp: 2026-02-22T15-25`, `Command: git rev-parse --abbrev-ref HEAD && git rev-parse HEAD`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P0-T4] Capture baseline targeted test output with command `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q` into `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/baseline/pytest-target-baseline.2026-02-22T15-25.md`.
	- Acceptance: Evidence file contains schema fields plus `Output Summary:` with pass/fail counts.
- [x] [P0-T5] Create canonical evidence directory tree under `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/`: `baseline/`, `regression-testing/`, `qa-gates/`, `other/`, `issue-updates/`.
	- Acceptance: All five folders exist.
- [x] [P0-T6] Capture baseline formatter output with command `poetry run black .` into `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/baseline/black-baseline.2026-02-22T15-25.md`.
	- Acceptance: Evidence file contains `Timestamp`, exact `Command: poetry run black .`, `EXIT_CODE`, and `Output Summary:`.
- [x] [P0-T7] Capture baseline linter output with command `poetry run ruff check` into `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/baseline/ruff-baseline.2026-02-22T15-25.md`.
	- Acceptance: Evidence file contains `Timestamp`, exact `Command: poetry run ruff check`, `EXIT_CODE`, and `Output Summary:`.
- [x] [P0-T8] Capture baseline type-check output with command `poetry run pyright` into `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/baseline/pyright-baseline.2026-02-22T15-25.md`.
	- Acceptance: Evidence file contains `Timestamp`, exact `Command: poetry run pyright`, `EXIT_CODE`, and `Output Summary:`.
- [x] [P0-T9] Capture baseline test coverage output with command `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` into `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/baseline/pytest-cov-baseline.2026-02-22T15-25.md`.
	- Acceptance: Evidence file contains `Timestamp`, exact `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE`, and `Output Summary:`.

### Phase 1 — Preparation

Completion Criteria (machine-verifiable): Scope boundaries and test targets are frozen in plan and no dependency additions are introduced.

No dependency file edits permitted.

- [x] [P1-T1] Freeze in-scope file list to `tests/scripts/dev_tools/test_new_active_feature_folder.py` and `tests/conftest.py` and freeze out-of-scope production files `scripts/dev_tools/new_active_feature_folder_flow.py` and `scripts/dev_tools/new_active_feature_folder_io.py`.
	- Acceptance: Plan contains exact four paths and explicit out-of-scope statement.
- [x] [P1-T2] Confirm no dependency manifest changes are planned in `pyproject.toml`, `poetry.lock`, and `package.json`; ensure full-mode required docs include `docs/features/active/2026-02-22-testing-missing-mock-injections-42/user-story.md` (materialize from `docs/features/templates/user-story.md` if missing).
	- Acceptance: Plan contains explicit statement `No dependency file edits permitted` and `docs/features/active/2026-02-22-testing-missing-mock-injections-42/user-story.md` exists before Phase 2 starts.

### Phase 2 — TDD Red (Regression Fails First)

Completion Criteria (machine-verifiable): Regression guard scenario exists and is proven failing with auditable evidence artifact.

- [x] [P2-T1] [expect-fail] Add regression scenario `test_guard_blocks_unmocked_code_launcher_invocation` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` that intentionally triggers unmocked launcher subprocess invocation from scoped module logic.
	- Depends on: P1-T1.
	- Acceptance: Test function name exists exactly in the file.
- [x] [P2-T2] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q -k guard_blocks_unmocked_code_launcher_invocation` and save failure evidence to `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/regression-testing/guard-fail-before.2026-02-22T15-25.md`.
	- Depends on: P2-T1.
	- Acceptance: Evidence file contains `Timestamp: 2026-02-22T15-25`, exact `Command: poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q -k guard_blocks_unmocked_code_launcher_invocation`, `EXIT_CODE: 1`, `Output Summary:`, and a failure signal string containing `failed`.

### Phase 3 — Minimal Deterministic Fix

Completion Criteria (machine-verifiable): All 11 identified callsites inject `code_launcher=FakeCodeLauncher()`, scoped guard fixture exists, and launcher-specific tests remain intentionally mocked.

- [x] [P3-T1] Update callsite in function `test_create_active_folder_raises_on_invalid_feature_type` (line ~721 in current file) to pass `code_launcher=FakeCodeLauncher()`.
	- Depends on: P2-T2.
	- Acceptance: In that function call argument list, exact token `code_launcher=FakeCodeLauncher()` exists.
- [x] [P3-T2] Update callsite in function `test_create_active_folder_raises_on_missing_template` (line ~734) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T3] Update callsite in function `test_create_active_folder_raises_when_exists_without_force` (line ~866) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T4] Update callsite in function `test_create_active_folder_minor_audit_materializes_issue_md_and_skips_full_docs` (line ~1028) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T5] Update callsite in function `test_work_mode_marker_minor_issue_md` (line ~1064) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T6] Update callsite in function `scenario_single_work_mode_marker_before_first_heading` (line ~1101) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T7] Update callsite in function `test_minor_audit_preserves_issue_frontmatter_and_spacing` (line ~1153) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T8] Update callsite in function `test_create_active_folder_minor_audit_falls_back_to_full_when_not_eligible` (line ~1201) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T9] Update callsite in function `test_work_mode_marker_fallback_issue_md_full` (line ~1239) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T10] Update callsite in function `test_create_active_folder_full_mode_remains_backward_compatible` (line ~1260) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T11] Update callsite in function `test_create_active_folder_fallback_reason_output` (line ~1277) to pass `code_launcher=FakeCodeLauncher()`.
	- Acceptance: Exact token exists at this callsite.
- [x] [P3-T12] Add fixture `guard_unmocked_code_launcher_subprocess` in `tests/conftest.py` scoped to `tests/scripts/dev_tools/test_new_active_feature_folder.py` that fails on unmocked subprocess executable tokens matching `code`, `code.cmd`, `code.exe`.
	- Depends on: P2-T2.
	- Acceptance: Fixture name exists and assertion message includes executable token and test node id.
- [x] [P3-T13] Add allowlist condition in guard fixture for launcher-behavior tests that explicitly mock subprocess in `tests/scripts/dev_tools/test_new_active_feature_folder.py`.
	- Depends on: P3-T12.
	- Acceptance: Guard fixture defines an explicit allowlist collection and includes at least one literal matcher containing `default_code_launcher`.
- [x] [P3-T14] Verify no edits are made to production files `scripts/dev_tools/new_active_feature_folder_flow.py` and `scripts/dev_tools/new_active_feature_folder_io.py`.
	- Acceptance: `git diff --name-only` output excludes both production file paths.

### Phase 4 — Targeted Verification (Green)

Completion Criteria (machine-verifiable): Targeted tests pass, regression now green, and guard logic enforces isolation without false positives.

- [x] [P4-T1] Run `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q` and save result to `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/regression-testing/pytest-target-green.2026-02-22T15-25.md`.
	- Depends on: P3-T1, P3-T2, P3-T3, P3-T4, P3-T5, P3-T6, P3-T7, P3-T8, P3-T9, P3-T10, P3-T11, P3-T12, P3-T13.
	- Acceptance: Evidence file contains exact command and `EXIT_CODE: 0`.
- [x] [P4-T2] Run `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q -k "guard_blocks_unmocked_code_launcher_invocation or default_code_launcher"` and save result to `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/regression-testing/guard-and-launcher-verification.2026-02-22T15-25.md`.
	- Depends on: P4-T1.
	- Acceptance: Evidence file contains exact command and `EXIT_CODE: 0`.
- [x] [P4-T3] Run `poetry run pytest tests/scripts/dev_tools -q` and save result to `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/regression-testing/pytest-dev-tools-green.2026-02-22T15-25.md`.
	- Depends on: P4-T2.
	- Acceptance: Evidence file contains exact command and `EXIT_CODE: 0`.

### Phase 5 — Full Python QA Gate Loop

Completion Criteria (machine-verifiable): A single clean pass of full toolchain loop is recorded in order with all exit codes equal to 0.

- [x] [P5-T1] Run formatter command `poetry run black .` and save output to `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/qa-gates/black.2026-02-22T15-25.md`.
	- Depends on: P4-T3.
	- Acceptance: Evidence file contains exact command and `EXIT_CODE: 0`.
- [x] [P5-T2] Run linter command `poetry run ruff check` and save output to `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/qa-gates/ruff.2026-02-22T15-25.md`.
	- Depends on: P5-T1.
	- Acceptance: Evidence file contains exact command and `EXIT_CODE: 0`.
- [x] [P5-T3] Run type checker command `poetry run pyright` and save output to `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/qa-gates/pyright.2026-02-22T15-25.md`.
	- Depends on: P5-T2.
	- Acceptance: Evidence file contains exact command and `EXIT_CODE: 0`.
- [x] [P5-T4] Run test command `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and save output to `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/qa-gates/pytest-cov.2026-02-22T15-25.md`.
	- Depends on: P5-T3.
	- Acceptance: Evidence file contains exact command and `EXIT_CODE: 0`.
- [x] [P5-T5] Record final QA loop summary in `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/qa-gates/qa-loop-summary.2026-02-22T15-25.md` with ordered command list and pass status.
	- Depends on: P5-T1, P5-T2, P5-T3, P5-T4.
	- Acceptance: Summary file contains all four commands in order and statement `Final Loop Result: PASS`.

### Phase 6 — Documentation and Handoff

Completion Criteria (machine-verifiable): Feature docs are synchronized to implemented behavior and evidence links are recorded for autonomous audit.

- [x] [P6-T1] Update `docs/features/active/2026-02-22-testing-missing-mock-injections-42/spec.md` acceptance criteria status notes to reference completed evidence files from phases 4 and 5.
	- Depends on: P5-T5.
	- Acceptance: `spec.md` contains explicit references to `pytest-target-green.2026-02-22T15-25.md` and `qa-loop-summary.2026-02-22T15-25.md`.
- [x] [P6-T2] Update `docs/features/active/2026-02-22-testing-missing-mock-injections-42/issue.md` with resolution summary and evidence index at `evidence/regression-testing/` and `evidence/qa-gates/`.
	- Depends on: P6-T1.
	- Acceptance: `issue.md` includes section `Resolution Evidence` containing both folder paths.
- [x] [P6-T3] Prepare final execution handoff note in `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/other/execution-handoff.2026-02-22T15-25.md` listing completed task IDs and unresolved risks.
	- Depends on: P6-T2.
	- Acceptance: Handoff file contains `Completed Task IDs:` and `Open Risks:` headings.
- [x] [P6-T4] Update `docs/features/active/2026-02-22-testing-missing-mock-injections-42/user-story.md` with validation outcome summary and links to targeted regression and QA evidence artifacts.
	- Depends on: P6-T3.
	- Acceptance: `user-story.md` contains explicit references to `guard-and-launcher-verification.2026-02-22T15-25.md` and `qa-loop-summary.2026-02-22T15-25.md`.
