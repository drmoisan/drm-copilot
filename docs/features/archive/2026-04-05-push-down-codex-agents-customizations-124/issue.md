# push-down-codex-agents-customizations (Issue #124)
title: "push-down-codex-agents-customizations - Plan"
issue: "TBD"
parent: "none"
owner: "Dan Moisan"
last_updated: "2026-04-05T13-44"
status: "Draft"
status_color: "lightgrey"
version: "0.1"
---

# push-down-codex-agents-customizations (Potential)

- Date captured: 2026-04-05
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/push-down-codex-agents-customizations/ (Issue #124)

- Issue: #124
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/124
- Last Updated: 2026-04-05
- Work Mode: full-feature

## Problem / Why

The repo already supports `drm-copilot: Push Down Copilot Customizations`, but
that publisher focuses on the bundled `.github` customization payload. A
destination workspace that needs the repo's Codex-specific orchestration assets
still requires manual copying of `.codex` and `.agents`, which makes setup
error-prone and encourages drift between the source repo and the destination
workspace.

The current gap is operational rather than conceptual: the extension and MCP
automation surface already support packaged one-way publishing flows, but there
is no parallel feature that publishes the repo's Codex agent configuration and
skill tree into another workspace.

## Proposed Behavior

Add a new one-way bundled publishing workflow for `.codex` and `.agents` that
works like the existing Copilot customization publisher but targets only those
directories.

The feature should package the source repo's `.codex` and `.agents` trees into
the extension resources, expose a destination-workspace command and matching MCP
tool, and copy the packaged trees into the destination repo while preserving the
relative directory structure under `.codex/` and `.agents/`.

The existing Copilot customization publisher must remain available and must not
change scope from `.github` content to the new Codex-specific payload.

## Acceptance Criteria (early draft)

- [ ] A bundled publisher can copy the packaged `.codex/` and `.agents/` trees
      into a destination workspace while preserving each file's relative path
      under those roots.
- [ ] The extension exposes a dedicated live command and matching repo
      automation surface for the `.codex` / `.agents` publisher without
      regressing `drm-copilot: Push Down Copilot Customizations`.
- [ ] Bundled resources for the new publisher stay aligned with the repo-root
      `.codex` and `.agents` sources and cover nested files and folders.
- [ ] Automated tests cover the publisher logic, the bundled command wiring, and
      destination-workspace execution behavior for the new scope.

## Constraints & Risks

- Preserve the current `.github` push-down command behavior and payload scope.
- The new workflow likely spans Python publisher code, TypeScript extension
  wiring, bundled resource packaging, and tests for both languages.
- Nested folder copying must remain deterministic so repeated runs are auditable
  and predictable.
- Bundled resource drift is a risk because the extension package mirrors
  repository content rather than reading directly from the source repo at
  runtime.

## Test Conditions to Consider

- [ ] Unit coverage areas
  - file enumeration and copy behavior for `.codex` and `.agents`
  - overwrite behavior and summary artifact output
  - nested directory preservation in the packaged payload
- [ ] Integration scenarios
  - extension command execution against an open destination workspace
  - MCP tool path uses the same packaged publisher surface
- [ ] CLI/API examples
  - direct publisher invocation against a destination path
  - extension command / MCP tool invocation for the same workspace

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/push-down-codex-agents-customizations/` folder from the template