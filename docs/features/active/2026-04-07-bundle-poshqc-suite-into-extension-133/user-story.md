# `2026-04-07-bundle-poshqc-suite-into-extension-133` — User Story

- Issue: #133
- Owner: drmoisan
- Status: Complete
- Last Updated: 2026-04-07T09-16

## Story Statement

- As a contributor using the extension, I want the bundled PoshQC suite to run from extension resources, so that I can quality-check PowerShell scripts in the destination workspace without depending on repo-local copies.
- As an automation client using the MCP bridge, I want the same bundled PoshQC workflow, so that automated validation can target destination-workspace folders consistently.

## Problem / Why

The repo already bundles several workspace-scoped workflows into the extension, but PoshQC still lives only in the repo-local PowerShell toolchain. That makes the PowerShell quality gate unavailable to users who are working through the packaged extension surface and prevents the workflow from scanning destination-workspace folders in a controlled way.

## Personas & Scenarios

- Persona: Extension user running workspace-wide quality checks
  - wants a bundled command that behaves the same way on any destination workspace
  - cares about predictable scan scope and clear output
  - needs the workflow to work without depending on repo-local helper scripts

- Persona: Automation client invoking the MCP bridge
  - wants a stable semantic tool for the same bundle
  - needs structured results and artifact paths
  - cares about deterministic workspace-relative inputs

- Scenario: A contributor opens a destination workspace containing multiple PowerShell subfolders, runs the bundled PoshQC command, selects only the folders that matter for the current change, and receives format, analyzer, and test results for those folders without copying scripts into the workspace.

## Acceptance Criteria

- [x] The extension command and MCP tool run the bundled PoshQC suite from extension resources.
- [x] The bundled suite targets the destination workspace instead of repo-local scripts.
- [x] Users can select one or more destination-workspace folders to scan, and the workflow validates that the folders stay inside the workspace.
- [x] The shared PoshQC module and wrapper preserve the existing format, analysis, and Pester coverage behavior.
- [x] Tests and documentation are updated for the new bundled workflow and folder-selection behavior.

## Non-Goals

- Replacing the existing repo-root PoshQC module with a new implementation.
- Changing the existing command IDs or MCP tool semantics for unrelated workflows.
- Adding non-PowerShell quality gates to the bundled PoshQC workflow.
