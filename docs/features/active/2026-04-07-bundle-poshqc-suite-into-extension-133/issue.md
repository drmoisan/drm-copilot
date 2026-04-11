# bundle-poshqc-suite-into-extension (Issue #133)

- Date captured: 2026-04-07
- Author: Dan Moisan
- Status: Active -> docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/ (Issue #133)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub feature issue template.

- Issue: #133
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/133
- Last Updated: 2026-04-07
- Work Mode: full-feature

## Summary

The extension already bundles several Python and PowerShell workflows and executes them against the active destination workspace, but it does not currently expose the repo's PoshQC PowerShell quality suite through that same self-contained extension surface. Contributors still have to depend on repo-local `scripts/powershell/PoshQC` assets, which breaks the extension's packaged-workflow model and prevents non-repo consumers from using the same PowerShell quality tooling through the VS Code command or MCP bridge.

This feature should bundle the PoshQC suite into the extension package, expose a stable command/tool to run it against the destination workspace, and let users choose which destination-workspace folders are scanned for PowerShell file discovery.

## Environment

- OS/version: Windows 11
- Extension: drm-copilot 0.0.1
- Surfaces in scope: VS Code command palette, extension MCP bridge, bundled PowerShell resources
- Destination workspace behavior: execute bundled assets from the extension package while scanning PowerShell files under the destination workspace

## Steps to Reproduce

1. Open a workspace that contains PowerShell scripts and tests.
2. Inspect the extension command list and MCP tool surface.
3. Observe there is no bundled PoshQC workflow equivalent to the other workspace-targeted bundled scripts.
4. Attempt to use PoshQC through the extension package alone and observe the workflow is unavailable.

## Expected Behavior

The extension should expose a bundled PoshQC suite that runs from extension resources, targets the destination workspace, and supports selecting which destination-workspace folders are scanned.

## Actual Behavior

No bundled PoshQC workflow currently exists in the extension command or MCP surfaces.

## Logs / Screenshots

- [x] Static repo inspection is sufficient for the missing-surface gap
- Snippet: `extensions/drm-copilot/resources/templates/` currently contains no PoshQC runner and `extensions/drm-copilot/src/repo-automation-service.ts` exposes no PoshQC tool.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- The repo-root PoshQC module exists only under `scripts/powershell/PoshQC/`.
- The extension service and MCP bridge only expose the existing repo-automation workflows.
- No bundled wrapper currently bridges destination-workspace folder selection into the PowerShell quality tooling.

## Proposed Fix / Validation Ideas

- [x] Add a repo-root `run-poshqc-suite.ps1` entrypoint and bundle an identical extension template copy.
- [x] Bundle the PoshQC module and settings files under extension resources.
- [x] Add a new extension command plus MCP tool for running the bundled PoshQC suite against the destination workspace.
- [x] Support explicit destination-workspace folder selection for PowerShell scan scope.
- [x] Add parity and behavior tests for the root/bundled PowerShell assets and the TypeScript service/command/MCP surfaces.
- [x] Update README documentation for the new extension capability and prerequisites.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create active feature folder / branch
- [x] Author spec, user story, and implementation plan
