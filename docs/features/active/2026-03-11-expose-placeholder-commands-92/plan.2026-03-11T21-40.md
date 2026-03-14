# 2026-03-11-expose-placeholder-commands — Atomic Plan

- Issue: #92
- Work Mode: full-feature
- Plan File: `docs/features/active/2026-03-11-expose-placeholder-commands-92/plan.2026-03-11T21-40.md`
- Last Updated: 2026-03-11

## Overview

Replace the four placeholder VS Code extension commands with real command handlers that bundle the referenced Python and PowerShell scripts, prompt for required user input, and execute through `executeBundledScript()` using the established extension-side pattern. The implementation order stays intentionally incremental: `newPotentialBugEntry` → `newPotentialEntry` → `potentialToIssue` → `newActiveFeatureFolder`, followed by placeholder removal and full multi-language QA.

## Status Notes

- Remediation follow-up: `remediation-plan.2026-03-14T15-48.md`
- Remediation verification complete: remediation-plan.2026-03-14T15-48.md

## Requirements Inputs

- Primary acceptance source: `docs/features/active/2026-03-11-expose-placeholder-commands-92/issue.md`
- Technical specification: `docs/features/active/2026-03-11-expose-placeholder-commands-92/spec.md`
- Research notes: `docs/features/active/2026-03-11-expose-placeholder-commands-92/research.md`
- User scenarios: `docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md`

## Evidence Locations

- Baseline evidence: `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/`
- Regression evidence: `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/regression-testing/`
- Other evidence: `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/other/`
- QA evidence: `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/`

### Phase 0 — Context & Inputs

- [x] [P0-T1] Record the mandatory policy-read order in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/phase0-instructions-read.md`
  - Acceptance: The file exists and contains `Timestamp:`, `Policy Order:`, and an explicit `Files Read:` list covering `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, and `.github/instructions/powershell-unit-test.instructions.md` in that order.
- [x] [P0-T2] Record the feature requirements snapshot in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/requirements-snapshot.md`
  - Acceptance: The file exists and contains `Work Mode: full-feature`, the four requirements-source file paths, the implementation order `newPotentialBugEntry -> newPotentialEntry -> potentialToIssue -> newActiveFeatureFolder`, and explicit sections named `Command IDs:` and `Bundled File Manifest:`.
- [x] [P0-T3] Capture the extension-format baseline with `npm --prefix extensions/drm-copilot run format`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/typescript-format.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T4] Capture the extension-lint baseline with `npm --prefix extensions/drm-copilot run lint`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/typescript-lint.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T5] Capture the extension-typecheck baseline with `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/typescript-typecheck.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T6] Capture the extension-unit-test baseline with `npm --prefix extensions/drm-copilot run test:unit`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/typescript-test.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T7] Capture the root Python format baseline with `poetry run black .`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/python-format.*.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T8] Capture the root Python lint baseline with `poetry run ruff check`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/python-lint.*.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T9] Capture the root Python typecheck baseline with `poetry run pyright`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/python-typecheck.*.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T10] Capture the root Python test baseline with `poetry run pytest --cov-report=term-missing`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/python-test.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headlines from the terminal coverage report.
- [x] [P0-T11] Capture the PowerShell format baseline with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/powershell-format.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T12] Capture the PowerShell analyze baseline with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/powershell-analyze.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T13] Capture the PowerShell test baseline with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/powershell-test.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — New Potential Bug Entry

