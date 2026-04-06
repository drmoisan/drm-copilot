# `push-down-codex-agents-customizations` — User Story

- Issue: #124
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-04-05T13-45

## Story Statement

- As a repository maintainer, I want a dedicated bundled workflow that pushes
  `.codex` and `.agents` into a destination repo so that Codex-specific agent
  configuration and skills can be installed without manual copying.
- As an orchestration workflow author, I want the same capability available
  through the semantic MCP repo-automation surface so that automation can set
  up a destination workspace without relying on raw VS Code command IDs.

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


## Personas & Scenarios

- Persona: Repository maintainer
  - Maintains the source repo's Codex runtime conventions.
  - Wants packaged destination setup to remain deterministic and low-friction.
  - Cannot rely on every destination workspace having the source repo mounted.
- Persona: Orchestration author
  - Uses the shared repo-automation adapter and semantic MCP tools.
  - Needs a stable host-agnostic surface for destination-workspace bootstrap.
- Scenario: Push Codex runtime assets into a destination repo
  - A maintainer opens a target repo in VS Code after installing the extension.
  - They run a dedicated push-down command for Codex/agents assets.
  - The extension executes a bundled Python wrapper against the open workspace.
  - The bundled payload copies `.codex` and `.agents` into the destination repo.
  - The maintainer expects nested files to preserve their relative paths and a
    summary artifact to record what was copied.
- Scenario: Invoke the same operation from orchestration
  - An automation workflow resolves a destination workspace root.
  - It calls the semantic MCP tool for the Codex/agents publisher.
  - The shared repo-automation service executes the same bundled publisher
    surface used by the interactive command.
  - The workflow expects the operation to complete without changing the scope of
    the existing `.github` push-down command.


## Acceptance Criteria

- [x] A bundled publisher can copy the packaged `.codex/` and `.agents` trees into a destination workspace while preserving each file's relative path under those roots.
- [x] The extension exposes a dedicated live command and matching repo-automation surface for the `.codex` / `.agents` publisher without regressing `drm-copilot: Push Down Copilot Customizations`.
- [x] Bundled resources for the new publisher stay aligned with the repo-root `.codex` and `.agents` sources and cover nested files and folders.
- [x] Automated tests cover the publisher logic, the bundled command wiring, and destination-workspace execution behavior for the new scope.


## Non-Goals

- Expanding `drm-copilot: Push Down Copilot Customizations` to copy `.codex` or `.agents`.
- Replacing or removing the existing `.github` push-down workflow.
- Introducing GitHub-side automation beyond the existing repo-automation and extension surfaces.
