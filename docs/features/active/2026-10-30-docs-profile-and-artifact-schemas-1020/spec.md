# docs-profile-and-artifact-schemas — Spec

- **Issue:** #1020
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T16-08
- **Status:** Draft
- **Version:** 0.1

## Overview

The documentation-estate-tooling epic (#1019) needs a stable set of contracts before its analyzer,
ledger, generator, MCP and enforcement features can be built in parallel. No documentation profile,
documentation artifact schema, surface element model or analyzer protocol exists in the repository
today. Without them, every downstream feature would invent its own shapes, and the coverage ledger,
parity matrix and `docs-complete` receipt could not be validated consistently. Framework code must also
stay domain-neutral: all repository specificity must be runtime configuration in a docs profile.


## Behavior

Create the `packages/docs-runtime` package (import name `drm_copilot_docs`), depending on the merged
discovery runtime (`packages/discovery-runtime`, `drm_copilot_discovery`) as a library without changing
its behavior. The package provides:

- Profile dataclasses (audiences, documentation roots, surface selection, page owners, Diataxis policy,
  completion gates) and a loader that validates a docs profile.
- Docs v1 schema loading with references into discovery v2 `common`.
- The surface element model: kinds `cli-command`, `cli-option`, `http-route`, `config-key`,
  `public-symbol`, `architecture-component`, with deterministic identifiers derived from kind, path and
  declaration, following `drm_copilot_discovery.analyzer.findings`.
- The analyzer protocol and an append-only registry table in `analyzer_contract.py` that later analyzer
  features extend.
- One CLI module providing `dev.docs.init` (emit a starter profile) and `dev.docs.validate-profile`.
- Six schemas under `schemas/docs/v1/`: `docs-profile`, `surface-inventory-snapshot`,
  `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin`, `docs-validation-receipt`, with one
  example per schema under `examples/docs/v1/`. Ledger dispositions are `documented`, `excluded` and
  `deferred`; parity dimensions are `exists`, `accurate`, `example_present`, `owner_assigned` and
  `diataxis_mode`; page front-matter fields are `owner`, `last_reviewed`, `audience`, `diataxis_mode`
  and `surface_refs`.
- Registration of the package in the root `pyproject.toml` (path dependency and two scripts) and in the
  same bundling or distribution mechanism the discovery runtime uses, so a consumer repository can
  install and run the docs runtime.


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

- The naming contract in the epic manifest `## Shared Design` section is fixed; this feature may not
  change it.
- Downstream features consume these schemas and contracts, so they must be stated precisely.
- The consumer installation path for the Python package is unresolved and must follow the discovery
  runtime's distribution mechanism.
- No test creates temporary files; pure cores take in-memory mappings and I/O stays in thin CLI modules.
- Shared append-only files (`pyproject.toml`, `poetry.lock`) are also edited by sibling features.


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
- [ ] Unit coverage areas: profile loading and validation, surface identities, analyzer registry, CLI.
- [ ] Integration scenarios: example artifacts validate against each schema; schema references resolve into discovery v2.
- [ ] CLI/API examples: `dev.docs.init`, `dev.docs.validate-profile`.
