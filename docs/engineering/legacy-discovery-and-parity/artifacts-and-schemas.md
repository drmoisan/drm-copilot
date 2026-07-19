# Artifacts and Schemas

Every artifact produced by the discovery/parity workflow (see [`workflow.md`](workflow.md))
is governed by a versioned JSON Schema, validated by a dedicated CLI command, and enforced
by completion-gate hooks that block progression until validation passes. This page names
the seven schemas, the versioning convention, the validation path, and the completion-gate
mechanism; it does not restate individual schema field tables, hook input/output payload
shapes, or validator internals, which are owned by the schema, validator, and hook
features respectively.

## The Seven Schemas

Each discovery artifact kind has one versioned JSON Schema file under
`schemas/discovery/v1/`:

| Artifact | Schema file |
|---|---|
| Feature Contract | `schemas/discovery/v1/feature-contract.schema.json` |
| Coverage Ledger | `schemas/discovery/v1/coverage-ledger.schema.json` |
| Runtime Characterization Scenario | `schemas/discovery/v1/runtime-characterization-scenario.schema.json` |
| Parity Matrix | `schemas/discovery/v1/parity-matrix.schema.json` |
| Unspecified Behavior Record | `schemas/discovery/v1/unspecified-behavior-record.schema.json` |
| Product Decision Record | `schemas/discovery/v1/product-decision-record.schema.json` |
| Evidence Reference | `schemas/discovery/v1/evidence-reference.schema.json` |

Each artifact instance declares its schema via a `$schema` self-reference (JSON Schema
draft 2020-12) and a `schema_version` field, following the same versioning convention used
by every schema consumer in this capability.

## Schema-Versioning Convention

Schemas live under a version-numbered directory (`schemas/discovery/v1/`), and each schema
file's own `$id` echoes its repository-relative path. A future breaking change to a schema
is expected to land as a new version directory (for example `v2/`) rather than an in-place
edit, following the repository-wide convention that a major schema change requires a
version bump rather than silent mutation of an existing version.

## Validation

Two validation paths exist, and they are not the same mechanism:

- **The discovery validator CLI (primary, artifact-specific).** Nine `dev.discovery.validate-*`
  Poetry console-script commands validate discovery artifacts against their declared
  schema: `dev.discovery.validate-all` (validates every kind under a supplied path),
  `dev.discovery.validate-profile`, `dev.discovery.validate-feature-contract`,
  `dev.discovery.validate-coverage-ledger`, `dev.discovery.validate-runtime-scenario`,
  `dev.discovery.validate-parity-matrix`, `dev.discovery.validate-unspecified-behavior`,
  `dev.discovery.validate-product-decision`, and `dev.discovery.validate-evidence-reference`.
  All are entry points into `scripts/dev_tools/validate_discovery_artifacts.py`. This is
  the validation path a consumer repository uses day to day (see
  [`running-the-workflow.md`](running-the-workflow.md) for the corresponding MCP tool and
  VS Code command).
- **The generic governed-JSON checker (secondary, repository-wide).** `dev.validate-json`
  (`scripts/dev_tools/validate_json.py`) validates any `$schema`-bearing JSON file against
  its declared schema. Its default scan covers governed globs
  (`scripts/**/*.json`, `docs/**/*.json`, `examples/**/*.json`) — a repo-root
  `schemas/**` file is outside that default scan, but `dev.validate-json` also accepts
  explicit file or directory paths, so it can validate schema files directly when pointed
  at them. The artifact templates under `docs/discovery/templates/artifacts/*.template.json`
  fall inside the default governed-glob scan because they are under `docs/`.

## Completion-Gate Enforcement

Two PowerShell hooks enforce the validation gate automatically, registered in
`.claude/settings.json`:

- `.claude/hooks/enforce-discovery-artifact-gate.ps1` — a `PreToolUse` hook (matching
  `Write`/`Edit`) that, when a write targets a recognized discovery artifact type, invokes
  the discovery validator CLI and denies the write on a validation failure.
- `.claude/hooks/validate-discovery-artifact-gate.ps1` — a `SubagentStop` hook that
  re-validates discovery artifacts at the end of a delegated agent's work as a backstop.

Neither hook reimplements validator logic; both route to the validator CLI described
above and interpret its exit code and output. Hook I/O contract details are owned by the
completion-gate hooks feature's own reference documentation.
