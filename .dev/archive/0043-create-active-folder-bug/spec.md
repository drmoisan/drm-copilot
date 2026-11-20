# 2026-02-22-create-active-folder-bug (Spec)

- **Issue:** #43
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-22T14-53
- **Status:** Draft
- **Version:** 0.1
- **Work Mode:** full

## Context
`Dev: 3 Create Active Folder` can miss the promoted bug markdown when the manually entered `--feature-name` does not match the promoted filename selection heuristic, so the promoted file is not moved/renamed to `issue.md` in the new active folder. In explicit `full` mode, the resulting moved `issue.md` can also miss the required persisted `- Work Mode: full` marker.

Environment:
- OS/version: Windows host
- Python version: Poetry-managed project interpreter
- Command/flags used: VS Code task `Dev: 3 Create Active Folder`; equivalent CLI `poetry run python -m scripts.dev_tools.new_active_feature_folder --feature-name <value> --type bug --issue-number 42 --work-mode full`
- Data source or fixture: `docs/features/potential/promoted/2026-02-22-testing-missing-mock-injections.md`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Ensure promoted bug file exists at `docs/features/potential/promoted/2026-02-22-testing-missing-mock-injections.md`.
2. Run `Dev: 3 Create Active Folder` with `type=bug`, `work-mode=full`, and a manual `ActiveFeatureName` that does not align with the promoted filename stem.
3. Inspect `docs/features/active/<new-folder>/` and confirm whether `issue.md` was created from the promoted file and whether a `- Work Mode: full` marker exists.

Expected:
The workflow should deterministically resolve the intended promoted file for bug creation, move/rename it to `<active-folder>/issue.md`, and persist exactly one work-mode marker `- Work Mode: full` for full-mode runs.

Actual:
When the manual feature-name value does not match lookup expectations, `find_potential_file(...)` returns no match and no promoted-file move occurs. Additionally, explicit `full` mode does not currently upsert `- Work Mode: full` in the moved `issue.md` content.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:
	- Task args in `.vscode/tasks.json` pass direct prompt input for `--feature-name` and do not derive from active file.
	- `scripts/dev_tools/new_active_feature_folder_flow.py` only writes `- Work Mode: full` under the `minor-audit` fallback branch.


## Scope & Non-Goals
- In scope:
	- Add an auto-resolve option in active-folder creation so feature name can be derived from active editor file path.
	- Add supporting VS Code task `Dev: 3 Auto Create Folder` using active file path as source-of-truth.
	- Enforce canonical validation for auto-resolve: file must be under `docs/features/potential/promoted` and have `.md` extension.
	- Persist `- Work Mode: full` in moved `issue.md` when selected mode is full.
- Out of scope / non-goals:
	- Rewriting promotion workflow in `scripts/dev_tools/potential_to_issue.py`.
	- Introducing fuzzy or probabilistic matching for potential file selection.
	- Changing minor-audit eligibility rules.
- Explicitly excluded systems, integrations, or datasets:
	- GitHub issue template structures and issue labels.
	- External services beyond existing local CLI/task behavior.

## Root Cause Analysis
Primary root cause is an input source-of-truth gap: `Dev: 3 Create Active Folder` depends on manual `ActiveFeatureName`, while potential selection depends on filename substring matching in `find_potential_file(...)`; mismatch causes non-deterministic selection failures. Secondary root cause is marker persistence asymmetry: full marker insertion is implemented for minor-audit fallback but not for explicit full mode. Relevant files are `.vscode/tasks.json`, `scripts/dev_tools/new_active_feature_folder_flow.py`, `scripts/dev_tools/new_active_feature_folder_io.py`, and `scripts/dev_tools/new_active_feature_folder_markdown.py`.


## Proposed Fix

### Design summary (what changes where):
- Extend `scripts/dev_tools/new_active_feature_folder_flow.py` argument surface to support deriving feature name from active file path (new option).
- Add canonical path validation logic for active-file auto-resolve in active-folder creation flow.
- Update full-mode path to always upsert `- Work Mode: full` in moved `issue.md`.
- Add task `Dev: 3 Auto Create Folder` in `.vscode/tasks.json` that passes `${file}` to the new auto-resolve option.

