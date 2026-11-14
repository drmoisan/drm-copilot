# documentation-estate-template-and-onboarding (Issue #1038)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/documentation-estate-template-and-onboarding/ (Issue #1038)
- Parent epic: #1019 (documentation-estate-tooling), child placeholder 900010, wave 5, band C3

- Issue: #1038
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1038
- Last Updated: 2026-10-30
## Problem / Why

The documentation-estate-tooling epic (#1019) delivers a docs profile and schemas, a page
checker, surface analyzers, a coverage ledger and `docs-complete` receipt, a reference generator,
docs MCP tools, CI enforcement and an authoring workflow as separate children. A consumer
repository has no single entry point that composes them: there is no epic template that plans a
documentation estate, no onboarding guide that documents every subcommand and MCP tool, and no
end-to-end test that proves the pieces work together on one fixture repository.

## Proposed Behavior

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

## Acceptance Criteria (early draft)

- [ ] The end-to-end test runs inventory, ledger, generation and `docs-complete` validation; it
      fails naming the undocumented command and the stale page, passes after both are fixed, and
      the result records `analysis_method` per element.
- [ ] The template is accepted by `/epic-plan` as a manifest path.
- [ ] A Pester test proves the template manifest has a cycle-free dependency graph under the epic
      manifest rules.
- [ ] The onboarding guide documents every subcommand and MCP tool with an example and states the
      destination-repository prerequisite (PowerShell 7.4); it states that the optional python
      pack enables the native Python analyzer and that linting is optional.
- [ ] No test creates temporary files.

## Constraints & Risks

- Depends on 1034 (docs-enforcement-and-ci) and 900009 (docs-authoring-workflow), and
  transitively on every earlier child of #1019; the subcommands, MCP tools and roles it documents
  are defined by those children.
- Language rule (owner directive, 2026-10-30): pushed-down logic is PowerShell or bash; TypeScript
  only for MCP tools and extension commands; no new Python outside the python-pack native analyzer.
- No consumer identifier may appear in framework source or documentation.

## Test Conditions to Consider

- [ ] Unit coverage areas: template manifest DAG check
- [ ] Integration scenarios: end-to-end inventory, ledger, generation, docs-complete
- [ ] CLI/API examples: every subcommand and MCP tool in the onboarding guide

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/documentation-estate-template-and-onboarding/` folder from the template
