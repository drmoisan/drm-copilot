# push-down-codex-agents-customizations — Spec

- **Issue:** #124
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-05T13-45
- **Status:** Draft
- **Version:** 0.1

## Overview

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

## Behavior

Add a new one-way bundled publishing workflow for `.codex` and `.agents` that
works like the existing Copilot customization publisher but targets only those
directories.

The feature should package the source repo's `.codex` and `.agents` trees into
the extension resources, expose a destination-workspace command and matching MCP
tool, and copy the packaged trees into the destination repo while preserving the
relative directory structure under `.codex/` and `.agents/`.

The existing Copilot customization publisher must remain available and must not
change scope from `.github` content to the new Codex-specific payload.

On the main path, a user opens a destination workspace, runs a dedicated command
for Codex/agents customizations, and the extension executes a bundled Python
wrapper against that workspace root. The bundled publisher copies the packaged
`.codex` and `.agents` trees into the destination repo, preserving the relative
layout under those roots, and writes a JSON summary artifact under a dedicated
artifact folder in the destination workspace.

On alternative paths, the same functionality is available through the semantic
MCP tool surface so orchestration skills can invoke the publisher without
depending on raw VS Code command IDs. The existing `.github` publisher remains a
separate command and separate MCP tool with unchanged behavior.

## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Extension command invocation: `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`
- Semantic MCP tool invocation: `push_down_codex_and_agents_customizations`
- Bundled wrapper CLI: `python push_down_codex_and_agents_customizations.py --destination <workspace-root>`
- Bundled payload source roots:
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/**`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/**`
- Repo-root Python entry point:
  - `poetry run python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <workspace-root>`
- Config keys and defaults:
- No environment variables are required by the documented feature surface.
- Outputs (artifacts, logs, telemetry)
  - Destination-repo file writes under `.codex/**` and `.agents/**`
  - JSON summary artifact under `artifacts/codex-and-agents-customizations/`
  - Existing extension output channel success/failure logging through the shared runtime
- Versioning or backward-compatibility constraints:
  - `drmCopilotExtension.pushDownCopilotCustomizations` remains `.github`-only
  - `push_down_copilot_customizations` remains `.github`-only
  - The new feature is additive and does not change the current `.github` payload contract

## API / CLI Surface

- Extension command contribution
  - Command ID: `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`
  - Command title: `drm-copilot: Push Down Codex and Agents Customizations`
- Semantic MCP tool
  - Tool name: `push_down_codex_and_agents_customizations`
  - Input shape: `{ "workspace_root"?: string }`
- Python entry point
  - Module: `scripts.dev_tools.push_down_codex_and_agents_customizations`
  - Required flag: `--destination <workspace-root>`
- Example invocations with expected outputs (concise):
  - VS Code: run `drm-copilot: Push Down Codex and Agents Customizations`; expected result is the packaged `.codex` and `.agents` payload copied into the open workspace plus a summary artifact under `artifacts/codex-and-agents-customizations/`.
  - MCP: call `push_down_codex_and_agents_customizations` with `workspace_root` set to a repo path; expected result is the same copied payload and summary artifact path surfaced through the repo-automation service.
  - Python: `poetry run python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination C:\work\target-repo`; expected result is the same copied payload and summary artifact path.
- Contracts and validation rules:
  - The destination must exist and must not equal the source repo root.
  - Nested files and folders under `.codex` and `.agents` must retain their relative paths.
  - The JSON summary artifact must record created/overwritten counts and per-file outcomes.
  - No `.github` content is copied by the new publisher.
  - No command-reference rewrite behavior is applied unless the copied content explicitly requires it in future scope.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
  - Source enumeration order must be deterministic by configured root and relative path.
  - The new bundled payload mirrors the repo-root `.codex` and `.agents` trees.
  - The existing `.github` push-down publisher keeps its own payload root and artifact directory.
- Caching or persistence details:
  - No cache is introduced.
  - Persistent outputs are limited to copied destination files and the summary artifact.
- Migration or backfill requirements (if any):
  - No migration is required for existing consumers of the `.github` publisher.
  - Destination workspaces opt in by invoking the new command or MCP tool.

## Constraints & Risks

- Preserve the current `.github` push-down command behavior and payload scope.
- The new workflow likely spans Python publisher code, TypeScript extension
  wiring, bundled resource packaging, and tests for both languages.
- Nested folder copying must remain deterministic so repeated runs are auditable
  and predictable.
- Bundled resource drift is a risk because the extension package mirrors
  repository content rather than reading directly from the source repo at
  runtime.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
  - Make the existing Python publisher engine configurable for root folders, artifact directory, and text-rewrite behavior.
  - Add a new Python entry point dedicated to `.codex` and `.agents`.
  - Bundle the new publisher module and a thin Python wrapper into the extension.
  - Add a new resource payload tree that mirrors the repo-root `.codex` and `.agents` content.
  - Add extension command, repo-automation service support, semantic MCP tool exposure, and targeted tests.
- New classes/functions/commands to add or update:
  - `scripts/dev_tools/push_down_copilot_customizations.py`
  - `scripts/dev_tools/push_down_codex_and_agents_customizations.py`
  - `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations.py`
  - `extensions/drm-copilot/resources/scripts/dev_tools/push_down_codex_and_agents_customizations.py`
  - `extensions/drm-copilot/resources/templates/push_down_codex_and_agents_customizations.py`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/**`
  - `extensions/drm-copilot/src/extension.ts`
  - `extensions/drm-copilot/src/repo-automation-service.ts`
  - `extensions/drm-copilot/src/mcp-tools.ts`
  - `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - `extensions/drm-copilot/package.json`
  - `README.md`
  - `extensions/drm-copilot/README.md`
- Dependency changes (new/removed packages) and rationale:
  - No new runtime dependencies are required.
- Logging/telemetry additions and locations:
  - Reuse the existing bundled-script runtime logging path and the repo-automation service summary surface.
- Rollout plan (feature flags, staged deploys, fallback path):
  - No feature flag is required.
  - Repository-local Python invocation remains available as a deterministic fallback path.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, docs/features/active/... links)
- [x] Telemetry/logging added or updated (if applicable)
- [x] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage areas
- file enumeration and copy behavior for `.codex` and `.agents`
- overwrite behavior and summary artifact output
- nested directory preservation in the packaged payload
- [x] Integration scenarios
- extension command execution against an open destination workspace
- MCP tool path uses the same packaged publisher surface
- [x] CLI/API examples
- direct publisher invocation against a destination path
- extension command / MCP tool invocation for the same workspace