### Boundaries and invariants to preserve:
- Existing `Dev: 3 Create Active Folder` manual entry path remains backward compatible.
- `find_potential_file(...)` continues searching `docs/features/potential/` and `docs/features/potential/promoted/`.
- Persisted work-mode marker invariant remains exactly one marker line (`minor-audit` or `full`) above first `##` heading.
- Minor-audit fallback behavior and fallback-reason output stay unchanged.

### Dependencies or blocked work:
- Dependency: active file must be open and saved in VS Code for `${file}` substitution.
- No external service dependency is required.
- No release blocker beyond updating and validating `.vscode/tasks.json` and Python tests.

### Implementation strategy (what changes, not sequencing):
#### Files/modules to change:
- `.vscode/tasks.json`
- `scripts/dev_tools/new_active_feature_folder_flow.py`
- `scripts/dev_tools/new_active_feature_folder.py` (re-export surface if needed)
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`

#### Functions/classes/CLI commands impacted:
- `parse_args()` and `create_active_folder(...)` in `new_active_feature_folder_flow.py`
- CLI module command: `python -m scripts.dev_tools.new_active_feature_folder`
- VS Code task command definitions for active-folder creation

#### Data flow and validation changes:
- When auto-resolve option is present, derive `feature_name` from active file stem.
- Validate active file requirements:
	- Path must be inside `docs/features/potential/promoted`
	- Extension must be `.md`
- If invalid, exit with deterministic guidance: user must select a promoted markdown file in canonical location or provide feature name directly.
- Continue existing flow for potential-file move and doc seeding.

#### Error handling and logging updates:
- Add explicit user-facing validation error for invalid auto-resolve path/extension.
- Keep existing selected-mode and fallback-reason messages.
- Add concise log line indicating resolved feature name source (`manual` vs `active-file`).

#### Rollback/feature-flag considerations (if applicable):
- Rollback path is low risk: remove new task and ignore the new CLI option while preserving existing manual task behavior.
- No runtime feature flag is required; option is opt-in.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- New CLI option input: active file path string (workspace-relative or absolute) for auto feature-name resolution.
- Resolution contract: `docs/features/potential/promoted/2026-02-22-testing-missing-mock-injections.md` resolves to feature name `2026-02-22-testing-missing-mock-injections`.
- Invalid input contract: clear actionable error with guidance to use canonical promoted markdown or provide feature name directly.
- Output contract: active folder creation result remains unchanged (`ActiveFolderResult` with `target` and optional `potential_issue_path`).

#### Required configuration keys and defaults:
- No new environment variables.
- Existing defaults remain:
	- `--work-mode` default `full`
	- `--type` default `feature`
	- Manual `--feature-name` path remains supported.

#### Backward-compatibility expectations:
- Existing scripts and tasks using `--feature-name` continue to work unchanged.
- Existing `Dev: 3 Create Active Folder` remains available for manual workflows.
- New `Dev: 3 Auto Create Folder` is additive and optional.

#### Performance constraints (latency/throughput/memory):
- Auto-resolve path check must stay O(1) relative to file count (path/string validation only).
- No additional directory scanning beyond existing `find_potential_file(...)` behavior.
- No measurable memory impact expected.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
	- User runs tasks from repository root in VS Code workspace.
	- Promoted issue docs follow current folder contract under `docs/features/potential/promoted`.
	- Active file variable `${file}` resolves correctly in VS Code task context.
- Constraints (budget, performance, compatibility):
	- Must preserve current behavior for manual task users.
	- Must not break existing minor-audit/full mode routing semantics.
	- Must keep deterministic marker placement in `issue.md`.
- External dependencies (services, libraries, releases):
	- No new runtime dependency.
	- Uses existing Python stdlib and VS Code task variables.

## Data / API / Config Impact
- User-facing or API changes:
	- New auto-resolve CLI option for active-file-driven feature-name resolution.
	- New task `Dev: 3 Auto Create Folder` in `.vscode/tasks.json`.
- Data or migration considerations:
	- No schema migration.
	- Existing promoted and active markdown data remain compatible.
- Logging/telemetry updates (if any):
	- Add deterministic validation/error messages for invalid active-file location or extension.
	- Keep existing selected-mode/fallback output.
- Compatibility notes (CLI flags, config schemas, versioning):
	- Additive flag only; no breaking change to existing arguments.
	- No config version bump required.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas
- [ ] Integration scenario to retest
- [ ] Manual verification notes

- Regression tests to add or update:
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_full_mode_persists_full_marker_in_issue_md`
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file`
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_auto_resolve_rejects_non_promoted_or_non_markdown_active_file`
- Unit tests (pytest) for the fixed behavior and boundaries:
	- Verify explicit full mode writes exactly one `- Work Mode: full` marker above first `##` heading.
	- Verify valid auto-resolve path derives expected feature name from filename stem.
	- Verify manual mode remains unchanged when auto-resolve option not provided.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
	- Active file outside `docs/features/potential/promoted`.
	- Active file under canonical folder but extension not `.md`.
	- Active file path does not exist.
	- Filename with valid date+slug format and issue suffix variants.
