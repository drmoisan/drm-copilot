# poshqc-test-terminal-output-scan-config (Issue #344)

- Date captured: 2026-07-10
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/poshqc-test-terminal-output-scan-config/ (Issue #344)

- Issue: #344
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/344
- Last Updated: 2026-07-10
- Work Mode: full-feature

## Problem / Why

The `drm-copilot: Run PoshQC Test` command writes its Pester output to the extension
OutputChannel window rather than the integrated terminal, which is inconsistent with how
the local `PoshQC: 4 test (Pester)` task presents results. In addition, the set of folders
scanned by the command's "Scan entire workspace" option does not match the folders covered by
the local task, which invokes `Invoke-PoshQCTest -Root '${workspaceFolder}'` and discovers a
larger set of Pester tests. There is currently no persisted, user-editable configuration that
records which folders are included in the test scan, and the command's folder-selection flow
uses a native OS folder picker rather than an interactive select/deselect experience for
folders and subfolders.

## Proposed Behavior

1. When `drm-copilot: Run PoshQC Test` is invoked from the command palette, its process output
   is redirected to the integrated terminal instead of (or in addition to) the OutputChannel.
2. The folder coverage of the command's workspace scan is reconciled with the local Pester task
   so the command gathers the same tests as the task.
3. A local, persisted configuration mechanism records which folders and subfolders are included
   in the PoshQC test scan, editable by the user.
4. The command provides an interactive way to select and deselect folders and subfolders for
   scanning (for example a multi-select QuickPick with checkbox items), seeded from and writing
   back to the persisted configuration.

## Acceptance Criteria (early draft)

- [ ] AC1: `Run PoshQC Test` output appears in the integrated terminal when run from the command.
- [ ] AC2: The command's workspace scan reconciles folder coverage with the local Pester task.
- [ ] AC3: A persisted local configuration records the included test-scan folders/subfolders.
- [ ] AC4: The command offers interactive select/deselect of folders and subfolders, backed by
      the persisted configuration.

## Constraints & Risks

- Terminal redirection must preserve exit-code and failure reporting semantics used downstream.
- Folder-coverage reconciliation must not silently broaden or narrow the local task's behavior.
- Configuration schema is a cross-module contract between the extension command layer, the
  PoshQC PowerShell scan-folder discovery, and possibly the MCP surface.
- No production file may exceed 500 lines; coverage thresholds (line >= 85%, branch >= 75%) apply.

## Test Conditions to Consider

- [ ] Unit coverage for terminal-output routing and folder-selection persistence in TypeScript.
- [ ] Pester coverage for scan-folder discovery parity.
- [ ] Interactive select/deselect edge cases (empty selection, nested subfolders, persistence round-trip).

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/poshqc-test-terminal-output-scan-config/` folder from the template
