---
issue: 28
parent: none
owner: drmoisan
last_updated: 2026-02-20T21-30
status: Planned
status_color: blue
version: 0.2
---

# Remediation Plan: 2026-02-19-minor-audit-small-change-28 (2026-02-20T21-30)

## Introduction

![Status: Planned](https://img.shields.io/badge/Status-Planned-blue)

This remediation plan resolves the minor-audit-small-change-28 findings by fixing Windows pytest collection, aligning docstring/comment policy, conforming S603 suppressions, eliminating temporary filesystem usage in tests, adding explicit minor-audit policy language, and capturing targeted verification evidence.

## Required References

- Copilot Instructions: [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Python Suppressions Policy: [`.github/instructions/python-suppressions.instructions.md`](../../../../.github/instructions/python-suppressions.instructions.md)
- Docstring/Commenting Policy: [`.github/instructions/self-explanatory-code-commenting.instructions.md`](../../../../.github/instructions/self-explanatory-code-commenting.instructions.md)
- Remediation inputs: [`docs/features/active/2026-02-19-minor-audit-small-change-28/remediation-inputs.2026-02-20T21-30.md`](./remediation-inputs.2026-02-20T21-30.md)
- Feature spec: [`docs/features/active/2026-02-19-minor-audit-small-change-28/spec.md`](./spec.md)
- Research: [`docs/features/active/2026-02-19-minor-audit-small-change-28/research.md`](./research.md)

## Requirements Traceability

| ID | Type | Requirement |
| --- | --- | --- |
| REQ-001 | Functional | Ensure pytest collection succeeds on Windows by adding repo root to `sys.path` during test collection. |
| REQ-002 | Quality | Add intent-first docstrings and loop/branch intent comments for required Python files (`scripts/dev_tools/potential_to_issue.py`, `scripts/dev_tools/new_active_feature_folder.py`, `tests/scripts/dev_tools/test_potential_to_issue.py`, `tests/scripts/dev_tools/test_new_active_feature_folder.py`). |
| REQ-003 | Quality | Align S603 suppressions with pre-authorized comment format for validated executables. |
| REQ-004 | Quality | Remove all temporary filesystem usage (`tmp_path`) from `tests/scripts/dev_tools/test_potential_to_issue.py`. |
| REQ-005 | Documentation | Add explicit minor-audit policy statement that broad regression and extended design docs are not required by default. |
| REQ-006 | Evidence | Capture targeted verification evidence artifact with required schema under `evidence/other/`. |
| SEC-001 | Security | Preserve validated executable resolution via `shutil.which()` and use only pre-authorized S603 suppression format. |
| CON-001 | Constraint | Do not add new runtime or test dependencies. |
| CON-002 | Constraint | Do not introduce non-pre-authorized suppressions. |
| CON-003 | Constraint | Do not create or use temporary files in tests. |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline Capture

- [ ] [P0-T1] Record policy-read evidence in `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/policy-read.2026-02-20T21-30.md` after reading required policies in the mandated order
  - Acceptance: Evidence file contains `Timestamp: 2026-02-20T21-30`, `Command: policy-read`, `EXIT_CODE: 0`, `Output Summary: policy files reviewed in required order`, and the ordered list `1) .github/copilot-instructions.md`, `2) .github/instructions/general-code-change.instructions.md`, `3) .github/instructions/general-unit-test.instructions.md`, `4) .github/instructions/python-code-change.instructions.md`, `5) .github/instructions/python-unit-test.instructions.md`, `6) .github/instructions/python-suppressions.instructions.md`, `7) .github/instructions/self-explanatory-code-commenting.instructions.md`.
- [ ] [P0-T2] Capture Python formatter baseline by running `poetry run black . --check` and writing output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/python-format-baseline.2026-02-20T21-30.md`
  - Acceptance: Evidence file includes `Timestamp`, `Command: poetry run black . --check`, `EXIT_CODE`, and `Output Summary`.
- [ ] [P0-T3] Capture Python lint baseline by running `poetry run ruff check` and writing output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/python-lint-baseline.2026-02-20T21-30.md`
  - Acceptance: Evidence file includes `Timestamp`, `Command: poetry run ruff check`, `EXIT_CODE`, and `Output Summary`.
- [ ] [P0-T4] Capture Python type baseline by running `poetry run pyright` and writing output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/python-type-baseline.2026-02-20T21-30.md`
  - Acceptance: Evidence file includes `Timestamp`, `Command: poetry run pyright`, `EXIT_CODE`, and `Output Summary`.
- [ ] [P0-T5] Capture Python test baseline by running `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and writing output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/python-test-baseline.2026-02-20T21-30.md`
  - Acceptance: Evidence file includes `Timestamp`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE`, and `Output Summary`.
- [ ] [P0-T6] Sync original plan checklist status in `docs/features/active/2026-02-19-minor-audit-small-change-28/plan.2026-02-19T12-02.md` by checking off any delivered items and recording the update in the plan
  - Acceptance: `plan.2026-02-19T12-02.md` reflects current delivered items and notes the sync in the plan text.

### Phase 1 — TDD Red: Pytest Collection Regression

- [ ] [P1-T1] [expect-fail] Add `tests/test_pytest_collection.py` with test `test_repo_root_on_sys_path_allows_scripts_import` that imports `scripts.dev_tools.potential_to_issue` and asserts the repo root is present in `sys.path`
  - Preconditions: File does not exist and will be created as a new test module.
  - Acceptance: Running `poetry run pytest tests/test_pytest_collection.py -k repo_root_on_sys_path_allows_scripts_import` fails with `ModuleNotFoundError: No module named 'scripts'` and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/regression-testing/p1-t1.expect-fail.2026-02-20T21-30.md` containing `Timestamp`, exact `Command`, non-zero `EXIT_CODE`, and a failure excerpt line containing `ModuleNotFoundError`.

### Phase 2 — Fix Pytest Collection on Windows

- [ ] [P2-T1] Create `tests/conftest.py` that inserts the repo root (`Path(__file__).resolve().parents[1]`) into `sys.path` before test collection, with module/function docstrings and a branch intent comment above the `if str(repo_root) not in sys.path` guard
  - Acceptance: Running `poetry run pytest tests/test_pytest_collection.py -k repo_root_on_sys_path_allows_scripts_import` exits 0.

### Phase 3 — Align S603 Suppressions in `scripts/dev_tools/potential_to_issue.py`

- [ ] [P3-T1] Update `RealGhClient.is_authenticated` subprocess call at line 85 to use the exact pre-authorized comment `# noqa: S603 - static analysis can't verify runtime validation`
  - Acceptance: `scripts/dev_tools/potential_to_issue.py` line 85 contains the exact comment and `poetry run ruff check scripts/dev_tools/potential_to_issue.py` exits 0.
- [ ] [P3-T2] Update `RealGhClient._run` subprocess call at line 97 to use the exact pre-authorized comment `# noqa: S603 - static analysis can't verify runtime validation`
  - Acceptance: `scripts/dev_tools/potential_to_issue.py` line 97 contains the exact comment and `poetry run ruff check scripts/dev_tools/potential_to_issue.py` exits 0.

### Phase 4 — Align S603 Suppressions in `scripts/dev_tools/new_active_feature_folder.py`

- [ ] [P4-T1] Update `default_issue_fetcher` subprocess call at line 539 to use the exact pre-authorized comment `# noqa: S603 - static analysis can't verify runtime validation`
  - Acceptance: `scripts/dev_tools/new_active_feature_folder.py` line 539 contains the exact comment and `poetry run ruff check scripts/dev_tools/new_active_feature_folder.py` exits 0.
- [ ] [P4-T2] Update `default_code_launcher` subprocess call at line 576 to use the exact pre-authorized comment `# noqa: S603 - static analysis can't verify runtime validation`
  - Acceptance: `scripts/dev_tools/new_active_feature_folder.py` line 576 contains the exact comment and `poetry run ruff check scripts/dev_tools/new_active_feature_folder.py` exits 0.

### Phase 5 — Docstring & Intent Comment Compliance for `scripts/dev_tools/potential_to_issue.py`

- [ ] [P5-T1] Add class docstrings (with Purpose/Usage/Flow/Invariants/Side Effects/Attributes headings) for `GhResult` (line 53), `RealGhClient` (line 67), `FileSystem` (line 134), `RealFileSystem` (line 150), and `PromotionOutcome` (line 176)
  - Acceptance: Running `poetry run python -c "import ast, pathlib, sys; p=pathlib.Path('scripts/dev_tools/potential_to_issue.py'); t=ast.parse(p.read_text(encoding='utf-8')); classes={n.name:ast.get_docstring(n) or '' for n in t.body if isinstance(n, ast.ClassDef)}; missing=[n for n in ['GhResult','RealGhClient','FileSystem','RealFileSystem','PromotionOutcome'] if n not in classes or any(k not in classes[n] for k in ['Purpose:','Usage:','Flow:','Invariants / Constraints:','Side Effects:','Attributes:'])]; print(missing); sys.exit(0 if not missing else 1)"` exits 0.
- [ ] [P5-T2] Add function docstrings (with Purpose/Args/Returns/Raises/Side Effects headings) for ` _resolve_workspace` (line 183), `_strip_potential_marker` (line 187), `get_feature_name` (line 192), `get_feature_path` (line 203), `get_section` (line 208), `build_body` (line 217), `build_bug_body` (line 235), `parse_issue_reference` (line 281), `_extract_last_updated` (line 289), `_find_meta_end` (line 306), `_set_line_value` (line 334), `update_metadata_lines` (line 344), `_default` (line 367), `promote_potential` (line 371), `parse_args` (line 521), and `main` (line 545)
  - Acceptance: Running `poetry run python -c "import ast, pathlib, sys; p=pathlib.Path('scripts/dev_tools/potential_to_issue.py'); t=ast.parse(p.read_text(encoding='utf-8')); funcs={n.name:ast.get_docstring(n) or '' for n in ast.walk(t) if isinstance(n, ast.FunctionDef)}; required=['_resolve_workspace','_strip_potential_marker','get_feature_name','get_feature_path','get_section','build_body','build_bug_body','parse_issue_reference','_extract_last_updated','_find_meta_end','_set_line_value','update_metadata_lines','_default','promote_potential','parse_args','main']; missing=[n for n in required if n not in funcs or any(k not in funcs[n] for k in ['Purpose:','Args:','Returns:','Raises:','Side Effects:'])]; print(missing); sys.exit(0 if not missing else 1)"` exits 0.
- [ ] [P5-T3] Add explicit intent comments for loops/comprehensions and branching in `scripts/dev_tools/potential_to_issue.py` at lines 236, 306, 336, 416-466, and 484-488
  - Acceptance: File contains the exact comment lines `# Build bug issue sections in template order to preserve heading sequence.`, `# Scan for the first section header to determine where metadata ends.`, `# Update existing metadata entry before inserting a new line.`, `# Route issue-body generation based on promotion type and eligible work mode.`, and `# Emit every gh output line to preserve context for callers.`

### Phase 6 — Docstring & Intent Comment Compliance for `scripts/dev_tools/new_active_feature_folder.py`

- [ ] [P6-T1] Add class docstrings (with Purpose/Usage/Flow/Invariants/Side Effects/Attributes headings) for `IssueMeta` (line 32), `ActiveFolderResult` (line 39), `FileSystem` (line 45), and `RealFileSystem` (line 63)
  - Acceptance: Running `poetry run python -c "import ast, pathlib, sys; p=pathlib.Path('scripts/dev_tools/new_active_feature_folder.py'); t=ast.parse(p.read_text(encoding='utf-8')); classes={n.name:ast.get_docstring(n) or '' for n in t.body if isinstance(n, ast.ClassDef)}; missing=[n for n in ['IssueMeta','ActiveFolderResult','FileSystem','RealFileSystem'] if n not in classes or any(k not in classes[n] for k in ['Purpose:','Usage:','Flow:','Invariants / Constraints:','Side Effects:','Attributes:'])]; print(missing); sys.exit(0 if not missing else 1)"` exits 0.
- [ ] [P6-T2] Add function docstrings (with Purpose/Args/Returns/Raises/Side Effects headings) for `resolve_workspace` (line 103), `validate_feature_name` (line 146), `format_checklist` (line 154), `get_section` (line 169), `set_section` (line 180), `find_potential_file` (line 408), `parse_issue_number` (line 430), `build_folder_slug` (line 437), `copy_template` (line 453), `default_issue_fetcher` (line 535), `default_code_launcher` (line 572), `create_active_folder` (line 892), `parse_args` (line 1076), and `main` (line 1108)
  - Acceptance: Running `poetry run python -c "import ast, pathlib, sys; p=pathlib.Path('scripts/dev_tools/new_active_feature_folder.py'); t=ast.parse(p.read_text(encoding='utf-8')); funcs={n.name:ast.get_docstring(n) or '' for n in ast.walk(t) if isinstance(n, ast.FunctionDef)}; required=['resolve_workspace','validate_feature_name','format_checklist','get_section','set_section','find_potential_file','parse_issue_number','build_folder_slug','copy_template','default_issue_fetcher','default_code_launcher','create_active_folder','parse_args','main']; missing=[n for n in required if n not in funcs or any(k not in funcs[n] for k in ['Purpose:','Args:','Returns:','Raises:','Side Effects:'])]; print(missing); sys.exit(0 if not missing else 1)"` exits 0.
- [ ] [P6-T3] Add explicit intent comments for loops/comprehensions and branching in `scripts/dev_tools/new_active_feature_folder.py` at lines 75-81, 155-165, 417-426, 456-463, 916-923, and 995-1023
  - Acceptance: File contains the exact comment lines `# Copy template files while preserving relative paths under the target folder.`, `# Normalize checklist lines while preserving existing checkbox formatting.`, `# Scan potential directories in priority order and return the most recent match.`, `# Prefer the timestamped plan template when both plan templates exist.`, `# Decide minor-audit usage once to keep routing deterministic.`, and `# Build issue.md content for minor-audit mode in a fixed section order.`

### Phase 7 — Test Refactors and Docstring Compliance

- [ ] [P7-T1] Remove `tmp_path` usage from `tests/scripts/dev_tools/test_potential_to_issue.py` by updating `test_real_filesystem_round_trip` (lines 503-511), `test_parse_args_and_main_paths` (lines 514-550), and `test_main_exits_on_promotion_error` (lines 553-573) to use in-memory fakes or static `Path` values
  - Acceptance: `tests/scripts/dev_tools/test_potential_to_issue.py` contains no `tmp_path` references and `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "real_filesystem_round_trip or parse_args_and_main_paths or main_exits_on_promotion_error"` exits 0.
- [ ] [P7-T2] Add docstrings for every class, helper method, and test function in `tests/scripts/dev_tools/test_potential_to_issue.py` (lines 18-700) using the intent-first format required by policy
  - Acceptance: Running `poetry run python -c "import ast, pathlib, sys; p=pathlib.Path('tests/scripts/dev_tools/test_potential_to_issue.py'); t=ast.parse(p.read_text(encoding='utf-8')); missing=[n.name for n in ast.walk(t) if isinstance(n,(ast.FunctionDef,ast.ClassDef)) and not ast.get_docstring(n)]; print(missing); sys.exit(0 if not missing else 1)"` exits 0.
- [ ] [P7-T3] Add docstrings for every class, helper method, and test function in `tests/scripts/dev_tools/test_new_active_feature_folder.py` (lines 1-900) using the intent-first format required by policy
  - Acceptance: Running `poetry run python -c "import ast, pathlib, sys; p=pathlib.Path('tests/scripts/dev_tools/test_new_active_feature_folder.py'); t=ast.parse(p.read_text(encoding='utf-8')); missing=[n.name for n in ast.walk(t) if isinstance(n,(ast.FunctionDef,ast.ClassDef)) and not ast.get_docstring(n)]; print(missing); sys.exit(0 if not missing else 1)"` exits 0.

### Phase 8 — Documentation Policy Statement Update

- [ ] [P8-T1] Add explicit minor-audit statement to `docs/engineering/Feature Playbook.md` (lines 125-128) stating broad regression and extended design docs are not required by default for minor-audit unless risk dictates otherwise
  - Acceptance: `docs/engineering/Feature Playbook.md` contains the exact sentence `For minor-audit work, broad regression and extended design docs are not required by default; escalate only when risk or scope warrants it.`
- [ ] [P8-T2] Add explicit minor-audit statement to `docs/features/templates/README.md` (lines 13-16) mirroring the regression/docs expectation
  - Acceptance: `docs/features/templates/README.md` contains the exact sentence `Minor-audit does not require broad regression or extended design docs by default; add them only when risk warrants.`

### Phase 9 — Targeted Verification Evidence

- [ ] [P9-T1] Create targeted verification artifact at `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/other/targeted-verification.2026-02-20T21-30.md` by running `poetry run pytest tests/test_pytest_collection.py tests/scripts/dev_tools/test_potential_to_issue.py tests/scripts/dev_tools/test_new_active_feature_folder.py`
  - Acceptance: Evidence file contains `Timestamp: 2026-02-20T21-30`, `Command: poetry run pytest tests/test_pytest_collection.py tests/scripts/dev_tools/test_potential_to_issue.py tests/scripts/dev_tools/test_new_active_feature_folder.py`, `EXIT_CODE: 0`, and `Output Summary`.

### Phase 10 — Final QA Loop (Format → Lint → Type → Test)

- [ ] [P10-T1] Run formatter `poetry run black .` and save output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/qa-gates/qa-format.2026-02-20T21-30.md`
  - Acceptance: Evidence file contains `Timestamp`, `Command: poetry run black .`, `EXIT_CODE: 0`.
- [ ] [P10-T2] Run linter `poetry run ruff check` and save output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/qa-gates/qa-lint.2026-02-20T21-30.md`
  - Dependencies: [P10-T1]
  - Acceptance: Evidence file contains `Timestamp`, `Command: poetry run ruff check`, `EXIT_CODE: 0`.
- [ ] [P10-T3] Run type checker `poetry run pyright` and save output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/qa-gates/qa-type.2026-02-20T21-30.md`
  - Dependencies: [P10-T2]
  - Acceptance: Evidence file contains `Timestamp`, `Command: poetry run pyright`, `EXIT_CODE: 0`.
- [ ] [P10-T4] Run tests `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and save output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/qa-gates/qa-test.2026-02-20T21-30.md`
  - Dependencies: [P10-T3]
  - Acceptance: Evidence file contains `Timestamp`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`.
- [ ] [P10-T5] Re-run the full QA loop from P10-T1 if any QA gate changes files or returns non-zero
  - Acceptance: The most recent QA evidence set shows all four commands passing in a single clean pass.
- [ ] [P10-T6] Perform final sync of `plan.2026-02-19T12-02.md` checklist items after remediation work completes
  - Acceptance: Final plan sync completed and reflected in the plan file.

## Test Plan

- Unit:
  - `tests/test_pytest_collection.py`
    - `test_repo_root_on_sys_path_allows_scripts_import` (ensures repo root is on `sys.path` and `scripts` is importable).
  - `tests/scripts/dev_tools/test_potential_to_issue.py`
    - `test_real_filesystem_round_trip` (refactored to in-memory FileSystem behavior).
    - `test_parse_args_and_main_paths` (no temp path usage).
    - `test_main_exits_on_promotion_error` (no temp path usage).
  - `tests/scripts/dev_tools/test_new_active_feature_folder.py`
    - No new scenarios; docstring compliance only.
- Integration:
  - `poetry run pytest tests/test_pytest_collection.py tests/scripts/dev_tools/test_potential_to_issue.py tests/scripts/dev_tools/test_new_active_feature_folder.py`
- Manual/CLI:
  - Not required for this remediation; rely on automated verification and evidence artifacts.

## Open Questions / Notes

- No open questions. This plan is fully deterministic and scoped to the remediation inputs.
- Do not add any new dependencies or suppressions outside pre-authorized patterns.