- [x] [P1-T1] Extend the shared VS Code mock harness in `extensions/drm-copilot/test/extension.test.ts` to control `showInputBox`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` declares a `showInputBoxMock`, resets it in `beforeEach` or `afterEach`, and wires it into the mocked `vscode.window` object.
- [x] [P1-T2] Create `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` from `scripts/dev_tools/new_potential_bug_entry.py`
  - Acceptance: The new file exists and uses `Path.cwd()` for workspace resolution instead of `Path(__file__).resolve().parents[2]`.
- [x] [P1-T3] Implement `drmCopilotExtension.newPotentialBugEntry` in `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` registers `drmCopilotExtension.newPotentialBugEntry`, prompts with `showInputBox`, validates the short name, and passes `runtimeKind: "python"`, `bundledRelativePath: "resources/templates/new_potential_bug_entry.py"`, and an args array whose first element is `--short-name` to `executeBundledScript()`.
- [x] [P1-T4] Update the `newPotentialBugEntry` command contribution in `extensions/drm-copilot/package.json`
  - Acceptance: `extensions/drm-copilot/package.json` contains `{ "command": "drmCopilotExtension.newPotentialBugEntry", "title": "drm-copilot: New Potential Bug Entry" }` and no longer contributes `drmCopilotExtension.newPotentialBugEntryPyPlaceholder`.
- [x] [P1-T5] Add a registration scenario for `newPotentialBugEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that asserts `commandHandlers.has("drmCopilotExtension.newPotentialBugEntry")` after activation.
- [x] [P1-T6] Add an execution-args scenario for `newPotentialBugEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that drives a valid short name, invokes `drmCopilotExtension.newPotentialBugEntry`, and asserts the spawned argv includes `C:/extension/resources/templates/new_potential_bug_entry.py`, `--short-name`, and the supplied short name.
- [x] [P1-T7] Add a cancellation scenario for `newPotentialBugEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that sets `showInputBoxMock` to return `undefined`, invokes `drmCopilotExtension.newPotentialBugEntry`, and asserts `spawn` was not called.
- [x] [P1-T8] Add a missing-runtime scenario for `newPotentialBugEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that disables Python runtime discovery, invokes `drmCopilotExtension.newPotentialBugEntry`, and asserts the thrown error contains `Python runtime 'python' not found on PATH.`.
- [x] [P1-T9] Add a non-zero-exit scenario for `newPotentialBugEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that makes the spawned process exit non-zero, invokes `drmCopilotExtension.newPotentialBugEntry`, and asserts the error contains `Command exited with code`.

### Phase 2 — New Potential Entry

- [x] [P2-T1] Create `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` from `scripts/dev-tools/new-potential-entry.ps1`
  - Acceptance: The new file exists and resolves the workspace root from `Get-Location` instead of deriving it from `$PSScriptRoot`.
- [x] [P2-T2] Add the co-located PowerShell helper `extensions/drm-copilot/resources/templates/vscode-cli.helpers.ps1`
  - Acceptance: The helper file exists at `extensions/drm-copilot/resources/templates/vscode-cli.helpers.ps1` and `new-potential-entry.ps1` dot-sources it via `Join-Path -Path $PSScriptRoot -ChildPath 'vscode-cli.helpers.ps1'`.
- [x] [P2-T3] Implement `drmCopilotExtension.newPotentialEntry` in `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` registers `drmCopilotExtension.newPotentialEntry`, prompts with `showInputBox`, validates the short name, and passes `runtimeKind: "powershell"`, `bundledRelativePath: "resources/templates/new-potential-entry.ps1"`, and an args array whose first element is `-ShortName` to `executeBundledScript()`.
- [x] [P2-T4] Update the `newPotentialEntry` command contribution in `extensions/drm-copilot/package.json`
  - Acceptance: `extensions/drm-copilot/package.json` contains `{ "command": "drmCopilotExtension.newPotentialEntry", "title": "drm-copilot: New Potential Entry" }` and no longer contributes `drmCopilotExtension.newPotentialEntryPsPlaceholder`.
- [x] [P2-T5] Add a registration scenario for `newPotentialEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that asserts `commandHandlers.has("drmCopilotExtension.newPotentialEntry")` after activation.
- [x] [P2-T6] Add an execution-args scenario for `newPotentialEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that drives a valid short name, invokes `drmCopilotExtension.newPotentialEntry`, and asserts the spawned argv includes `C:/extension/resources/templates/new-potential-entry.ps1` and `-ShortName` with the supplied value.
- [x] [P2-T7] Add a cancellation scenario for `newPotentialEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that sets `showInputBoxMock` to return `undefined`, invokes `drmCopilotExtension.newPotentialEntry`, and asserts `spawn` was not called.
- [x] [P2-T8] Add a missing-runtime scenario for `newPotentialEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that disables both `pwsh` and `powershell`, invokes `drmCopilotExtension.newPotentialEntry`, and asserts the thrown error contains `PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.`.
- [x] [P2-T9] Add a non-zero-exit scenario for `newPotentialEntry` in `extensions/drm-copilot/test/extension.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.test.ts` contains a Jest test that makes the spawned process exit non-zero, invokes `drmCopilotExtension.newPotentialEntry`, and asserts the error contains `Command exited with code`.