- Error handling and logging verification:
	- Assert deterministic guidance message for invalid auto-resolve input.
	- Assert selected-mode and fallback logs remain unchanged for existing flows.
- Coverage impact and targets for changed lines/modules:
	- Maintain or improve coverage for changed logic in `new_active_feature_folder_flow.py` and updated task-facing argument handling.
- Toolchain commands to run (format → lint → type-check → test):
	- `poetry run black .`
	- `poetry run ruff check`
	- `poetry run pyright`
	- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- Manual validation steps (if required):
	- Open promoted file `docs/features/potential/promoted/2026-02-22-testing-missing-mock-injections.md` in editor.
	- Run `Dev: 3 Auto Create Folder` with `type=bug`, `work-mode=full`, `issue-number=42`.
	- Confirm resulting active folder contains `issue.md` moved from promoted file with exactly one `- Work Mode: full` marker.


## Acceptance Criteria
- [x] Repro now succeeds: running active-folder creation for bug `#42` using auto-resolved promoted file path materializes `<active-folder>/issue.md` from promoted source.
- [x] `issue.md` for explicit full mode contains exactly one marker line `- Work Mode: full` placed above the first `##` heading.
- [x] Regression tests are added and passing:
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_full_mode_persists_full_marker_in_issue_md`
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file`
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_auto_resolve_rejects_non_promoted_or_non_markdown_active_file`
- [x] Invalid auto-resolve cases return deterministic guidance to select canonical promoted markdown or supply feature name directly.
- [x] Existing manual `Dev: 3 Create Active Folder` behavior remains backward compatible.
- [x] Existing minor-audit routing/fallback behavior remains unchanged.
- [x] Full toolchain pass is completed for changed code paths.
- [x] `.vscode/tasks.json` includes additive task `Dev: 3 Auto Create Folder` and references are documented in feature docs.

Acceptance Evidence:
- Targeted regression pass artifacts:
	- `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-auto-resolve-valid.2026-02-22T14-53.md`
	- `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-auto-resolve-invalid.2026-02-22T14-53.md`
	- `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/regression-testing/pass-full-marker.2026-02-22T14-53.md`
- Final QA clean-pass artifact:
	- `docs/features/active/2026-02-22-create-active-folder-bug-43/evidence/qa-gates/final-pass-summary.2026-02-22T14-53.md`

## Risks & Mitigations
- Technical or operational risks:
	- Risk of ambiguous path handling across Windows/Unix separators for active-file resolution.
	- Risk of duplicate/incorrect marker placement in `issue.md` if full-mode insertion is not idempotent.
	- Risk of unintended behavior changes for existing manual workflows.
- Mitigations and rollbacks:
	- Normalize paths with `Path.resolve()` + workspace-relative checks and explicit extension validation.
	- Reuse `upsert_work_mode_marker(...)` to enforce single-marker invariant.
	- Keep new behavior opt-in via new flag/task; rollback by removing additive task/flag usage.

## Rollout & Follow-up
- Release/rollout steps:
	- Implement Python flow and task updates.
	- Run required Python toolchain and targeted regression tests.
	- Validate VS Code task execution manually on promoted bug markdown.
	- Merge via standard PR workflow for issue `#43`.
- Post-fix monitoring or clean-up tasks:
	- Verify no future reports of missing promoted-file move in active-folder creation.
	- Verify marker persistence behavior for both full and minor-audit paths in subsequent bug/feature runs.
	- Optionally add a short operator note in `docs/engineering/Feature Playbook.md` describing when to use auto-create task.
- Links: issue, PRs, related docs
	- Issue: `#43`
	- Related research: `docs/features/active/2026-02-22-create-active-folder-bug-43/research.md`
	- Related promoted source example: `docs/features/potential/promoted/2026-02-22-testing-missing-mock-injections.md`
