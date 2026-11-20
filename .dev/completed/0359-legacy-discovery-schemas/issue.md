# legacy-discovery-schemas (Issue #359)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-schemas/ (Issue #359)
- Epic: legacy-discovery-and-parity (child feature #9002, C3, Wave 0)

- Issue: #359
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/359
- Last Updated: 2026-07-17
- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity epic requires machine-readable artifact shapes that
every downstream feature (validators, reports, init/templates, analyzers, acceptance
scenarios) consumes. Today the repository has no domain/business JSON Schema files (only
permissive `.vscode/schemas/*.schema.json` editor stubs) and no schema-versioning
convention. Downstream features cannot produce or validate discovery artifacts without a
stable, versioned schema contract and a documented versioning layout.

## Proposed Behavior

Author seven versioned JSON schemas that express generic, domain-neutral legacy-discovery
artifact shapes and define the repository's schema-versioning convention:

- Feature Contract
- Coverage Ledger
- Runtime Characterization Scenario
- Parity Matrix
- Unspecified Behavior Record
- Product Decision Record
- Evidence Reference

Define (there is none today) the schema-versioning convention: directory layout (a repo-root
`schemas/` tree with a `vN/` layout), the version field, and the `$schema` self-reference
strategy. Reuse `scripts/dev_tools/validate_json.py`'s governed-glob and `$schema` resolution
machinery rather than writing new JSON-Schema-loading code. Ensure new schema and fixture
locations fall under the governed globs (`scripts/**/*.json`, `docs/**/*.json`,
`examples/**/*.json`) so `validate_json.py` picks them up. Provide conforming and
non-conforming example fixtures per schema.

## Acceptance Criteria (early draft)

- [ ] Seven versioned JSON schemas exist with a documented `vN/` directory layout.
- [ ] The schema-versioning convention (layout, version field, `$schema` self-reference) is
      documented precisely in spec.md as a shared contract.
- [ ] Each schema expresses generic, domain-neutral shapes with no TaskMaster/TMW/Outlook/
      VSTO/email/task-management-specific fields.
- [ ] Conforming and non-conforming example fixtures exist for each schema.
- [ ] Schema and fixture locations fall under `validate_json.py` governed globs and validate
      cleanly.
- [ ] Tests satisfy repository quality-tier policy (line >= 85%, branch >= 75%).

## Constraints & Risks

- Domain neutrality is a hard epic invariant: schemas must not contain domain-specific fields.
- Out of scope: deterministic validators (owned by feature #9003) and the domain-profile
  config contract (owned by feature #9001). This feature owns schema files, the versioning
  convention, and example fixtures only.
- Must reuse existing `validate_json.py` machinery; no new schema-loading code.
- The `$schema` self-reference strategy must be compatible with `validate_json.py`'s
  resolution (relative path, `file://`, or cached `http(s)://`).

## Test Conditions to Consider

- [ ] Each schema validates its conforming fixture and rejects its non-conforming fixture.
- [ ] Governed-glob discovery includes the new schema and fixture files.
- [ ] Versioning-convention edge cases (version field mismatch, missing `$schema`).

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-schemas/` folder from the template