### Phase 3 — Potential To Issue

- [x] [P3-T1] Add the shared bundled module `extensions/drm-copilot/resources/scripts/dev_tools/prompt_mode_contract.py`
  - Acceptance: The new file exists and matches the source module name `prompt_mode_contract.py` so bundled imports can target `dev_tools.prompt_mode_contract`.
- [x] [P3-T2] Add `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue_content.py`
  - Acceptance: The new file exists at `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue_content.py` and contains no `scripts.dev_tools` import path.
- [x] [P3-T3] Add `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`
  - Acceptance: The new file exists and rewrites all `scripts.dev_tools` imports to `dev_tools` imports.
- [x] [P3-T4] Create `extensions/drm-copilot/resources/templates/potential_to_issue.py`
  - Acceptance: The new file exists, defines `_ensure_bundled_scripts_import_path()`, prepends `resources/scripts` to `sys.path`, and imports `dev_tools.potential_to_issue`.
- [x] [P3-T5] Add a wrapper-import scenario for `potential_to_issue` in `tests/scripts/dev_tools/test_extension_bundled_templates.py`
  - Acceptance: `tests/scripts/dev_tools/test_extension_bundled_templates.py` contains a Pytest test named `test_potential_to_issue_template_imports_bundled_module` that imports the bundled template successfully.
- [x] [P3-T6] Implement `drmCopilotExtension.potentialToIssue` in `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` registers `drmCopilotExtension.potentialToIssue`, gathers `potential-path` via `showOpenDialog`, gathers `promotion-type` and `work-mode` via `showQuickPick`, and passes `runtimeKind: "python"`, `bundledRelativePath: "resources/templates/potential_to_issue.py"`, and the exact `--potential-path`, `--promotion-type`, and `--work-mode` argv pairs to `executeBundledScript()`.
- [x] [P3-T7] Update the `potentialToIssue` command contribution in `extensions/drm-copilot/package.json`
  - Acceptance: `extensions/drm-copilot/package.json` contains `{ "command": "drmCopilotExtension.potentialToIssue", "title": "drm-copilot: Potential To Issue" }` and no longer contributes `drmCopilotExtension.potentialToIssuePlaceholder`.
