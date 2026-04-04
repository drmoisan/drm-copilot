# `2026-03-21-bundle-sync-agents` — User Story

- Issue: #113
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-21T20-41

## Story Statement

- As a maintainer pushing bundled copilot tooling into another workspace, I want to run `AGENTS.md` sync from the VS Code extension command surface, so that I can regenerate the destination workspace's agent instructions without leaving the extension workflow.
- As a repository maintainer evolving `.github` instruction files, I want `AGENTS.md` generation to discover supported instruction sources automatically, so that new or reorganized instruction files are included on the next sync run without script maintenance drift.

## Problem / Why

The repository already has `scripts/dev-tools/sync-agents-from-instructions.ps1`, but it is not exposed through the VS Code extension command surface that currently drives other destination-workspace workflows. Users who push bundled tooling into another workspace can sync customization files there, but they cannot trigger `AGENTS.md` regeneration from the extension in the same way.

The current script also hard-codes a fixed section list and rewrites section titles instead of discovering the canonical instruction sources that actually exist under `.github/`. That makes the sync brittle when new instruction files are added, renamed, or reorganized, and creates drift between the generated `AGENTS.md` content and the instruction set the repo actually ships.


## Personas & Scenarios

- Persona: Repository maintainer using the bundled extension workflow
  - Works on this repository and pushes bundled customization and tooling into other workspaces.
  - Cares that extension commands operate on the active destination workspace rather than the extension installation directory.
  - Needs deterministic generated output because `AGENTS.md` is derived content that should not drift across repeated runs or across machines.
  - Is constrained by the current extension command surface: related workspace-targeted workflows are available there today, but `AGENTS.md` sync is not.
  - Wants newly added instruction files under the supported `.github` discovery scope to appear automatically without having to update a hard-coded section list.
- Scenario: Syncing agent instructions after pushing bundled customization content into a workspace
  - A repository maintainer opens a destination workspace that already contains the expected `.github` instruction sources.
  - After using the extension-driven workflow that pushes bundled customization content, the maintainer needs the workspace's generated `AGENTS.md` to reflect the current instruction set.
  - The maintainer runs the new `drm-copilot: Sync AGENTS.md from Instructions` command from the Command Palette.
  - The extension resolves the open workspace root, executes the bundled PowerShell sync workflow against that workspace, and the script discovers `.github/copilot-instructions.md` plus supported `*.instructions.md` files under `.github/`.
  - If the required sources are present, the maintainer expects a regenerated, deterministic `AGENTS.md`; if the sources are missing, the maintainer expects an actionable failure instead of partial output.


## Acceptance Criteria

- [x] The extension contributes a new command for syncing `AGENTS.md`, and invoking it runs the bundled sync workflow against the open workspace root rather than the extension installation directory.
- [x] The bundled sync workflow reads `.github/copilot-instructions.md` and discovers instruction sources under `.github/` from the destination workspace instead of depending on a hard-coded section-definition array.
- [x] The generated `AGENTS.md` includes the canonical repository instructions plus the discovered instruction bodies in a deterministic order, strips YAML frontmatter from source files, and produces identical output on repeated runs when inputs have not changed.
- [x] If the destination workspace is missing required source files such as `.github/copilot-instructions.md` or has no discoverable instruction files, the command fails with an actionable error message instead of generating partial or misleading output.
- [x] Adding a new instruction file under the supported `.github/` discovery scope causes the next sync run to include it automatically without requiring a code change to the sync script.


## Non-Goals

- Changing the semantics or authoring format of the underlying instruction files themselves.
- Expanding the discovery scope beyond the documented `.github/copilot-instructions.md` preamble and supported `*.instructions.md` files under `.github/`.
- Aggregating `.prompt.md`, `.agent.md`, generated outputs, or other non-instruction assets into `AGENTS.md`.
- Replacing the existing repository-local PowerShell entrypoint; direct script invocation remains supported.
- Introducing new runtime dependencies, feature flags, or unrelated extension command behavior beyond the `AGENTS.md` sync workflow.
