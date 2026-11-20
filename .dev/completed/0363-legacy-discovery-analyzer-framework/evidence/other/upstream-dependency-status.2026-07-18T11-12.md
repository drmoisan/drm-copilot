# Upstream Dependency Status (P1-T1)

Timestamp: 2026-07-18T11-12

Purpose: record presence/absence of the upstream #360 config-contract loader surface and
the #359 discovery v1 schema, per plan task [P1-T1]. Absence would be a sequencing note (not
a preflight blocker), resolved by the integration merge of #360 and #359 before execution.

## Config-contract loader (#360)

Path: `scripts/dev_tools/discovery/domain_profile.py` — PRESENT.

Documented/expected symbols:
- `DomainProfileError` — PRESENT (defined in `scripts/dev_tools/discovery/domain_profile_models.py`, re-exported from the package `__init__` and importable via `domain_profile.py`).
- `DEFAULT_PROFILE_FILENAME` — PRESENT (`domain_profile.py`, value `"discovery-profile.yaml"`).
- `load_profile` — ABSENT under that exact name. The public loader entry point is named
  `load_domain_profile(path: Path) -> DomainProfile` (plus the pure text parser
  `parse_domain_profile_text(text, source)`). The plan task text referenced `load_profile`;
  the delivered #360 surface uses `load_domain_profile`. This CLI (P6-T1) imports
  `load_domain_profile`. This is a naming reconciliation only; the loader capability the plan
  requires is present.

Profile model surface (consumed by the analyzer): `DomainProfile`, `LegacySourceConfig`
(`root`, `include`, `exclude`), `ArtifactsConfig` (`root`) — all PRESENT.

## Discovery v1 schema (#359)

Path: `schemas/discovery/v1/evidence-reference.schema.json` — PRESENT.

Schema key facts used by the emitter (P5): `additionalProperties: false`; required set
`["$schema", "schema_version", "id", "kind", "location", "captured_at", "description"]`;
optional `content_hash` ({algorithm, value}), `tool`, and free-form `metadata` object;
`schema_version` pattern `^1\.\d+\.\d+$`; `id` pattern `^[a-z0-9][a-z0-9._-]*$`; `kind` enum
includes `"file"`; `captured_at` ISO-8601 pattern (no FormatChecker).

## Conclusion

Both upstream dependencies are present on this branch. No sequencing blocker. The only
reconciliation is the loader function name: use `load_domain_profile` rather than the
plan-text placeholder `load_profile`.
