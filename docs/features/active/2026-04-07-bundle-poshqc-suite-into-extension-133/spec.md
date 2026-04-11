# 2026-04-07-bundle-poshqc-suite-into-extension-133 — Spec

- **Issue:** #133
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-07T09-16
- **Status:** Draft
- **Version:** 0.2

## Overview

Bundle the existing PoshQC PowerShell quality suite into the `drm-copilot` extension so the packaged workflow runs from extension resources, targets the destination workspace, and can restrict scanning to one or more destination-workspace folders.

Primary users:
- Extension users running bundled workspace-quality workflows from the VS Code command palette.
- Automation and MCP clients that need the same bundled PowerShell quality gate without depending on repo-local scripts.

Success looks like:
- The extension exposes a dedicated bundled PoshQC command and MCP tool.
- The bundled workflow executes against the destination workspace, not copied repo-local scripts.
- Users can choose which destination-workspace folders are scanned.

## Behavior

Happy path:
- The user invokes the bundled PoshQC command or MCP tool.
- The extension resolves the bundled wrapper from extension resources.
- The wrapper imports the colocated bundled PoshQC module and runs format, analysis, and test steps against the destination workspace.
- When scan folders are supplied, only those workspace-relative folders are scanned.
- When no scan folders are supplied, the workflow defaults to the destination workspace root.

Alternate and edge flows:
- If the user cancels folder selection, the command exits without mutating files.
- If a selected folder is outside the destination workspace, the invocation fails fast.
- If required PowerShell tooling is missing, the command reports the missing dependency rather than falling back to repo-local scripts.

Error handling:
- Validate input paths before invoking the suite.
- Preserve the existing destination-workspace execution model for all other bundled workflows.
- Surface analyzer and test failures through the existing output and artifact paths.

## Inputs / Outputs

Inputs:
- Destination workspace root.
- Optional list of workspace-relative scan folders.
- Existing bundled-suite options such as test and coverage output settings.

Outputs:
- Workspace-local format, analyzer, and Pester artifacts.
- Extension output-channel progress logs.
- MCP structured results with tool name, summary, workspace root, and artifacts.

Config keys and defaults:
- Default workspace scope is the full destination workspace.
- Explicit scan folders narrow the root set used by the bundled suite.
- Bundled module/settings paths are resolved from extension resources or the repo-root wrapper location.

Backward compatibility:
- Existing command IDs and MCP tool behavior remain unchanged for the current workflows.
- The new bundled PoshQC capability is additive.

## API / CLI Surface

New command:
- `drmCopilotExtension.runPoshQCSuite`

New MCP tool:
- `run_poshqc_suite`

Wrapper script:
- `scripts/dev-tools/run-poshqc-suite.ps1`
- `extensions/drm-copilot/resources/templates/run-poshqc-suite.ps1`

Shared PowerShell module updates:
- `Get-PoshQCFileList`
- `Invoke-PoshQCFormat`
- `Invoke-PoshQCAnalyze`
- `Invoke-PoshQCTest`

Planned invocation shape:
- `-WorkspaceRoot <path>`
- `-ScanFolders <string[]>`

Validation rules:
- Scan folders must be workspace-relative and resolve inside the destination workspace.
- The bundled wrapper must import the colocated bundled module, not the repo-local copy.

## Data & State

Data flow:
- The extension resolves the bundled wrapper inside the installed extension package.
- The wrapper resolves the colocated PoshQC module and settings under extension resources.
- The module enumerates files relative to the destination workspace and the selected scan folders.

State changes:
- The destination workspace may receive formatting updates and Pester artifact output.
- The extension package itself remains read-only at runtime.

Invariants:
- Scan-folder selection never escapes the destination workspace.
- The packaged workflow never depends on repo-local `scripts/powershell/PoshQC` assets at runtime.

## Constraints & Risks

Constraints:
- Preserve existing public command IDs and current MCP tool behavior.
- Keep the bundled wrapper identical between the repo-root and extension-resources locations.
- Avoid temporary-file test strategies; use deterministic unit tests and injected collaborators.

Risks:
- The module and bundled copy can drift if parity tests are incomplete.
- Folder-selection validation can become ambiguous if path normalization is not handled consistently.
- Coverage output must remain valid when the scan scope is narrowed.

## Implementation Strategy

- Add a shared wrapper script that accepts the destination workspace and optional scan folders.
- Mirror the PoshQC module and settings into extension resources.
- Extend the shared module to honor workspace-relative scan-folder selection.
- Wire the new extension command, MCP tool, workflow parser, and folder-selection prompt.
- Update the README and feature docs so the new bundled workflow is discoverable.
- Add Jest and Pester tests for wrapper parity, command wiring, MCP dispatch, and scan-folder validation.

## Acceptance Criteria

- [x] The extension exposes a bundled PoshQC command and MCP tool that run from extension resources rather than repo-local scripts.
- [x] The bundled suite executes against the destination workspace and can limit scanning to one or more workspace-relative folders.
- [x] The shared PoshQC module validates scan folders and preserves the existing quality-gate behavior for formatting, analysis, and Pester execution.
- [x] The extension and PowerShell test suites cover the new wrapper, command wiring, MCP dispatch, and folder-selection behavior.
- [x] Documentation and feature artifacts reflect the new bundled workflow and its usage.

## Definition of Done

- [x] Acceptance criteria are documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added for the extension and PowerShell surfaces
- [x] Edge cases and error handling are covered by tests
- [x] Documentation is updated for the bundled workflow and scan-folder selection
- [x] Toolchain pass completed for the touched languages
