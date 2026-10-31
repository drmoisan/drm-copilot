# `2026-10-30-documentation-estate-template-and-onboarding` — User Story

- Issue: #1038
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-31

## Story Statement

- As a consumer-repository maintainer planning a documentation estate, I want a ready-made
  `documentation-estate` epic manifest that `/epic-plan` accepts, so that I can start from a
  foundation, page-family and exit-gate plan instead of assembling it from the child
  specifications.
- As a consumer-repository maintainer adopting the docs tooling, I want onboarding pages that
  state the prerequisites and document every `Invoke-DocsCommand.ps1` subcommand and every docs
  MCP tool with an example, so that I can run the tooling without reading feature specifications.
- As a framework maintainer, I want an end-to-end test over one in-memory fixture repository, so
  that a contract mismatch between the docs children fails in this repository's CI rather than in a
  consumer repository.

## Problem / Why

The documentation-estate-tooling epic (#1019) delivers a docs profile and schemas, a page checker,
surface analyzers, a coverage ledger and `docs-complete` receipt, a reference generator, docs MCP
tools, CI enforcement and an authoring workflow as separate children. A consumer repository has no
single entry point that composes them: there is no epic template that plans a documentation estate,
no onboarding guide that documents every subcommand and MCP tool, and no end-to-end test that
proves the pieces work together on one fixture repository.

## Personas & Scenarios

- Persona: consumer-repository maintainer
  - Maintains a repository that receives the pushed-down Claude customizations.
  - Cares about documentation that stays in correspondence with code, with a receipt CI can check.
  - Constraints: the destination may have PowerShell only; Python, Node.js and linters may be
    unavailable.
  - Goal: plan and run a documentation estate with the tooling as shipped.
- Persona: framework maintainer
  - Maintains the docs children in this repository.
  - Cares about the children agreeing on subcommand names, options, envelopes and finding codes.
  - Goal: a single test that fails when the composed workflow breaks.
- Scenario: planning a documentation estate
  1. The maintainer copies the template `epic.md` to `docs/features/epics/<slug>/epic.md`, as the
     template `README.md` instructs, and adjusts `epic`, `integration_branch` and `created_at`.
  2. The maintainer runs `/epic-plan` with that path; the planner reads a manifest with a
     cycle-free graph: foundation children, then page families, then the `docs-complete` exit gate.
  3. Expected outcome: child issues are promoted and placeholders back-filled without manual
     manifest repair.
- Scenario: onboarding the tooling
  1. The maintainer reads `consumer-onboarding.md`, confirms PowerShell 7.4, and decides whether to
     install the optional python pack.
  2. The maintainer runs `init`, `inventory`, `update-ledger`, `generate-reference`, `check` and
     `validate -Mode docs-complete` using the examples in `command-reference.md`.
  3. Expected outcome: a passing receipt, with no linter installed.
- Scenario: detecting drift end to end
  1. The fixture repository passes `docs-complete` at a first revision.
  2. A command's declaration lines change and a new command is added.
  3. `docs-complete` fails naming the new command and the stale page; after the ledger and page are
     updated it passes.

## Acceptance Criteria

- [ ] The template `epic.md` under `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/` is accepted by `/epic-plan` as a manifest path, verified by a Pester test of conformance to the `epic-orchestrate` manifest schema.
- [ ] A Pester test proves the template manifest has a cycle-free dependency graph under the epic manifest rules, with foundation children in wave 0, page-family children in wave 1 and the exit-gate child alone in the final wave, and in-memory mutations (cycle, unresolved dependency, duplicate `issue_num`) make it fail.
- [ ] The template `README.md` tells the maintainer where to place `epic.md`, which fields to change together and how to run `/epic-plan`, and states that no command copies the template.
- [ ] The onboarding guide under `docs/engineering/documentation-estate/` documents every subcommand and every docs MCP tool by its exact contract name with an example, and a Pester test derives the expected names from the merged dispatch table and the merged MCP tool definitions.
- [ ] The onboarding guide states the destination-repository prerequisite PowerShell 7.4 (Q8 provisional default).
- [ ] The onboarding guide states that the optional python pack enables the native Python analyzer (D3) and that without it `inventory` uses the scanner.
- [ ] The onboarding guide states that linting is optional (D4) and that `check` is the required page gate.
- [ ] The end-to-end test runs inventory, ledger, generation and `docs-complete` validation; it fails naming the undocumented command and the stale page, and passes after both are fixed.
- [ ] The end-to-end test records `analysis_method` for every inventory element and ledger entry and asserts the value `scanner`.
- [ ] No test creates temporary files or starts a process.
- [ ] No consumer identifier appears in the template or the onboarding pages, and this feature adds no Python or TypeScript file.

## Non-Goals

- No change to any `.claude/lib/docs/` module, schema, hook, skill, agent, MCP tool or extension
  command.
- No command or tool that copies the epic template into a consumer repository (OQ-A).
- No executable `/epic-plan` parser.
- No docs-site build and no Markdown linter adoption for this repository.
