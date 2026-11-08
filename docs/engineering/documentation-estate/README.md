# Documentation Estate

This folder documents the documentation-estate tooling: the PowerShell helpers under
`.claude/lib/docs/`, the docs MCP tools, the documentation roles and skills, and the epic template
that plans a documentation estate. The tooling inventories the documentable surface of a
repository, generates reference pages, records a disposition for every element in a coverage
ledger, and proves documentation correspondence with a `docs-complete` receipt.

## Domain-Neutrality Invariant

The framework code, schemas, templates and these pages name no consumer repository, product or
domain. Repository specificity lives only in the docs profile of the repository that adopts the
tooling. A neutrality test hashes the tokens of the framework files and of these pages and fails
when a configured consumer-identifier digest matches.

## Ownership

The tooling is maintained in this repository. Changes to a helper, schema, hook, skill, agent or
MCP tool are made in the owning source path listed under `## Capability Provenance`, and these pages
are updated in the same change when a subcommand, option, tool or finding code changes. The Pester
suite `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` fails when a
subcommand or docs MCP tool has no heading and example in `command-reference.md`.

## Audience

- Maintainers of a repository that adopts the tooling: read `consumer-onboarding.md`, then
  `command-reference.md`.
- Contributors who change the tooling: read `architecture.md`.
- Agents and reviewers who author documentation: read `workflow.md`.

## Topic Pages

| Page | Content |
|---|---|
| [architecture.md](architecture.md) | Helper root, entry script and dispatch table, command context, schemas, analyzers, `analysis_method`, ledger, parity matrix, evidence pins, receipt, generated blocks, MCP wrappers and the opt-in hook |
| [consumer-onboarding.md](consumer-onboarding.md) | Prerequisites, the optional python pack, optional linting, adoption steps, consumer CI and the epic template |
| [command-reference.md](command-reference.md) | Common parameters, exit codes, the JSON envelope, every subcommand and every docs MCP tool with examples |
| [workflow.md](workflow.md) | Documentation roles and skills, the authoring sequence, receipt persistence, the integration-PR gate and the surface-delta review step |

## Capability Provenance

| Capability | Source |
|---|---|
| Entry script and dispatch table | `.claude/lib/docs/Invoke-DocsCommand.ps1` |
| Helper modules | `.claude/lib/docs/` |
| Artifact schemas | `schemas/docs/v1/` (runtime copy `.claude/lib/docs/schemas/v1/`) |
| Starter templates written by `init` | `.claude/lib/docs/templates/` |
| Native Python analyzer (python pack) | `.claude/lib/docs/python/` |
| Docs MCP tool definitions and inputs | `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts` |
| Integration-PR gate hook | `.claude/hooks/enforce-docs-complete-gate.ps1` |
| Roles | `.claude/agents/docs-architect.md`, `.claude/agents/docs-author.md`, `.claude/agents/docs-reconciler.md`, `.claude/agents/docs-coverage-reviewer.md` |
| Skills | `.claude/skills/documentation-workflow/` and the `docs-*` skills under `.claude/skills/` |
| Epic template | `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/` |
| Tests | `tests/scripts/claude-lib/docs/` |
