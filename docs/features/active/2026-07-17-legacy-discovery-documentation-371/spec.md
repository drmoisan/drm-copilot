# legacy-discovery-documentation — Spec

- **Issue:** #371
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 0.1

## Overview

The `legacy-discovery-and-parity` epic delivers a reusable, domain-neutral capability for
agentic discovery of legacy-system behavior and source-to-target parity definition. The
capability spans a domain-profile configuration contract (#9001), seven versioned JSON
schemas (#9002), validators (#9003), completion-gate hooks (#9004), initialization
templates (#9005), an analyzer framework (#9006, #9014), generic agent roles (#9007),
generic skills (#9008), acceptance-scenario generation (#9009), reports (#9010),
CLI/MCP/VS Code surfaces (#9011), and cross-ecosystem publishing (#9012).

Each functional feature delivers its own per-feature reference documentation inside its
own PR. What is missing — and what this feature supplies — is capability-level,
end-to-end documentation that ties the surfaces together: without it, a consumer
repository cannot author its domain profile, run the workflow across the CLI/MCP/VS Code
surfaces, or understand how to receive the capability through the push-down tooling.

This feature is documentation only. It delivers Markdown files under `docs/` and no
production code.

## Behavior

Author a README-indexed capability documentation directory at
`docs/engineering/legacy-discovery-and-parity/`, consistent with the
`docs/engineering/claude-code-architecture.md` precedent for capability-level
documentation (per research: `docs/engineering/` is the repository's durable
documentation home; `docs/features/` has archive semantics and is not durable). The
directory contains a `README.md` index plus one topic page per capability area,
kebab-case filenames, and relative-path cross-links.

The documentation set covers five areas:

1. **End-to-end workflow** — what the capability does, the sequence of discovery and
   parity-definition activities, and the artifacts produced (through reports and
   acceptance scenarios as terminal outputs).
2. **Domain-profile authoring** — how a consumer repository authors its domain-profile
   configuration: the contract fields (legacy source location, target location,
   technology stack, artifact conventions) and domain-neutral authoring guidance.
3. **Artifact/schema lifecycle** — the seven versioned JSON schemas (Feature Contract,
   Coverage Ledger, Runtime Characterization Scenario, Parity Matrix, Unspecified
   Behavior Record, Product Decision Record, Evidence Reference), the schema-versioning
   convention, validation, and completion-gate hook enforcement.
4. **Running the workflow** — the three lockstep invocation surfaces: CLI
   (`poetry run dev.discovery.<command>`), MCP tools, and VS Code commands, documented in
   the order CLI before MCP before VS Code.
5. **Consumer onboarding** — how consumer repositories receive the capability via the
   push-down tooling (`scripts/dev_tools/push_down_*_customizations.py` CLIs and the
   corresponding MCP `push_down_*` tools), with TaskMaster and TMW framed strictly as
   onboarding examples.

The documentation describes the generic capability and domain-neutral authoring of the
domain profile. Consumer specifics (TaskMaster, TMW) appear only as onboarding examples,
never as framework behavior. The documentation cites, and links to, each functional
feature's own reference docs; it does not duplicate them.

## Inputs / Outputs

- Inputs (requirements sources, not runtime inputs — this feature has no runtime):
  - `docs/features/epics/legacy-discovery-and-parity/objective-source.md` — planned
    capability scope, used wherever an upstream feature spec is absent.
  - Delivered upstream feature specs on the integration branch
    (`epic/legacy-discovery-and-parity-integration`), used where present; the delivered
    spec supersedes planned scope.
  - `docs/features/epics/legacy-discovery-and-parity/epic.md` — shared-design
    constraints (domain neutrality, CLI-before-MCP-before-VS-Code, mirror contract).
- Outputs (the documentation set, all new files):

  | File | Topic |
  |---|---|
  | `docs/engineering/legacy-discovery-and-parity/README.md` | Index; capability overview; domain-neutrality invariant; links to all topic pages |
  | `docs/engineering/legacy-discovery-and-parity/workflow.md` | End-to-end discovery/parity workflow and the artifacts produced |
  | `docs/engineering/legacy-discovery-and-parity/domain-profile.md` | Authoring the domain-profile configuration contract (domain-neutral guidance) |
  | `docs/engineering/legacy-discovery-and-parity/artifacts-and-schemas.md` | Seven schemas, versioning convention, validation, completion gates |
  | `docs/engineering/legacy-discovery-and-parity/running-the-workflow.md` | CLI `dev.discovery.*`, MCP tools, VS Code commands in lockstep |
  | `docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md` | Push-down delivery to consumers; TaskMaster/TMW as examples only |

  File names are kebab-case; exact topic-page names may be adjusted at planning time
  provided the five coverage areas and the README index remain intact.
- Config keys and defaults: none (no code, no configuration).
- Versioning or backward-compatibility constraints: documented command names, schema
  paths, and pack-manifest decisions are provisional until the pre-PR reconciliation
  pass against the integration branch (see Constraints & Risks).

## API / CLI Surface

This feature adds no commands, tools, or APIs. It documents surfaces owned by other
features. The documentation must cover:

- **CLI**: the `dev.discovery.*` Poetry console-script namespace and the invocation
  pattern `poetry run dev.discovery.<command> ...`, matching the established `dev.*`
  alias convention in `pyproject.toml`. Each `dev.discovery.*` command is delivered by
  its owning functional feature; #9011 wraps them.
- **MCP tools**: the MCP exposure of the discovery commands (extension-hosted server and
  the standalone `packages/mcp-server/` npm package usable via `npx`).
- **VS Code commands**: the command-palette entries contributed by the extension, which
  call the same in-process services as the MCP tools.
- **Push-down tooling** (onboarding surface): the three push-down variants as Python
  CLIs (`push_down_copilot_customizations.py`,
  `push_down_codex_and_agents_customizations.py`, `push_down_claude_customizations.py`),
  MCP `push_down_*` tools, and VS Code commands.
- Contracts and validation rules to document (not implement): every governed discovery
  artifact declares `$schema` and is validated via the validator CLI and
  `dev.validate-json` governed globs; completion-gate hooks block progression until the
  validators pass.

Concrete discovery command names are planned scope until the owning features land on the
integration branch; the reconciliation pass verifies or corrects every documented name.

## Data & State

Not applicable at runtime. The only state introduced is the documentation tree itself:

```
docs/engineering/legacy-discovery-and-parity/
  README.md
  workflow.md
  domain-profile.md
  artifacts-and-schemas.md
  running-the-workflow.md
  consumer-onboarding.md
```

- Data transformations and invariants: none.
- Caching or persistence details: none.
- Migration or backfill requirements: none.

## Constraints & Risks

- **Domain neutrality (shared epic invariant).** The core framework is domain-neutral.
  The documentation describes the generic capability and domain-neutral authoring of the
  domain profile. Consumer specifics (TaskMaster, TMW) appear only as onboarding
  examples in the consumer-onboarding page, never as framework behavior. No
  TaskMaster/TMW/Outlook/VSTO/email/task-management behavior may be presented as
  framework behavior anywhere in the doc set.
- **No per-feature duplication.** Per-feature reference docs are delivered inside each
  functional feature's own PR. This doc set links to them and summarizes at the
  capability level only. Restating parser internals, schema field tables, hook I/O
  details, or command flag references owned by another feature is out of scope.
- **Upstream absence / provisional content.** Research verified that all 13 upstream
  child features are absent on the current branch. Documentation is authored against
  planned scope from `objective-source.md` where an upstream spec is absent, and against
  the delivered spec where present. All documented command names, schema paths, and
  pack-manifest decisions are provisional until reconciled.
- **Pre-PR reconciliation (required).** A reconciliation pass against the integration
  branch (`epic/legacy-discovery-and-parity-integration`) is required before the PR:
  verify every documented command name, file path, schema name, and pack decision
  against what has actually landed; update or explicitly mark as planned anything not
  yet delivered.
- **Link-drift risk.** The repository has a precedent of a stale doc reference
  (`docs/ci.research.md` cited but absent). The doc set must prefer linking to files
  that exist at authoring time and explicitly mark forward references as planned.
- **Naming-collision constraint.** The installed `code-modernization` plugin ships
  `/modernize-*` commands and agents (`legacy-analyst`, `business-rules-extractor`,
  etc.). The documentation must not introduce, imply, or reuse those names.
- **No docs-lint convention exists.** Research verified there is no markdownlint,
  link-check, or docs structural-lint tooling or CI step in this repository. Structural
  link/section checks are therefore optional, not mandated (see Implementation
  Strategy).

## Implementation Strategy

- Implementation scope (what changes, not sequencing):
  - Author the six Markdown files listed in Inputs / Outputs under
    `docs/engineering/legacy-discovery-and-parity/`. Markdown files are exempt from the
    500-line file-size limit; page size is a readability concern only.
  - `README.md`: capability overview, statement of the domain-neutrality invariant,
    audience guide, and a linked index of the five topic pages.
  - `workflow.md`: the end-to-end sequence — workspace initialization, agent/skill-driven
    discovery and parity definition, artifact population, validation, gate enforcement,
    and terminal outputs (reports rendered, acceptance scenarios generated).
  - `domain-profile.md`: the configuration contract a consumer authors (legacy source
    location, target location, technology stack, artifact conventions) and domain-neutral
    authoring guidance; references the decided profile format without restating parser
    internals (owned by #9001).
  - `artifacts-and-schemas.md`: the seven schemas by name, the versioning convention,
    the `$schema`/governed-glob validation path, the canonical validator CLI, and how
    completion-gate hooks enforce artifact completion — citing each owning feature's
    reference docs.
  - `running-the-workflow.md`: per-command lockstep documentation pattern —
    `poetry run dev.discovery.<x>`, MCP tool `<x>`, VS Code command — in CLI-first order.
  - `consumer-onboarding.md`: generic push-down flow (consumer runs the push-down tool
    via CLI, MCP, or VS Code and receives the discovery agents, skills, hooks, schemas,
    and templates from the bundled mirrors), with TaskMaster (legacy source provider)
    and TMW (modern target provider) as worked examples only.
- New classes/functions/commands to add or update: none (documentation only).
- Tests: no tests are required; the repository has no docs-lint convention. Optionally,
  one pytest content-contract test under `tests/docs/` asserting the documentation files
  exist and contain their required top-level sections, in the style of
  `tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py`, may be
  authored at planning discretion. It is not repository-mandated.
- Dependency changes: none.
- Logging/telemetry additions: none.
- Rollout plan: single PR to the integration branch after the reconciliation pass; no
  feature flags or staged deploys apply.

## Acceptance Criteria

- [x] A README-indexed documentation directory exists at
      `docs/engineering/legacy-discovery-and-parity/` with kebab-case filenames;
      `README.md` states the domain-neutrality invariant and links every topic page via
      relative paths.
- [x] A workflow page documents the discovery/parity workflow end to end — from
      workspace initialization through validated artifacts to rendered reports and
      generated acceptance scenarios — without duplicating per-feature reference docs.
- [x] A domain-profile page documents domain-neutral authoring of the domain-profile
      configuration, covering the contract fields (legacy source location, target
      location, technology stack, artifact conventions), and defers parser internals to
      the #9001 reference docs.
- [x] An artifacts-and-schemas page documents the artifact/schema lifecycle: the seven
      versioned JSON schemas by name (Feature Contract, Coverage Ledger, Runtime
      Characterization Scenario, Parity Matrix, Unspecified Behavior Record, Product
      Decision Record, Evidence Reference), the schema-versioning convention, validation
      (validator CLI and `$schema`/governed-glob checking), and completion-gate hook
      enforcement.
- [x] A running-the-workflow page documents the three lockstep invocation surfaces —
      CLI (`poetry run dev.discovery.<command>`), MCP tools, and VS Code commands — in
      the order CLI before MCP before VS Code.
- [x] A consumer-onboarding page documents how consumer repositories receive the
      capability via the push-down tooling
      (`scripts/dev_tools/push_down_*_customizations.py` CLIs and MCP `push_down_*`
      tools), with TaskMaster and TMW framed strictly as onboarding examples.
- [x] Domain-neutrality invariant holds across the doc set: the capability is described
      as domain-neutral; no TaskMaster/TMW/Outlook/VSTO/email/task-management behavior
      is presented as framework behavior; consumer specifics appear only in the
      onboarding examples.
- [x] No per-feature reference documentation is duplicated: the doc set links to (or
      names as planned) each functional feature's own reference docs instead of
      restating their content.
- [x] Provisional content is handled per the upstream-presence constraint: content is
      authored against planned scope from `objective-source.md` where an upstream spec
      is absent and against the delivered spec where present, and forward references to
      not-yet-delivered files are explicitly marked as planned.
- [x] A reconciliation pass against the integration branch
      (`epic/legacy-discovery-and-parity-integration`) is completed before the PR: every
      documented command name, path, schema name, and pack decision is verified against
      the integration branch or corrected/re-marked as planned.
- [x] The doc set introduces no name that collides with the installed
      `code-modernization` plugin's `/modernize-*` commands or agent names.

## Definition of Done

- [x] All Acceptance Criteria in this spec and in `user-story.md` are satisfied and
      checked off with evidence.
- [x] The six documentation files exist under
      `docs/engineering/legacy-discovery-and-parity/` and cover the five capability
      areas plus the README index.
- [x] Domain-neutrality review completed: no domain-specific behavior presented as
      framework behavior; TaskMaster/TMW confined to onboarding examples.
- [x] Pre-PR reconciliation pass against
      `epic/legacy-discovery-and-parity-integration` completed; documented command
      names, paths, and pack decisions verified, corrected, or explicitly marked as
      planned.
- [x] All relative links in the doc set resolve to files present on the branch, or the
      target is explicitly marked as planned.
- [x] Optional structural content-contract test: authored under `tests/docs/` in the
      existing contract-test style, or explicitly recorded as declined (no docs-lint
      convention mandates it).
- [x] Tone policy satisfied: professional, factual, neutral wording throughout the doc
      set.
- [x] Toolchain pass completed for any code authored (only applicable if the optional
      contract test is included; otherwise no code stages apply to Markdown-only
      changes).

## Seeded Test Conditions (from potential)

- [x] Structural link/section checks — optional only: no docs-lint convention exists in
      this repository (verified by research); if implemented, use a pytest
      content-contract test under `tests/docs/`.
- [x] Cross-references to schema, CLI, MCP, and VS Code surfaces resolve correctly —
      verified manually during the pre-PR reconciliation pass against the integration
      branch.
