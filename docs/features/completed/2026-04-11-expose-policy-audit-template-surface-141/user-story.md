# `2026-04-11-expose-policy-audit-template-surface` — User Story

- Issue: #141
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-04-11T22-03

## Story Statement

- As a workflow or review agent using the published `drmCopilotExtension` MCP server, I want to resolve the canonical policy-audit template assets through a semantic automation surface so that my prompts and skills do not depend on the source repository layout.
- As a VS Code user running the extension outside the development repository, I want a matching extension command for the policy-audit template assets so that I can access the same guidance that the MCP surface exposes.

## Problem / Why

The repository already treats many templates as published automation assets, but nothing currently exposes the policy-audit template pair through the published `drmCopilotExtension` MCP surface or through a matching extension command. Consumers that need the canonical policy-audit guidance must still depend on the repository-local path `docs/features/templates/policy_audit/AGENTS.md`, which breaks the extension-hosted automation model and keeps repository prompts and skills coupled to a source path that should instead be surfaced semantically.


## Personas & Scenarios

- Persona: Workflow author or agent maintainer
  - Maintains prompts, skills, and orchestration instructions that should target published automation surfaces rather than local source paths.
  - Cares about stable semantic contracts that work in the packaged extension and in Codex-hosted MCP environments.
  - Needs references to remain accurate after templates are bundled and published.
- Persona: Extension user in a destination workspace
  - Uses the published extension in a workspace that does not contain the repo's source template tree.
  - Needs consistent access to policy-audit guidance without cloning the development repository.
- Scenario: MCP-guided policy audit flow
  - An agent prompt needs the policy-audit guidance file.
  - The prompt references the semantic `drmCopilotExtension` policy-audit template surface instead of `docs/features/templates/policy_audit/AGENTS.md`.
  - The MCP server resolves the bundled asset from the published extension package.
  - The agent receives the correct guidance without relying on a repo-local file path.
- Scenario: Extension command access
  - A user installs the extension in a non-repo workspace.
  - The user runs the new policy-audit template command.
  - The command retrieves the requested bundled asset through the same underlying service contract used by the MCP server.
  - The user receives the policy-audit template asset without a missing-file failure tied to the repository source tree.


## Acceptance Criteria

- [x] The published `drmCopilotExtension` MCP surface exposes the bundled policy-audit template markdown file and the bundled policy-audit `AGENTS.md` guidance file through a canonical tool or resource path that is available outside the source repository layout
- [x] The VS Code extension contributes a matching command for retrieving or copying the same policy-audit template assets from the bundled extension surface
- [x] Repository references that currently hardcode `docs/features/templates/policy_audit/AGENTS.md` are redirected to the MCP server surface, or any remaining exceptions are explicitly documented with rationale
- [x] Regression coverage proves the new MCP and extension command behavior, and repository documentation or prompt references remain consistent with the published automation surface


## Non-Goals

- Rewriting or removing the source template files under `docs/features/templates/policy_audit/`
- Redirecting references to the policy-audit README or template markdown unless those references are intended to use the published automation surface
- Changing unrelated MCP tools or extension commands