- [x] [P3-T8] Add a registration scenario for `potentialToIssue` in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` contains a Jest test that asserts `commandHandlers.has("drmCopilotExtension.potentialToIssue")` after activation.
- [x] [P3-T9] Add an execution-args scenario for `potentialToIssue` in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` contains a Jest test that selects a markdown file, chooses `promotion-type` and `work-mode`, invokes `drmCopilotExtension.potentialToIssue`, and asserts the spawned argv includes `resources/templates/potential_to_issue.py`, `--potential-path`, `--promotion-type`, and `--work-mode` with the selected values.
- [x] [P3-T10] Add a file-picker cancellation scenario for `potentialToIssue` in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` contains a Jest test that sets `showOpenDialog` to return `undefined`, invokes `drmCopilotExtension.potentialToIssue`, and asserts `spawn` was not called.
- [x] [P3-T11] Add a promotion-type cancellation scenario for `potentialToIssue` in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` contains a Jest test that cancels the promotion-type quick pick after selecting a file and asserts `spawn` was not called.
- [x] [P3-T12] Add a work-mode cancellation scenario for `potentialToIssue` in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` contains a Jest test that cancels the work-mode quick pick after selecting a file and a promotion type and asserts `spawn` was not called.
- [x] [P3-T13] Add a missing-runtime scenario for `potentialToIssue` in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` contains a Jest test that disables Python runtime discovery, invokes `drmCopilotExtension.potentialToIssue`, and asserts the thrown error contains `Python runtime 'python' not found on PATH.`.
- [x] [P3-T14] Add a non-zero-exit scenario for `potentialToIssue` in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` contains a Jest test that makes the spawned process exit non-zero, invokes `drmCopilotExtension.potentialToIssue`, and asserts the error contains `Command exited with code`.

### Phase 4 — New Active Feature Folder

- [x] [P4-T1] Add `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_models.py`
  - Acceptance: The new file exists and preserves the source module name so bundled imports can target `dev_tools.new_active_feature_folder_models`.
- [x] [P4-T2] Add `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_markdown.py`
  - Acceptance: The new file exists and rewrites bundled imports to `dev_tools` paths where needed.
- [x] [P4-T3] Add `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_docs.py`
  - Acceptance: The new file exists and rewrites bundled imports to `dev_tools` paths where needed.
- [x] [P4-T4] Add `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`
  - Acceptance: The new file exists and rewrites bundled imports to `dev_tools` paths where needed.
- [x] [P4-T5] Add `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_flow.py`
  - Acceptance: The new file exists and rewrites bundled imports to `dev_tools` paths where needed.
- [x] [P4-T6] Add `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder.py`
  - Acceptance: The new file exists at `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder.py` and contains no `scripts.dev_tools` import path.
- [x] [P4-T7] Create `extensions/drm-copilot/resources/templates/new_active_feature_folder.py`
  - Acceptance: The new file exists, defines `_ensure_bundled_scripts_import_path()`, prepends `resources/scripts` to `sys.path`, and imports `dev_tools.new_active_feature_folder`.
- [x] [P4-T8] Add a wrapper-import scenario for `new_active_feature_folder` in `tests/scripts/dev_tools/test_extension_bundled_templates.py`
  - Acceptance: `tests/scripts/dev_tools/test_extension_bundled_templates.py` contains a Pytest test named `test_new_active_feature_folder_template_imports_bundled_module` that imports the bundled template successfully.
- [x] [P4-T9] Implement `drmCopilotExtension.newActiveFeatureFolder` in `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` registers `drmCopilotExtension.newActiveFeatureFolder`, gathers `type` and `work-mode` with `showQuickPick`, gathers `feature-name` and `issue-number` with `showInputBox`, and passes `runtimeKind: "python"`, `bundledRelativePath: "resources/templates/new_active_feature_folder.py"`, `--feature-name`, `--type`, and `--work-mode` argv pairs to `executeBundledScript()`, while omitting `--issue-number` when the prompt is left blank.
- [x] [P4-T10] Update the `newActiveFeatureFolder` command contribution in `extensions/drm-copilot/package.json`
  - Acceptance: `extensions/drm-copilot/package.json` contains `{ "command": "drmCopilotExtension.newActiveFeatureFolder", "title": "drm-copilot: New Active Feature Folder" }` and no longer contributes `drmCopilotExtension.newActiveFeatureFolderPlaceholder`.
- [x] [P4-T11] Add a registration scenario for `newActiveFeatureFolder` in `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` contains a Jest test that asserts `commandHandlers.has("drmCopilotExtension.newActiveFeatureFolder")` after activation.
- [x] [P4-T12] Add an execution-args scenario for `newActiveFeatureFolder` in `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` contains a Jest test that selects a type, supplies a feature name, leaves the issue number blank, selects a work mode, invokes `drmCopilotExtension.newActiveFeatureFolder`, and asserts the spawned argv includes `resources/templates/new_active_feature_folder.py`, `--feature-name`, `--type`, and `--work-mode`, while not including `--issue-number`.
- [x] [P4-T13] Add a type-prompt cancellation scenario for `newActiveFeatureFolder` in `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` contains a Jest test that cancels the first quick pick and asserts `spawn` was not called.
- [x] [P4-T14] Add a feature-name cancellation scenario for `newActiveFeatureFolder` in `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` contains a Jest test that cancels the feature-name input after selecting a type and asserts `spawn` was not called.
- [x] [P4-T15] Add an issue-number cancellation scenario for `newActiveFeatureFolder` in `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` contains a Jest test that cancels the issue-number input after supplying the feature name and asserts `spawn` was not called.
- [x] [P4-T16] Add a work-mode cancellation scenario for `newActiveFeatureFolder` in `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` contains a Jest test that cancels the work-mode quick pick after supplying earlier inputs and asserts `spawn` was not called.
- [x] [P4-T17] Add a missing-runtime scenario for `newActiveFeatureFolder` in `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` contains a Jest test that disables Python runtime discovery, invokes `drmCopilotExtension.newActiveFeatureFolder`, and asserts the thrown error contains `Python runtime 'python' not found on PATH.`.
- [x] [P4-T18] Add a non-zero-exit scenario for `newActiveFeatureFolder` in `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` contains a Jest test that makes the spawned process exit non-zero, invokes `drmCopilotExtension.newActiveFeatureFolder`, and asserts the error contains `Command exited with code`.

### Phase 5 — Placeholder Cleanup

- [x] [P5-T1] Remove the placeholder registration infrastructure from `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` no longer contains `PlaceholderCommandSpec`, `PLACEHOLDER_COMMAND_SPECS`, or `registerPlaceholderCommands`, and the final `context.subscriptions.push(` call includes only live command disposables plus `output`.
- [x] [P5-T2] Delete `extensions/drm-copilot/test/extension.placeholder-commands.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.placeholder-commands.test.ts` does not exist.
- [x] [P5-T3] Add a placeholder-absence scenario to the extension Jest suite
  - Acceptance: A Jest test in `extensions/drm-copilot/test/extension.test.ts` or a new focused `.test.ts` file asserts that activation does not register `drmCopilotExtension.newActiveFeatureFolderPlaceholder`, `drmCopilotExtension.potentialToIssuePlaceholder`, `drmCopilotExtension.newPotentialBugEntryPyPlaceholder`, or `drmCopilotExtension.newPotentialEntryPsPlaceholder`.
- [x] [P5-T4] Align command documentation references with the live command IDs
  - Acceptance: A grep over `extensions/drm-copilot/README.md` and `/workspaces/drm-copilot/README.md` finds no matches for the four placeholder command IDs after any necessary doc updates.

### Phase 6 — Final QA

Executor rule: For each language loop below, restart that language loop from its step 1 whenever formatting changes files or any later step fails.

- [x] [P6-T1] Capture final extension-format evidence with `npm --prefix extensions/drm-copilot run format`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/typescript-format.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T2] Capture final extension-lint evidence with `npm --prefix extensions/drm-copilot run lint`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/typescript-lint.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T3] Capture final extension-typecheck evidence with `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/typescript-typecheck.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T4] Capture final extension-test evidence with `npm --prefix extensions/drm-copilot run test:unit`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/typescript-test.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T5] Capture final root-Python format evidence with `poetry run black .`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/python-format.*.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T6] Capture final root-Python lint evidence with `poetry run ruff check`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/python-lint.*.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T7] Capture final root-Python typecheck evidence with `poetry run pyright`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/python-typecheck.*.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T8] Capture final root-Python test evidence with `poetry run pytest --cov-report=term-missing`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/python-test.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage headlines from the terminal coverage report.
- [x] [P6-T9] Capture final PowerShell format evidence with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/powershell-format.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T10] Capture final PowerShell analyze evidence with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/powershell-analyze.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T11] Capture final PowerShell test evidence with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: A file matching `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/powershell-test.*.md` exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P6-T12] Record the final command-surface summary in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/final-command-surface-summary.md`
  - Acceptance: The file exists and lists the four live command IDs, confirms the four placeholder command IDs are absent from `extensions/drm-copilot/src/extension.ts` and `extensions/drm-copilot/package.json`, and links the final QA artifacts recorded in Phase 6.

## Planner Self-Check

- Mode resolved from `issue.md`: `full-feature`
- Phase 0 includes policy-read evidence and baseline capture for TypeScript, Python, and PowerShell
- Implementation phases progress from the simplest command to the most complex command
- Final QA includes the required format → lint → typecheck → test loops for each applicable language
- No placeholder task text remains in this plan
