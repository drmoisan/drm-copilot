# docs-profile-and-artifact-schemas (Issue #1020)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-profile-and-artifact-schemas/ (Issue #1020)
- Parent epic: #1019 (documentation-estate-tooling, wave 0, complexity band C3)

- Issue: #1020
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1020
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

The documentation-estate-tooling epic (#1019) needs a stable set of contracts before its analyzer,
ledger, generator, MCP and enforcement features can be built in parallel. No documentation profile,
documentation artifact schema, surface element model or analyzer protocol exists in the repository
today. Without them, every downstream feature would invent its own shapes, and the coverage ledger,
parity matrix and `docs-complete` receipt could not be validated consistently. Framework code must also
stay domain-neutral: all repository specificity must be runtime configuration in a docs profile.

## Proposed Behavior

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

## Acceptance Criteria (early draft)

- [ ] Every example under `examples/docs/v1/` validates against its schema; each schema rejects a missing required field and an unknown disposition or element kind.
- [ ] `dev.docs.validate-profile` exits 0 for the example profile and non-zero with a message naming the failing field for an invalid profile; `dev.docs.init` emits a starter profile that validates.
- [ ] Element identifiers are deterministic (property test: same kind, path and declaration yield the same identifier; distinct inputs yield distinct identifiers).
- [ ] A neutrality test fails when a configured consumer identifier appears under `packages/docs-runtime/src/` or `schemas/docs/`.
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs`.

## Constraints & Risks

- The naming contract in the epic manifest `## Shared Design` section is fixed; this feature may not
  change it.
- Downstream features consume these schemas and contracts, so they must be stated precisely.
- The consumer installation path for the Python package is unresolved and must follow the discovery
  runtime's distribution mechanism.
- No test creates temporary files; pure cores take in-memory mappings and I/O stays in thin CLI modules.
- Shared append-only files (`pyproject.toml`, `poetry.lock`) are also edited by sibling features.

## Test Conditions to Consider

- [ ] Unit coverage areas: profile loading and validation, surface identities, analyzer registry, CLI.
- [ ] Integration scenarios: example artifacts validate against each schema; schema references resolve into discovery v2.
- [ ] CLI/API examples: `dev.docs.init`, `dev.docs.validate-profile`.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-profile-and-artifact-schemas/` folder from the template
