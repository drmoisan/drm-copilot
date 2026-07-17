# `legacy-discovery-schemas` — User Story

- Issue: #359
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17
- Epic: legacy-discovery-and-parity (child feature #9002, C3, Wave 0)

## Story Statement

- As a **downstream epic feature** (validators #9003, reports #9010, init/templates #9005, the
  analyzer framework #9006, acceptance-scenario generation #9009), I want a stable, versioned set of
  domain-neutral JSON schemas for the seven discovery artifacts, so that I can produce, consume, and
  validate discovery artifacts against one authoritative shape without re-deriving field structures or
  inventing my own versioning.
- As an **external consumer repository** (`drmoisan/TaskMaster` as legacy source, `drmoisan/TMW` as
  modern target), I want to author feature contracts, coverage ledgers, characterization scenarios,
  parity matrices, unspecified-behavior records, product-decision records, and evidence references
  against generic, versioned schemas, so that my discovery artifacts are portable and validate against
  the reusable framework rather than any repository-specific format.
- As a **framework maintainer**, I want a single documented schema-versioning convention (directory
  layout, in-schema `version`, instance-level `schema_version`, `$schema` self-reference, `$id`
  strategy), so that additive schema changes stay non-breaking and a cross-major mismatch is detected
  as a validation rejection.

## Problem / Why

The legacy-discovery-and-parity epic requires machine-readable artifact shapes that every downstream
feature (validators, reports, init/templates, analyzers, acceptance scenarios) and every external
consumer repository consumes. Today the repository has no domain/business JSON Schema files (only
permissive `.vscode/schemas/*.schema.json` editor stubs) and no schema-versioning convention.
Downstream features and consumer repositories cannot produce or validate discovery artifacts without a
stable, versioned, domain-neutral schema contract and a documented versioning layout.

Because the schemas sit at the base of the epic dependency graph (Wave 0, depended on by #9003, #9005,
#9006, #9007, #9009, #9010, and #9012), their shape and their versioning convention become a
user-visible contract the moment they exist. Any ambiguity here propagates to every consuming feature.

## Personas & Scenarios

- **Persona: downstream epic feature (for example the #9003 validator author).**
  - Who: an agent or engineer implementing a deterministic validator, a report renderer, or an
    initialization template inside this repository.
  - What they care about: a single authoritative artifact shape and a versioning convention they can
    reuse rather than re-invent; deterministic, offline validation that does not fetch a remote
    meta-schema or dirty the working tree.
  - Constraints: must reuse `scripts/dev_tools/validate_json.py` rather than write new schema-loading
    code; must satisfy quality-tier coverage thresholds; must keep the framework domain-neutral.
  - Goals and frustrations: wants to load a schema, validate an instance, and know the exact required
    fields and cross-reference identifiers; frustrated by permissive stubs and undefined versioning.

- **Persona: external consumer repository (TaskMaster / TMW).**
  - Who: a repository migrating a legacy application to a modern architecture, supplying legacy
    context, feature contracts, runtime evidence, characterization scenarios, coverage information,
    and parity status.
  - What they care about: producing discovery artifacts against a versioned, generic shape that will
    not encode another domain's vocabulary; confidence that additive schema evolution will not break
    their existing artifacts.
  - Constraints: their real source/target names and technology stack are supplied at runtime via the
    domain-profile configuration (#9001), never encoded in a schema.
  - Goals and frustrations: wants portable, validatable artifacts; frustrated by having to conform to
    a format that names a foreign domain's concepts.

- **Scenario: a validator author consumes the schemas.**
  - Trigger: feature #9003 begins implementing deterministic validators, which depend on #9002.
  - Steps: the author reads the schema-versioning convention in `spec.md`; opens
    `schemas/discovery/v1/feature-contract.schema.json`; observes the required fields, the
    `schema_version` pattern `^1\.\d+\.\d+$`, and the plain-string cross-reference identifiers; loads
    the schema through the existing machinery and validates the conforming fixture at
    `examples/discovery/v1/feature-contract.example.json`.
  - Obstacles/decisions: the author needs a negative corpus; the non-conforming fixtures under
    `tests/fixtures/discovery_schemas/v1/` provide a distinct violation class per schema.
  - Expected outcome: the author builds referential-integrity checks (deferred from the schemas to
    #9003) on top of a stable shape without changing the shape or the versioning convention.

- **Scenario: a consumer repository authors a coverage ledger.**
  - Trigger: TaskMaster runs the discovery workflow and needs to record legacy implementation
    coverage.
  - Steps: the consumer instantiates a coverage-ledger instance carrying `schema_version`,
    `generated_at`, `subject`, `entries`, and `summary`, referencing feature contracts by plain
    string `feature_ids` and evidence by `evidence_refs`; the instance declares its `$schema` as a
    scheme-less relative path to the schema file.
  - Obstacles/decisions: the consumer must express only generic units (`module | namespace | type | file | component | other`);
    domain-specific naming is confined to the values the consumer supplies, not the schema.
  - Expected outcome: the artifact validates through the reusable framework and remains portable
    across consumer repositories.

## Versioning Convention (user-visible contract)

The schema-versioning convention is itself a user-visible contract that every consumer depends on:

- **Directory layout:** `schemas/<family>/v<N>/<artifact>.schema.json` at the repository root; this
  feature creates `schemas/discovery/v1/`. `v<N>` is the major version; a breaking change creates a
  sibling `v2/` tree, and a published `vN/` tree is immutable except for additive changes.
- **In-schema `version`:** a semver string whose major component equals the directory `N`.
- **Instance-level `schema_version`:** a required string constrained by `^1\.\d+\.\d+$` (major pinned,
  minor/patch free), so additive minor bumps do not break existing instances but a cross-major
  mismatch is rejected.
- **`$schema`:** the Draft 2020-12 meta-schema self-reference in each schema document; each instance
  declares `$schema` as a scheme-less relative path to its schema file.
- **`$id`:** the repo-relative path string, used as an identifier only and never dereferenced.
- **Self-containment:** no cross-file `$ref`; shared shapes are duplicated into each schema's `$defs`,
  because the validation machinery loads a single schema dict and cannot resolve cross-file `$ref`.

## Acceptance Criteria

- [ ] A downstream feature can load any of the seven `schemas/discovery/v1/` schemas and validate a
      conforming instance through the existing `validate_json.py` machinery, offline and without a
      remote meta-schema fetch.
- [ ] The schema-versioning convention (directory layout, in-schema `version`, instance-level
      `schema_version` pattern, `$schema` self-reference, `$id` identifier-only strategy,
      self-containment rule) is documented as the user-visible contract every consumer reuses.
- [ ] Each schema expresses generic, domain-neutral shapes with no TaskMaster/TMW/Outlook/VSTO/email/
      task-management-specific fields, enum values, or descriptions; real source/target names are
      supplied at runtime by the domain profile (#9001).
- [ ] Cross-references between artifacts are plain string identifiers a consumer can populate without
      JSON Schema `$ref`.
- [ ] A conforming fixture and a distinct-violation non-conforming fixture exist for each schema,
      giving downstream features a positive and a varied negative corpus.
- [ ] Conforming fixtures at `examples/discovery/v1/` are governed and validate cleanly; non-conforming
      fixtures at `tests/fixtures/discovery_schemas/v1/` are intentionally ungoverned and are exercised
      by tests that assert rejection via `validate_file`. (Not all fixture locations fall under
      governed globs and validate cleanly; a governed failing fixture would make `dev.validate-json`
      permanently fail.)
- [ ] An additive minor schema change does not break an existing conforming instance, and a
      cross-major `schema_version` mismatch is rejected at validation time.
- [ ] Tests satisfy repository quality-tier policy (line >= 85%, branch >= 75%) and add no new
      production code.

## Non-Goals

- Deterministic validators and the canonical `validate_<artifact>_text` pattern (owned by feature
  #9003).
- The domain-profile configuration contract and its parser (owned by feature #9001).
- Referential-integrity checks across artifacts (whether a referenced `id` exists) — not expressible
  in JSON Schema and deferred to #9003.
- Reports rendered from the artifacts (owned by feature #9010) and initialization/templates (owned by
  feature #9005).
- Mirroring schemas into `resources/` subtrees (owned by feature #9012).
- Any change to `validate_json.py` or `json_config.py`, and any new `dev.discovery.*` CLI command.
