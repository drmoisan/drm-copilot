<!-- markdownlint-disable-file -->

# Task Research Notes: Push Down Codex and Agents Customizations (Issue #124)

## Research Executed

### File Analysis

- `scripts/dev_tools/push_down_copilot_customizations.py`
  - Current Python publisher already handles deterministic file enumeration, overwrite-aware writes, summary artifact emission, bundled-source execution, and optional source/artifact root overrides.
  - The only `.github`-specific assumptions are the scoped root list, artifact directory constant, CLI description text, and the rewrite helper used for copied text.
- `scripts/dev_tools/push_down_copilot_customizations_rewrites.py`
  - Rewrite catalog currently maps copied `.github` documentation references to live extension commands.
  - No rewrite behavior appears necessary for `.codex` or `.agents` payload files based on current repo search.
- `scripts/dev_tools/agentic_sync.py`
  - Defines the current `.github` root-folder tuple used by the existing push-down publisher.
- `extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py`
  - Shows the canonical bundled Python wrapper pattern: prepend `resources/scripts` to `sys.path`, import a bundled publisher module, resolve a bundled payload root, use `Path.cwd()` for artifact placement, and forward `--destination`.
- `extensions/drm-copilot/src/extension.ts`
  - Registers the live `pushDownCopilotCustomizations` command through the shared repo-automation service.
- `extensions/drm-copilot/src/repo-automation-service.ts`
  - Centralizes semantic repo-automation tool names, bundled script paths, summaries, and MCP-facing execution behavior.
- `extensions/drm-copilot/src/mcp-tools.ts`
  - Publishes semantic MCP tool definitions and dispatch wiring.
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - Defines input normalization for each semantic repo-automation tool.
- `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`
  - Covers file copying and rewrite behavior for the existing `.github` publisher.
- `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`
  - Covers helper-focused behavior such as explicit source roots, explicit artifact roots, destination validation, and CLI success output.
- `extensions/drm-copilot/test/extension.test.ts`
  - Covers command registration through `activate()`.
- `extensions/drm-copilot/test/extension.integration.test.ts`
  - Covers bundled execution path, runtime selection, bundled script path resolution, and destination-workspace argument forwarding for live commands.
- `extensions/drm-copilot/test/mcp-server.test.ts`
  - Covers MCP tool exposure and dispatch to the repo-automation service.
- `.codex/**` and `.agents/**`
  - Current source trees include `.codex/config.toml`, `.codex/agents/*.toml`, `.agents/README.md`, and `.agents/skills/**`.
  - These are the concrete payload roots required by the feature.

### Code Search Results

- `pushDownCopilotCustomizations|push_down_copilot_customizations`
  - Found the complete implementation seam for the existing push-down workflow across Python publisher code, bundled extension wrappers, command registration, service, MCP exposure, and tests.
- `drmCopilotExtension` across `.codex` and `.agents`
  - Found no current `.codex` or `.agents` files that require script-reference rewrite behavior analogous to the `.github` publisher's rewrite catalog.
- `.codex|.agents`
  - Confirmed the payload is rooted in exactly two top-level trees and already exists in the working repo with nested content that can be mirrored into a bundled extension payload directory.

### Project Conventions

- Preserve the existing `push_down_copilot_customizations` workflow and command surface; add a sibling flow instead of broadening the `.github` publisher's semantic scope.
- Keep bundled Python wrappers thin and execute packaged publisher logic in-process.
- Use the shared repo-automation service and semantic MCP tool surface instead of wiring bespoke command execution paths.

## Key Discoveries

### Existing Publisher Is Already Mostly Generic

The current `.github` publisher already supports:

- explicit `source_root` for bundled execution,
- explicit `artifact_root` for destination-scoped artifact placement,
- deterministic root-ordered enumeration,
- overwrite-aware file writes,
- structured JSON summary artifacts.

The only hard-coded `.github` assumptions are small enough that the current implementation can be made reusable without changing the user-facing behavior of the existing command.

### A Sibling Publisher Is Cleaner Than Expanding Scope

The user asked for a new feature that behaves similarly to `Push Down Copilot Customizations` but focuses on `.codex` and `.agents` only. Keeping the existing publisher scoped to `.github` and introducing a sibling publisher avoids:

- silent behavior changes for the existing command,
- mixed payloads in one artifact stream,
- confusing command semantics around whether `.github`, `.codex`, and `.agents` are all pushed by the same operation.

### Rewrite Behavior Should Stay Specific To `.github`

Current `.agents` and `.codex` content does not contain the raw script references that drove the `.github` rewrite catalog. That makes a no-op rewrite path the correct default for the new publisher and keeps the `.github` rewrite logic from bleeding into the Codex/agents payload.

## Chosen Design

1. Keep `push_down_copilot_customizations` as the `.github`-only publisher.
2. Make its internal engine configurable for:
   - root folders,
   - artifact directory,
   - text-rewrite function.
3. Add a new Python entry point:
   - `scripts.dev_tools.push_down_codex_and_agents_customizations`
4. Add a new bundled payload root:
   - `extensions/drm-copilot/resources/codex-and-agents-customizations/`
5. Add a new bundled Python wrapper:
   - `extensions/drm-copilot/resources/templates/push_down_codex_and_agents_customizations.py`
6. Add a new extension command and matching semantic MCP tool:
   - Command ID: `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`
   - MCP tool: `push_down_codex_and_agents_customizations`
7. Add targeted tests for:
   - new Python publisher behavior,
   - resource-bundle parity for `.codex` and `.agents`,
   - command registration and bundled execution,
   - MCP tool exposure and dispatch.

## Constraints Driving Implementation

- The new feature must not regress the existing `.github` publisher or its command/tool IDs.
- Bundled payload files must be mirrored into extension resources because the extension cannot rely on reading the source repo at runtime.
- Tests must remain deterministic and avoid temp files or external services.
