# legacy-discovery-validators — Spec

- **Issue:** #361
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-03
- **Status:** Ready for Planning
- **Version:** 0.2

## Overview

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability. Consumer repositories author a domain-profile
configuration (feature #9001) and produce seven versioned JSON-schema-governed
artifacts (feature #9002). Without deterministic validators, there is no
programmatic gate that a domain profile or a produced discovery artifact
conforms to its contract. This feature supplies those validators so that the
completion-gate hooks (#9004), reports (#9010), and MCP/VS Code surfaces (#9011)
can rely on a single authoritative conformance check.


## Behavior

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


## Inputs / Outputs

- **Inputs (CLI):** an artifact-type subcommand
  (`profile | feature-contract | coverage-ledger | runtime-scenario |
  parity-matrix | unspecified-behavior | product-decision |
  evidence-reference | all`) and a single positional file `path`. No other
  CLI flags are introduced for this feature; gate-style `--require-*` flags
  used by `validate_orchestration_artifacts.py` are out of scope unless a
  future consumer feature (#9004, #9010) specifies one.
- **Inputs (pure function layer):** each `validate_<artifact>_text(text:
  str, ...) -> list[str]` function receives the artifact text already read
  from disk. Disk I/O is confined to the CLI layer's `_read_text` helper, per
  the canonical pattern; the pure functions accept no file paths.
- **Outputs:** on failure, each error string is written to stderr, one per
  line; on success, a single line is written to stdout in the form
  `f"{artifact_type} validation passed: {path}"`. `main() -> int` returns `0`
  on success and `1` when the error list is non-empty.
- **Config keys and defaults:** none. This feature introduces no new
  configuration keys, environment variables, or defaults.
- **Versioning / backward-compatibility constraints:** per-schema validators
  locate the schema to validate against via the mechanism #9002 defines for
  schema resolution (the artifact's own `$schema` field, resolved through the
  shared loader extracted from `validate_json.py`), not through a
  hardcoded directory layout, version string, or path convention. This keeps
  the validators correct if #9002's versioning convention changes before it
  ships, and avoids encoding a schema version (for example `v1`) in
  validator source.

## API / CLI Surface

- **Subcommands** (umbrella module `scripts/dev_tools/validate_discovery_artifacts.py`):
  `profile`, `feature-contract`, `coverage-ledger`, `runtime-scenario`,
  `parity-matrix`, `unspecified-behavior`, `product-decision`,
  `evidence-reference`, `all`. Each non-`all` subcommand takes one positional
  `path` argument. See Implementation Strategy for the `all` semantics.
- **Poetry console-script entries** (`pyproject.toml`
  `[tool.poetry.scripts]`), one dotted key per artifact type plus one for
  `all`:
  - `"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"`
  - `"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"`
  - `"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"`
  - `"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"`
  - `"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"`
  - `"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"`
  - `"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"`
  - `"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"`
  - `"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"`
  Each `main_<artifact>()` is a thin wrapper delegating to the single
  `main(["<artifact-type>", *sys.argv[1:]])` dispatcher, preserving one
  argument-parsing and exit-code path.
- **Example invocations and expected outputs:**
  - `python -m scripts.dev_tools.validate_discovery_artifacts feature-contract path/to/contract.json`
    → stdout: `feature-contract validation passed: path/to/contract.json`;
    exit code `0`.
  - `dev.discovery.validate-profile path/to/profile.yaml` (or `.md`,
    pending #9001's format decision) with a missing required field → stderr:
    one or more lines such as `Missing required field: legacy_source_path.`;
    exit code `1`.
  - `dev.discovery.validate-coverage-ledger path/to/ledger.json` against a
    non-conforming fixture → stderr: one line per `jsonschema` validation
    error, formatted as `f"{list(err.path)}: {err.message}"` (mirroring
    `validate_json.py:213-221`); exit code `1`.
- **Contracts and validation rules:** every subcommand's underlying pure
  function returns `list[str]` (empty = pass). The CLI layer never inspects
  exceptions from the pure functions as its failure signal; only the
  returned list determines exit status. Malformed input (for example JSON
  that fails to parse) is surfaced as an error string in the list, not as an
  uncaught exception from the CLI.

## Data & State

- **Data transformations and invariants:** validation is stateless and pure
  at the function layer — each `validate_<artifact>_text` call transforms an
  input string into an error list with no side effects, no mutation of its
  input, and no reliance on prior calls. The CLI layer adds only file
  reading (`_read_text`) and stdout/stderr writing; it holds no state across
  invocations.
- **Caching or persistence details:** none introduced by this feature at the
  validator layer. The shared schema-loading module (extracted from
  `validate_json.py`) reuses that module's existing SHA-256-keyed cache for
  `http(s)://` `$schema` references; this feature does not add a new cache.
- **Migration or backfill requirements:** none. No prior validator artifacts
  exist for this feature to migrate.

## Constraints & Risks

- Domain neutrality is an epic invariant: validators are generic over
  schemas and config, never over domain field values. No
  TaskMaster/TMW/Outlook/VSTO/email/task-management identifier may appear in
  validator source, docstrings, error messages, or comments (research-input.md
  section 6).
- Upstream contracts (#9001 domain-profile config, #9002 schemas and
  versioning convention) are not yet finalized. This spec designs against
  the planned contract described in `objective-source.md` sections 3-4 and
  `epic.md`'s Shared Design, and isolates the seams most likely to change:
  - `validate_profile_text` re-checks profile structure independently; if it
    also calls #9001's typed loader, that call is wrapped in a narrow
    `try/except` on #9001's declared loader exception, converted to a single
    error string (no bare `except`).
  - Schema location for the seven schema validators is resolved through one
    `_resolve_schema_path(artifact_type)`-equivalent seam (in practice, the
    artifact's own `$schema` field resolved by the shared loader), so that
    only that seam changes when #9002's versioning convention lands.
  - Profile required-field checks are marked with a `# TODO(#9001)` comment
    until #9001 finalizes the field contract.
- The repository's 500-line file cap drives module decomposition: schema
  validators, the profile validator, and the CLI umbrella are split into
  separate files rather than one large module (research-input.md section 8).
- Reuse `jsonschema` (^4.25.1, `Draft202012Validator`, already a declared
  dependency in `pyproject.toml`) and the existing `validate_json.py`
  governed-glob / `$schema` resolution machinery rather than introducing new
  schema-loading code. This requires extracting the currently-private
  `_load_schema` logic into a public shared module, since importing a
  `_`-prefixed name across modules violates the internal-name convention in
  `.claude/rules/python.md`.
- Fixture availability risk: #9002 has not yet produced conforming and
  non-conforming fixtures. Until they exist, pure-function tests use inline
  literals; fixture-based tests are added once #9002 ships its fixture set.

## Implementation Strategy

- **Implementation scope:** add a domain-profile validator and seven
  per-schema validators, a thin argparse CLI umbrella exposing one
  subparser per artifact type plus `all`, and Poetry console-script entries
  for each. Extract shared schema-loading logic from `validate_json.py` into
  a public module usable by both `validate_json.py` and the new discovery
  validators. Add mirrored tests. No code from #9004, #9010, or #9011 is
  produced here; those features consume this feature's output.
- **New modules, classes, and functions:**
  - `scripts/dev_tools/validate_discovery_artifacts.py` — umbrella CLI:
    `build_parser() -> argparse.ArgumentParser`, `_read_text(path) -> str`,
    `_validate_from_args(args) -> list[str]`, `main(argv=None) -> int`, and
    one thin `main_<artifact>() -> int` wrapper per artifact type (calling
    `main(["<artifact-type>", *sys.argv[1:]])`). Contains no validation
    logic itself.
  - `scripts/dev_tools/validate_discovery_profile.py` —
    `validate_profile_text(text: str) -> list[str]` plus internal profile
    helper functions. Required-field checks against #9001's contract are
    marked `# TODO(#9001)` pending finalization.
  - `scripts/dev_tools/validate_discovery_schema_artifacts.py` — seven thin
    `validate_<schema>_text(text: str) -> list[str]` functions (one per
    Feature Contract, Coverage Ledger, Runtime Characterization Scenario,
    Parity Matrix, Unspecified Behavior Record, Product Decision Record,
    Evidence Reference), each delegating to one shared
    `_validate_against_schema(text: str, artifact_type: str) -> list[str]`
    helper that parses JSON, resolves the schema through the shared loader,
    runs `Draft202012Validator(schema).iter_errors(data)`, sorts by
    `e.path`, and formats each error as `f"{list(err.path)}: {err.message}"`
    (mirroring `validate_json.py:213-221`). If this file would exceed 500
    lines once #9002's schemas are finalized, split it per schema (for
    example `validate_discovery_schema_feature_contract.py`, etc.), per the
    500-line cap.
  - Shared schema-loading extraction: promote the schema-resolution logic
    presently in `validate_json.py`'s private `_load_schema` into a public
    function in a shared module (either a new public function in
    `json_config.py` or a new `scripts/dev_tools/schema_loading.py`),
    imported by both `validate_json.py` and
    `validate_discovery_schema_artifacts.py`. This is a modification to an
    existing file (`validate_json.py`) outside the primary new-file set and
    must be called out explicitly in the plan's file-change list.
  - `pyproject.toml` — add the nine `dev.discovery.validate-*` script
    entries listed in API / CLI Surface.
  - `all` subparser semantics (design decision, flagged as an open gap in
    research-input.md section 9, item 8): `all` takes one positional `path`
    and validates it against every one of the eight artifact-type
    validators in a fixed order (`profile`, then the seven schemas in the
    order listed above), collecting each validator's error list under a
    per-type prefix line (for example `feature-contract: <error>`). `all`
    succeeds (`exit 0`) only if at least one per-type validator returns an
    empty list; if every per-type validator returns errors, `all` fails
    (`exit 1`) and prints the collected, per-type-prefixed errors to stderr.
    This treats `all` as "validate this one path against every known type
    and report which type(s), if any, it conforms to" rather than a
    directory scan — the CLI does not do type inference from file content
    or path shape, keeping the dispatcher deterministic and free of
    heuristics.
- **Dependency changes:** none. `jsonschema` (^4.25.1) and `PyYAML` (>=6.0)
  are already declared in `pyproject.toml`; no new third-party dependency is
  added.
- **Logging/telemetry additions:** none beyond the canonical stdout/stderr
  contract described in Inputs / Outputs. No structured logging or
  telemetry emission is introduced.
- **Rollout plan:** no feature flag or staged deploy. The validators are
  additive, opt-in-by-invocation CLI tooling and library functions; nothing
  in existing CI or hook configuration invokes them until #9004 wires them
  into a completion gate.

## Definition of Done

- [x] A pure `validate_<artifact>_text(text: str, ...) -> list[str]` function
      exists for the domain-profile config and for each of the seven schemas.
- [x] A single argparse CLI (`validate_discovery_artifacts.py`) exposes one
      subparser per artifact type plus `all`, following the canonical
      pattern (errors to stderr, one success line to stdout, `main() -> int`
      returning 0/1).
- [x] `dev.discovery.validate-*` Poetry console-script entries are
      registered in `pyproject.toml` for every artifact type and `all`.
- [x] Schema-location resolution for the seven schema validators goes
      through the shared loader keyed off each artifact's `$schema` field,
      with no hardcoded schema directory or version string.
- [x] No TaskMaster/TMW/Outlook/VSTO/email/task-management identifier
      appears in the new validator source, docstrings, error messages, or
      comments.
- [x] Tests updated/added (pure-function tests with inline literals now;
      fixture-based tests wired to #9002's fixtures once they ship).
- [x] Edge cases and error handling covered by tests (malformed JSON,
      missing `$schema`, missing required profile fields).
- [ ] Docs updated (this spec and user-story, `docs/features/active/...`
      links).
- [ ] Toolchain pass completed (format → lint → type-check →
      architecture-boundary → unit tests → contract/schema checks →
      integration tests) with line coverage >= 85% and branch coverage
      >= 75% on all new/changed files.

## Seeded Test Conditions (from potential)
- [x] Conforming fixture accepted (empty error list) for each artifact type.
- [x] Non-conforming fixture rejected with specific error strings for each type.
- [x] CLI subparser dispatch for each artifact type and `all`.
- [x] CLI exit codes: 0 on success, 1 on validation failure.
- [x] Schema-location resolution follows the #9002 versioning convention.
- [x] `all` subcommand: succeeds when the path conforms to at least one
      artifact type and reports per-type-prefixed errors when it conforms to
      none.
- [x] Domain-neutrality grep gate: no TaskMaster/TMW/Outlook/VSTO/
      task-management token in new source files.
