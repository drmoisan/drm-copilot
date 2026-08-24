# legacy-discovery-validators (Issue #361)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-validators/ (Issue #361)
- Epic: legacy-discovery-and-parity (child feature #9003)

- Issue: #361
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/361
- Last Updated: 2026-07-17
- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability. Consumer repositories author a domain-profile
configuration (feature #9001) and produce seven versioned JSON-schema-governed
artifacts (feature #9002). Without deterministic validators, there is no
programmatic gate that a domain profile or a produced discovery artifact
conforms to its contract. This feature supplies those validators so that the
completion-gate hooks (#9004), reports (#9010), and MCP/VS Code surfaces (#9011)
can rely on a single authoritative conformance check.

## Proposed Behavior

Provide deterministic validators for the domain-profile config and for each of
the seven discovery schemas, following the repository canonical validator
pattern exactly:

- Pure `validate_<artifact>_text(text: str, ...) -> list[str]` functions
  (empty list = pass, list of human-readable error strings otherwise).
- A thin argparse CLI with subparsers per artifact type, mirroring
  `scripts/dev_tools/validate_orchestration_artifacts.py`. Likely one umbrella
  module (for example `validate_discovery_artifacts.py`) with subparsers:
  `profile | feature-contract | coverage-ledger | runtime-scenario |
  parity-matrix | unspecified-behavior | product-decision | evidence-reference |
  all`.
- Errors to stderr one per line, single success line to stdout,
  `main() -> int` returning 0/1.
- Expose `dev.discovery.validate-*` Poetry console-script entry points.
- Tests per quality-tier policy using the conforming/non-conforming fixtures
  produced by the schemas feature (#9002).

The validators must be generic over the schemas and config contract. They must
not encode any domain-specific field values (no TaskMaster/TMW/Outlook/VSTO/
email/task-management specifics).

## Dependencies (upstream, wave 0)

- legacy-discovery-config-contract (#9001): defines the domain-profile config
  contract and its typed loader. The profile validator validates that config's
  structure.
- legacy-discovery-schemas (#9002): defines the seven versioned JSON schemas and
  the schema-versioning convention / directory layout. The per-schema validators
  enforce conformance to those schemas and locate schemas via the versioning
  convention #9002 defines (no hardcoded layout that contradicts it).

## Acceptance Criteria (early draft)

- [ ] A pure `validate_<artifact>_text` function exists for the domain-profile
      config and for each of the seven schemas, returning `list[str]`.
- [ ] A single argparse CLI exposes one subparser per artifact type plus `all`,
      matching the canonical pattern (errors to stderr, one success line to
      stdout, `main() -> int` returning 0/1).
- [ ] `dev.discovery.validate-*` Poetry console-script entry points are
      registered.
- [ ] Each validator accepts its conforming fixtures and rejects its
      non-conforming fixtures with human-readable error strings.
- [ ] Per-schema validators locate schemas via the #9002 versioning convention
      rather than a hardcoded layout.
- [ ] No domain-specific identifier appears in the validator source.
- [ ] Tests satisfy quality-tier policy (line >= 85%, branch >= 75%), co-located
      in the mirrored `tests/` tree.

## Constraints & Risks

- Domain neutrality is an epic invariant: validators are generic over schemas
  and config, never over domain field values.
- Upstream contracts (#9001, #9002) are finalized in parallel; design against
  the planned contract and cite it. Do not hardcode a schema layout that
  contradicts #9002's versioning convention.
- Reuse `jsonschema` (^4.25.1, Draft202012Validator, already a declared
  dependency) and the existing `validate_json.py` governed-glob / `$schema`
  resolution machinery rather than introducing new schema-loading code.

## Test Conditions to Consider

- [ ] Conforming fixture accepted (empty error list) for each artifact type.
- [ ] Non-conforming fixture rejected with specific error strings for each type.
- [ ] CLI subparser dispatch for each artifact type and `all`.
- [ ] CLI exit codes: 0 on success, 1 on validation failure.
- [ ] Schema-location resolution follows the #9002 versioning convention.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-validators/` folder from the template
