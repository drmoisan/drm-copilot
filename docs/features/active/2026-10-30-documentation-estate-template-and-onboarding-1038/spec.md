# 2026-10-30-documentation-estate-template-and-onboarding — Spec

- **Issue:** #1038
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-59
- **Status:** Draft
- **Version:** 0.1

## Overview

The documentation-estate-tooling epic (#1019) delivers a docs profile and schemas, a page
checker, surface analyzers, a coverage ledger and `docs-complete` receipt, a reference generator,
docs MCP tools, CI enforcement and an authoring workflow as separate children. A consumer
repository has no single entry point that composes them: there is no epic template that plans a
documentation estate, no onboarding guide that documents every subcommand and MCP tool, and no
end-to-end test that proves the pieces work together on one fixture repository.


## Behavior

- Ship a `documentation-estate` epic template under
  `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/` (`epic.md` and
  `README.md`): wave 0 foundation (profile, information architecture, page templates, metadata,
  docs CI), wave 1 page families, and a final `docs-complete` exit gate. The template manifest is
  accepted by `/epic-plan` as a manifest path.
- Ship onboarding documentation under `docs/engineering/documentation-estate/` (`README.md`,
  `architecture.md`, `consumer-onboarding.md`, `command-reference.md`, `workflow.md`) that
  documents every `Invoke-DocsCommand.ps1` subcommand and every docs MCP tool with an example, and
  states the destination-repository prerequisite (PowerShell 7.4, per the 1020 provisional
  default). The optional python pack enables the native Python analyzer; linting is optional.
- Add an end-to-end Pester test
  `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` over an in-memory fixture
  repository with one undocumented command and one stale page.
- Add a Pester test that the template manifest has a cycle-free dependency graph under the epic
  manifest rules.


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

- Depends on 1034 (docs-enforcement-and-ci) and 900009 (docs-authoring-workflow), and
  transitively on every earlier child of #1019; the subcommands, MCP tools and roles it documents
  are defined by those children.
- Language rule (owner directive, 2026-10-30): pushed-down logic is PowerShell or bash; TypeScript
  only for MCP tools and extension commands; no new Python outside the python-pack native analyzer.
- No consumer identifier may appear in framework source or documentation.


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
- [ ] Unit coverage areas: template manifest DAG check
- [ ] Integration scenarios: end-to-end inventory, ledger, generation, docs-complete
- [ ] CLI/API examples: every subcommand and MCP tool in the onboarding guide
