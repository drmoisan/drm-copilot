# `docs-profile-and-artifact-schemas` — User Story

- Issue: #1020
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T20-45

## Story Statement

- As a consumer repository maintainer, I want to install a documentation runtime, generate a
  starter docs profile and validate it with one command, so that I can describe my repository's
  documentation estate as configuration without changing framework code.
- As a downstream epic feature author, I want fixed, versioned schemas, a deterministic surface
  element identifier and an append-only analyzer registry, so that I can build analyzers, the
  coverage ledger, the reference generator and enforcement in parallel against the same contracts.
- As a documentation role agent, I want every documentation artifact to validate against a closed
  schema that rejects unknown dispositions and element kinds, so that the artifacts I read and
  propose changes to have one unambiguous meaning.

## Problem / Why

The documentation-estate-tooling epic (#1019) needs a stable set of contracts before its analyzer,
ledger, generator, MCP and enforcement features can be built in parallel. No documentation profile,
documentation artifact schema, surface element model or analyzer protocol exists in the repository
today. Without them, every downstream feature would invent its own shapes, and the coverage ledger,
parity matrix and `docs-complete` receipt could not be validated consistently. Framework code must also
stay domain-neutral: all repository specificity must be runtime configuration in a docs profile.

## Personas & Scenarios

- Persona: Consumer repository maintainer
  - Maintains one consumer repository that uses this repository's tooling.
  - Cares that documentation correspondence can be checked without hand measurement, and that the
    tooling carries no other repository's names or assumptions.
  - Constraints: has no checkout of this repository and no access to its Poetry environment; installs
    Python wheels into a trusted interpreter.
  - Goals: a valid docs profile with minimal effort. Frustration: tooling that fails with messages
    that do not identify the faulty field.
  - Context: adopting the documentation estate tooling for the first time.
- Persona: Downstream epic feature author
  - Implements a later feature of the epic (surface analyzers, coverage ledger and receipt, reference
    generator, MCP tools or enforcement).
  - Cares that schema shapes, identifier rules and registry form are stated once and do not change
    under them.
  - Constraints: works in parallel with sibling features that append to the same registry and root
    configuration files.
  - Goals: append an analyzer registration or produce an artifact that validates on the first attempt.
    Frustration: contracts that are implied rather than written.
  - Context: wave-1 and wave-2 features of the epic.
- Persona: Documentation role agent
  - An agent role (architect, author, reconciler or coverage reviewer) that reads and proposes changes
    to documentation artifacts.
  - Cares that each artifact has a closed shape and that each disposition carries its required
    companion fields.
  - Constraints: has no direct write access to ledger or matrix artifacts; relies on validation
    results to decide what to propose.
  - Goals: identify the undocumented or inconsistent element from a validation finding.
    Frustration: findings that do not point at a field.
  - Context: later documentation workflows built on these contracts.

- Scenario: Maintainer creates and validates a profile
  - Actor: consumer repository maintainer.
  - Trigger: the maintainer decides to adopt the documentation estate tooling.
  - Steps: builds or obtains the discovery wheel and the docs wheel from this repository; installs both
    with `python -I -m pip install`; runs `dev.docs.init --repository-id <id> --output
    docs/documentation-estate/docs-profile.json`; edits audiences, documentation roots and the
    Diataxis policy; runs `dev.docs.validate-profile`.
  - Obstacles and decisions: an edit references an audience that is not declared; the command exits
    non-zero and names the pointer of the offending field; the maintainer corrects it.
  - Outcome: `dev.docs.validate-profile` exits 0 and the profile is committed.
- Scenario: Feature author registers an analyzer
  - Actor: downstream epic feature author.
  - Trigger: a new analyzer module under `drm_copilot_docs.analyzers.` is ready.
  - Steps: appends one `AnalyzerRegistration` line to `ANALYZER_REGISTRY`; computes element
    identifiers with `element_identifier` using the per-kind declaration conventions; emits a
    snapshot and validates it against `surface-inventory-snapshot`.
  - Obstacles and decisions: a sibling feature appended a registration with the same identifier, or a
    module path outside the analyzers package was used; registry validation reports an error and the
    loader refuses to import the module.
  - Outcome: the registry validates with no findings and the snapshot validates against its schema.
- Scenario: Role agent reads a ledger entry
  - Actor: documentation role agent.
  - Trigger: a coverage ledger is supplied for review.
  - Steps: validates the ledger; reads each entry's disposition and companion fields.
  - Obstacles and decisions: an `excluded` entry lacks a rationale; validation rejects the ledger and
    the agent proposes the missing rationale.
  - Outcome: the agent's proposal targets the exact entry and field named by the finding.

## Acceptance Criteria

- [ ] Every example artifact under `examples/docs/v1/` validates against its schema, and each artifact schema rejects an artifact that is missing a required field or that uses an unknown disposition or element kind.
- [ ] A maintainer running `dev.docs.validate-profile` on the example profile gets exit code 0; on an invalid profile the command exits non-zero and the message names the failing field; the profile emitted by `dev.docs.init` validates.
- [ ] The same element kind, path and declaration always produce the same element identifier, and distinct inputs produce distinct identifiers, as shown by a property test.
- [ ] A neutrality test fails when a configured consumer identifier appears in the docs runtime source or in the docs schemas, so no consumer repository's name ships in the framework.
- [ ] The `drm_copilot_docs` package has line coverage of at least 85% and branch coverage of at least 75%.
- [ ] The schema copies packaged inside the docs runtime are byte-equal to the canonical schemas under `schemas/docs/v1/`, and the docs builder's `--check` mode reports success when they match and names the drifted file when they do not, without writing any file.
- [ ] A developer in this repository can run `dev.docs.init` and `dev.docs.validate-profile` through Poetry, because the root `pyproject.toml` registers the docs package as a path dependency with both scripts and includes it in coverage and type checking, and `poetry check --lock` passes.
- [ ] The docs runtime is classified as tier T2 in `quality-tiers.yml`, and the tier check passes.
- [ ] Discovery runtime files are unchanged by this feature, so existing discovery consumers are unaffected.
- [ ] The analyzer registry rejects a registration whose identifier duplicates another registration and a registration whose module lies outside `drm_copilot_docs.analyzers.`, and such a module is never imported.

## Non-Goals

- Surface analyzers and the `dev.docs.inventory` command (900003, 900004).
- Coverage ledger, parity matrix and evidence-pin semantics, staleness and the `docs-complete`
  receipt logic and their commands (900005); this feature defines only their schemas.
- The reference-page generator (900006) and the page quality checker and `page-metadata` schema
  (900002).
- MCP tools (900007), CI and hook enforcement (900008), documentation roles and skills (900009).
- A docs-site build.
- Any change to discovery runtime behavior or files.
- Bundling Python into the VSIX or the MCP npm package; the docs runtime ships as a separate wheel.
- Adding the `hypothesis` dependency.
