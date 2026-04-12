# Feature Audit: bundle-link-parent-child-into-extension (#144)

**Audit Date:** 2026-04-12  
**Timestamp:** 2026-04-12T15-33  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144`

## Scope and Baseline

- **Base branch:** `development`
- **Head ref context:** `feature/bundle-link-parent-child-into-extension-144`
- **Work mode:** `full-feature`
- **Authoritative acceptance-criteria source files:** `spec.md` and `user-story.md`
- **Evidence sources used:**
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
  - `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/phase0-instructions-read.2026-04-12T15-09.md`
  - `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/requirements-snapshot.2026-04-12T15-29.md`
  - `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/other/link-parent-child-surface-inventory.2026-04-12T15-09.md`
  - `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/toolchain-summary.2026-04-12T15-29.md`

## Acceptance Criteria Inventory

Source: `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/user-story.md`

1. The published extension contributes a `link-parent-child` command that prompts for child issue number and parent tracking issue number, then executes the bundled workflow rather than the workspace script path.
2. The repo automation service runs a bundled copy or wrapper for the parent/child-link workflow and preserves the existing script behavior and CLI contract except for any minimal additive seams required for bundling.
3. The MCP bridge exposes a semantic `link-parent-child` tool with explicit child and parent issue inputs and dispatches the request through the same bundled automation surface.
4. Tests cover command registration, interactive prompting, direct invocation parsing, repo automation service execution, MCP input normalization, MCP dispatch, and bundled-script expectations.

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|-----------|--------|----------|--------------------------|-------|
| AC-1 | PASS | `extensions/drm-copilot/package.json`, `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/test/extension.workflow-commands.test.ts`, `extensions/drm-copilot/test/extension.integration.test.ts` | `npm --prefix extensions/drm-copilot run test:unit` | Interactive prompting and bundled-path execution are covered. |
| AC-2 | PASS | `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/resources/templates/link-parent-child.ps1`, `extensions/drm-copilot/test/repo-automation-service.test.ts` | `npm --prefix extensions/drm-copilot run test:unit`; `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '.' }"` | The PowerShell parameter names remain unchanged. |
| AC-3 | PASS | `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tools.ts`, `extensions/drm-copilot/test/mcp-tool-inputs.test.ts`, `extensions/drm-copilot/test/mcp-server.test.ts` | `npm --prefix extensions/drm-copilot run test:unit` | MCP callers must provide explicit child and parent issue numbers. |
| AC-4 | PASS | Updated Jest suites for workflow arguments, command routing, integration path, service dispatch, MCP normalization, and MCP dispatch | `npm --prefix extensions/drm-copilot run test:unit`; `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '.' }"` | The legacy task path remains only as a legacy workspace task, not as the published extension runtime path. |

## Summary

**Overall feature readiness:** **PASS**

What is verified:
- The bundled PowerShell asset exists in the extension package.
- The extension command and MCP tool both route through the shared repo-automation service.
- Direct and interactive inputs are validated before execution.
- The final relevant toolchain commands passed successfully.

What remains open:
- None.

## Acceptance Criteria Check-off

- `spec.md` acceptance and Definition of Done checklists were updated to reflect the verified implementation.
- `user-story.md` acceptance-criteria checkboxes were updated to reflect the verified implementation.
- `issue.md` acceptance and test-condition checklists were updated to reflect the verified implementation.
