# docs-authoring-workflow — Spec

- **Issue:** #1037
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-59
- **Status:** Draft
- **Version:** 0.1

## Overview

The documentation-estate-tooling epic (#1019) delivers a docs profile, surface analyzers, a page
checker, a coverage ledger with a `docs-complete` receipt, a reference generator and six docs MCP
tools. Without constrained documentation roles and reusable skills, a consumer repository still has
to hand-orchestrate inventory, information-architecture planning, page authoring, behavior
reconciliation and coverage review, and an unconstrained agent could edit the ledger or parity
matrix directly instead of going through the single mutation boundary (`update-ledger`).


## Behavior

- Four documentation roles under `.claude/agents/`: `docs-architect`, `docs-author`,
  `docs-reconciler`, `docs-coverage-reviewer`. Tool allowlists use the docs MCP tools
  (`run_docs_check`, `run_docs_inventory`, `run_docs_coverage`, `update_docs_ledger`,
  `generate_docs_reference`, `validate_docs_artifacts`) and grant no direct Write or Edit on ledger
  or matrix artifacts; no `memory:` frontmatter (it grants Write and Edit).
- Eight skills under `.claude/skills/`: `documentation-workflow`, `docs-init`,
  `docs-inventory-surface`, `docs-plan-ia`, `docs-author-page` (with page templates: tutorial,
  how-to, explanation, cli-reference, http-reference, config-reference, api-reference,
  architecture-overview), `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`.
  Skills call `.claude/lib/docs/Invoke-DocsCommand.ps1` subcommands or the six docs MCP tools; any
  new skill helper is PowerShell.
- Mirrors produced by the existing repository generators (existing Python tooling, called, not
  extended): `.github/agents/`, `.github/skills/`, `.codex/agents/` variants, `.agents/skills/`,
  and the push-down trees under `extensions/drm-copilot/resources/claude-customizations/` and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- A PowerShell SubagentStop output check for the four roles with a Pester suite, registered in
  `.claude/settings.json`, and role routing entries in `config/orchestration-routing.json`.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- Language rule (owner directive 2026-10-30, refined): pushed-down skills, skill helpers, hooks and
  libs are PowerShell or bash; TypeScript only for MCP and extension commands; no new Python.
- Depends on the docs MCP tools child (900007), prepared concurrently; tool names are fixed in the
  epic naming contract.
- Codex reach of the docs lib is owner question Q7 (provisional default: Claude bundle only).


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Pester suite for the SubagentStop output check (pass and block cases per role)
- [ ] Tool-allowlist test over the four agent files
- [ ] Mirror and push-down parity tests for agents and skills
