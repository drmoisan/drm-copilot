# 2026-04-11-expose-policy-audit-template-surface — Spec

- **Issue:** #141
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-11T22-03
- **Status:** Draft
- **Version:** 0.1

## Overview

The repository already treats many templates as published automation assets, but nothing currently exposes the policy-audit template pair through the published `drmCopilotExtension` MCP surface or through a matching extension command. Consumers that need the canonical policy-audit guidance must still depend on the repository-local path `docs/features/templates/policy_audit/AGENTS.md`, which breaks the extension-hosted automation model and keeps repository prompts and skills coupled to a source path that should instead be surfaced semantically.

## Behavior

Extend the canonical `drmCopilotExtension` automation surface so it can return both `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` and `docs/features/templates/policy_audit/AGENTS.md` from the published extension bundle. Add a matching extension command for the same capability, then replace repository references that currently hardcode `docs/features/templates/policy_audit/AGENTS.md` so they point to the MCP server surface rather than the local repository path.

## Inputs / Outputs

- Inputs:
  - workspace root
  - a requested policy-audit asset identifier or canonical selector when the tool supports choosing between `policy-audit` template markdown and `AGENTS.md`
  - optional destination or copy behavior if the extension command writes a file into the workspace rather than returning content or a resolved source path
- Outputs:
  - a deterministic MCP response that identifies which asset was requested and how it was resolved from the bundled extension surface
  - extension command output that either opens the resolved bundled asset or copies it into the workspace using a documented destination path
  - updated repo prompts, skills, or customization payloads that reference the semantic MCP surface instead of the local `docs/features/templates/policy_audit/AGENTS.md` path
- Config keys and defaults:
  - preserve current defaults for all existing commands and tools
  - any new selector should default to a stable asset choice only when that behavior is explicit in the tool contract
- Versioning or backward-compatibility constraints:
  - additive only; existing command IDs and MCP tools must continue to behave exactly as they do today
  - the repository source template files remain authoritative source artifacts and must not be deleted or renamed

## API / CLI Surface

The new surface should follow the existing semantic naming pattern already used by the extension and MCP server.

- MCP surface:
  - expose a canonical policy-audit template access tool or resource through `drmCopilotExtension`
  - support both bundled assets:
    - `policy-audit.yyyy-MM-ddTHH-mm.md`
    - `AGENTS.md`
  - validate asset selection and fail fast with a clear error when an unsupported asset is requested
- Extension command surface:
  - contribute a matching command in `extensions/drm-copilot/package.json`
  - route the command through the existing extension service and argument-normalization path where practical
  - keep the command additive; do not repurpose an unrelated command
- Repository reference contract:
  - current workflow assets that instruct users or agents to read `docs/features/templates/policy_audit/AGENTS.md` must be rewritten to reference the new MCP surface
  - if a historical archive or immutable evidence artifact is left unchanged, record that exception explicitly in the implementation notes

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
  - resolve policy-audit assets from the published extension bundle, not from the active repository checkout
  - map any asset selector to one and only one canonical bundled file
  - keep the source repo templates unchanged so the sync pipeline can continue to publish from them
- Caching or persistence details:
  - no durable cache is required unless an existing template-resolution helper already persists copied outputs
  - any copied workspace artifact must preserve source content without inline mutation
- Migration or backfill requirements:
  - current source prompts and skills should be updated in place
  - archived evidence may remain unchanged when it functions as historical record rather than active instruction surface

## Constraints & Risks

- Preserve existing command and MCP behavior unless the new policy-audit template-access capability requires an additive extension.
- Do not remove the source template files under `docs/features/templates/policy_audit/`; they remain the source artifacts.
- Keep the adapter model consistent with existing semantic MCP tooling patterns such as `resolve_execute_hard_lock_prompt`.
- Redirect only references to `docs/features/templates/policy_audit/AGENTS.md`; references to the README or template markdown may remain local if they are still source-artifact references.
- The change is expected to touch TypeScript extension code, bundled resources, extension registration, and repository prompts or skills. This is outside the 1-3 file small-path budget.


## Implementation Strategy

- Implementation scope:
  - TypeScript extension command, service, and MCP registration updates
  - bundled extension asset exposure for the two policy-audit template files
  - repository prompt or skill reference redirection for `policy_audit/AGENTS.md`
  - regression tests covering new behavior
- New classes/functions/commands to add or update:
  - service entry point for policy-audit template access
  - MCP metadata and handler registration
  - command manifest contribution and command handler
  - test helpers or fixtures for bundled asset resolution
- Dependency changes:
  - no new external dependency should be added unless implementation evidence proves it is unavoidable
- Logging/telemetry additions and locations:
  - use existing extension logging patterns if command or tool resolution failures need new diagnostics
- Rollout plan:
  - additive release through the extension package
  - preserve repo-local template files as source inputs
  - update active instructional references after the semantic MCP surface exists

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: MCP tool registration, input validation, server exposure, and extension command registration or dispatch
- [ ] Integration scenarios: retrieve the policy-audit template assets from the published `drmCopilotExtension` MCP surface in a workspace that does not rely on the repo-local template path
- [ ] CLI/API examples: verify any published command or tool arguments and response payloads used by prompts, skills, or lifecycle automation
