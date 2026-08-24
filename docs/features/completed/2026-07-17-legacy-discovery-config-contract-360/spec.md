# legacy-discovery-config-contract — Spec

- **Issue:** #360
- **Parent (optional):** Epic `legacy-discovery-and-parity` (child feature #9001, Wave 0, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 0.2

## Overview

The legacy-discovery-and-parity epic requires a domain-neutral core framework whose domain
specificity is supplied at runtime, never hardcoded. The foundational cross-module contract is
a repository-local domain-profile configuration file that a consumer repository (for example a
legacy-source repository and its modern-target counterpart) authors to declare its legacy
source location, target location, technology stack, and artifact conventions/paths. Without a
typed, fail-fast loader for this profile, every downstream epic feature (validators, analyzers,
agent roles, skills) would have to parse domain configuration ad hoc, reintroducing domain
coupling.

This feature delivers three things:

1. The **domain-profile configuration contract**: the documented field set (required and
   optional) that a consumer repository declares, expressed domain-neutrally.
2. A **typed, dataclass-based Python loader** that parses the profile and fails fast with
   specific, actionable errors on malformed input or missing required fields.
3. A **`dev.discovery.*` Python CLI entry point** that loads and shows a resolved profile.

It also records the epic's explicit specification decision — PyYAML versus the repository's
hand-rolled frontmatter regex convention — in the `## Specification Decision` section below.

## Scope

### In scope

- The domain-profile field contract (`discovery-profile.yaml` at the consumer repository
  root by default), documented in `## Domain-Profile Field Contract` below.
- A new Python package `scripts/dev_tools/discovery/` containing:
  - `domain_profile.py` — exception type, frozen dataclasses, typed extraction helpers,
    `parse_domain_profile_text`, `load_domain_profile`, and the `DEFAULT_PROFILE_FILENAME`
    constant.
  - `profile_cli.py` — argparse surface and `main` for the console script.
  - `__init__.py` — re-export of the public loader surface.
- One `[tool.poetry.scripts]` line: `"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"`.
- Unit tests under `tests/scripts/dev_tools/discovery/` meeting the repository quality-tier
  policy (pytest, line coverage >= 85%, branch coverage >= 75%).

### Out of scope (owned by sibling epic features)

- **JSON schema files** for the domain profile or any discovery artifact — owned by feature
  #9002 (`legacy-discovery-schemas`).
- **Standalone validators** following the `validate_<artifact>_text(text) -> list[str]`
  pattern with an argparse subparser CLI — owned by feature #9003
  (`legacy-discovery-validators`). This feature's `parse_domain_profile_text(text, source)`
  provides the text-in interface #9003 will build on, but this feature ships no
  `validate_*_text` validator and no schema file.
- The artifact-kind vocabulary and per-kind schemas referenced by `artifacts.conventions`
  keys — owned by #9002/#9005. The loader stores the conventions mapping without validating
  its keys; feature review must not read the free-form mapping as a gap.
- Path existence/reachability checks — a runtime concern for validators (#9003) and
  analyzers (#9006). The loader validates shape and types only.

## Specification Decision: PyYAML vs Hand-Rolled Frontmatter Regex

**Decision: adopt PyYAML via `yaml.safe_load`.** The loader is the first `import yaml` in
the repository; this is the intended outcome of the epic's explicit specification decision.

Justification, per the research record
(`research/2026-07-17T10-40-config-contract-research.md`):

1. **PyYAML is an already-declared but unused Poetry dependency.** `pyproject.toml`
   declares `PyYAML = ">=6.0"` under `[tool.poetry.dependencies]`, and no `import yaml`
   exists anywhere in the repository today. Adopting it adds zero new dependencies. The
   single documented reason the existing regex precedent avoided PyYAML
   (`push_down_claude_filesystem.py`: "avoids adding a runtime YAML dependency ... reading
   only the single leaf") does not apply here — the dependency cost is already paid and the
   profile is not a single leaf.
2. **The regex precedents cannot express the required structure.** The profile requires
   nested mappings, lists of strings, and typed scalars. The repository's two hand-rolled
   precedents demonstrably cannot represent this:
   - `scripts/dev_tools/push_down_claude_filesystem.py` (`_FRONTMATTER_PATTERN` and
     companions) extracts exactly one hardcoded two-level scalar leaf (`metadata.scope`)
     and nothing else.
   - `scripts/dev_tools/codex_native_converter/parser.py` (`_parse_frontmatter`) flattens
     nesting into an indistinguishable flat `dict[str, str]`, silently drops YAML list
     items (lines containing no `:`), types every value as `str`, and reports no syntax
     errors — malformed input silently yields partial dictionaries.
   Extending the regex convention to full nested structure would amount to writing an
   untyped YAML parser by hand, violating the simplicity-first design principle and
   inflating the test surface.
3. **`yaml.safe_load` is the safe loader.** It constructs only plain Python types (no
   arbitrary object instantiation) and passes the repository's ruff bandit ruleset
   (`yaml.load` without a safe loader triggers S506; `safe_load` does not). It also
   reports syntax errors with line/column marks, which the regex precedents cannot do.

**Rejected alternatives:** extending the hand-rolled regex convention (rejected per point
2); a JSON profile (loses comments/readability for a human-authored config, and the epic
frames the decision as PyYAML-vs-regex over a YAML-style contract); a TOML profile
(`tomllib` is stdlib only on Python 3.11+, below the repository's 3.10 floor, and has no
repository precedent).

**Pyright-strict tactic:** `yaml.safe_load` returns `Any`. The untyped boundary is isolated
in a single helper, `_load_yaml_mapping(text, source) -> dict[str, object]`, which
isinstance-narrows the result and rejects non-mapping documents with a specific error. All
downstream extraction helpers take `object` and narrow with `isinstance` — no `cast`
chains, no `# type: ignore`. Pyright bundles typeshed's third-party PyYAML stubs as a
fallback; if the strict-mode run surfaces a missing-stub diagnostic, adding `types-PyYAML`
to the dev group is the fix, but it is a new dev dependency requiring explicit approval and
must be surfaced in the plan as a conditional step.

## Domain-Profile Field Contract

Default filename at the consumer repository root: `discovery-profile.yaml`, exposed as the
module constant `DEFAULT_PROFILE_FILENAME`. All field names and enum values are
domain-neutral; stack identifiers are free-form strings supplied by the consumer.

```yaml
profile_version: 1                # required, int. Only 1 is accepted; gate for evolution.
profile_name: "my-migration"      # optional, str. Label used by reports; no semantics.

legacy_source:                    # required mapping
  root: "../LegacyCheckout"       # required, non-empty str. Path to legacy source
                                  # (absolute, or relative to the profile file's directory).
  description: "..."              # optional str
  include: ["src/**"]             # optional list[str] of glob patterns; default: all
  exclude: ["**/bin/**"]          # optional list[str] of glob patterns; default: none

target:                           # required mapping
  root: "../TargetCheckout"       # required, non-empty str
  description: "..."              # optional str

technology_stack:                 # required mapping
  legacy: ["csharp"]              # required, non-empty list of non-empty str (free-form)
  target: ["typescript"]          # optional list of non-empty str; default: empty

artifacts:                        # required mapping
  root: "discovery/"              # required, non-empty str. Workspace root (relative to
                                  # the consumer repo) where discovery artifacts are written.
  conventions:                    # optional mapping str -> non-empty str. Artifact-kind
    feature-contract: "contracts/"    # keys are free-form here; the kind vocabulary and
    coverage-ledger: "coverage.json"  # per-kind schemas are owned by #9002/#9005.
```

Contract rules:

- **Required fields:** `profile_version`, `legacy_source.root`, `target.root`,
  `technology_stack.legacy`, `artifacts.root`.
- **Optional fields with defaults:** `profile_name` (None), `legacy_source.description`
  (None), `legacy_source.include` (empty), `legacy_source.exclude` (empty),
  `target.description` (None), `technology_stack.target` (empty), `artifacts.conventions`
  (empty mapping).
- **Unknown keys are rejected** at the top level and inside each known section, with an
  error naming the offending key and listing the allowed keys. Rationale: fail-fast typo
  protection; `profile_version` is the forward-compatibility gate, so strictness does not
  block evolution.
- **Shape and types only.** The loader does not check that `root` paths exist.
  Existence/reachability belongs to #9003 and #9006. The CLI may resolve and display
  absolute paths without asserting existence.
- **Path portability note:** `root` values are stored verbatim with no normalization.
  Forward slashes are recommended for portability; no code behavior in this feature depends
  on the separator.

## Loader Contract

Module: `scripts/dev_tools/discovery/domain_profile.py`.

### Dataclasses

All dataclasses are `frozen=True` (repository precedent; value objects with invariants
asserted in `__post_init__`):

- `LegacySourceConfig(root: str, description: str | None = None, include: tuple[str, ...] = (), exclude: tuple[str, ...] = ())`
- `TargetConfig(root: str, description: str | None = None)`
- `TechnologyStackConfig(legacy: tuple[str, ...], target: tuple[str, ...] = ())`
- `ArtifactsConfig(root: str, conventions: tuple[tuple[str, str], ...] = ())` — conventions
  stored as ordered pairs to keep the frozen dataclass immutable and hashable; a
  `conventions_map` property exposes `dict[str, str]`.
- `DomainProfile(profile_version: int, legacy_source: LegacySourceConfig, target: TargetConfig, technology_stack: TechnologyStackConfig, artifacts: ArtifactsConfig, profile_name: str | None = None)`

YAML lists are normalized to tuples so frozen instances are truly immutable.

### Functions

- `parse_domain_profile_text(text: str, source: str = "<string>") -> DomainProfile` — pure,
  no I/O. Wraps `yaml.YAMLError` into `DomainProfileError` with the source label and the
  YAML mark. Rejects non-mapping documents. Walks the mapping section-by-section collecting
  **all** field errors (missing required field, wrong type, empty string, empty list,
  unknown key, unsupported `profile_version`) and raises a single `DomainProfileError`
  whose message enumerates every error with its dotted field path (for example
  `legacy_source.root: expected non-empty string, got int`).
- `load_domain_profile(path: Path) -> DomainProfile` — thin I/O wrapper:
  `read_text(encoding="utf-8")` then delegate to the text function; wraps
  `FileNotFoundError`/`OSError` into `DomainProfileError` with the path in the message.

### Fail-fast validation (two layers)

1. **Parse layer (primary):** collect-then-raise as described above, producing one
   actionable multi-error message per invalid profile.
2. **Dataclass `__post_init__` (defense-in-depth):** each dataclass re-asserts its local
   invariants (non-empty `root`, non-empty `legacy` tuple, `profile_version == 1`,
   non-empty convention keys/values) and raises `DomainProfileError`, so a direct
   constructor call cannot produce an invalid instance.

### Exception type

One module-level `class DomainProfileError(ValueError)` — a specific, catchable type per
the fail-fast rule; the `ValueError` base matches the repository's existing user-facing
validation errors. No broad `except Exception` anywhere; the CLI boundary catches only
`DomainProfileError`.

### Domain-neutrality invariant

The loader and CLI modules must contain no TaskMaster/TMW/Outlook/VSTO/email/
task-management identifiers in code, field names, defaults, error messages, or docstrings.
Domain specificity is runtime configuration read from the profile. A contract test scans
the production module sources for banned substrings (`taskmaster`, `tmw`, `outlook`,
`vsto`, `email`, `task-management`) case-insensitively.

## CLI Contract

- **Console script:** `dev.discovery.profile`, one line in `[tool.poetry.scripts]`:
  `"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"`. The
  `scripts/dev_tools/discovery/` package follows the existing subpackage precedent
  (`pr_context`, `atomic_executor`) and reserves a coherent home for later
  `dev.discovery.*` commands shipped by sibling features.
- **Argparse surface** (`profile_cli.py`):
  - `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace` with a flat
    parser (a single verb needs no subparsers; the subparser pattern belongs to #9003):
    - positional `profile_path`, `nargs="?"`, default `discovery-profile.yaml` via
      `DEFAULT_PROFILE_FILENAME`.
    - `--json`: emit the resolved profile as JSON (`dataclasses.asdict` + `json.dumps`,
      sorted keys). Default output is aligned `key: value` text of the resolved profile —
      declared values plus applied defaults.
  - `main(argv: Sequence[str] | None = None) -> int`.
  - Terminates with `if __name__ == "__main__": raise SystemExit(main())`.
- **Exit codes:**
  - `0` — profile loaded; resolved profile printed to stdout.
  - `1` — `DomainProfileError` (missing file, unreadable file, malformed YAML, failed
    validation); the full multi-error message is printed to stderr.
  - `2` — usage errors, via argparse's built-in behavior (unchanged).

## Inputs / Outputs

- **Inputs:** a domain-profile YAML file (default `discovery-profile.yaml`, overridable via
  the positional CLI argument); no environment variables.
- **Outputs:** resolved-profile text or JSON on stdout; error messages on stderr; process
  exit code. No artifacts, logs, or telemetry are written.
- **Config keys and defaults:** the field contract above is the complete key set.
- **Versioning / backward compatibility:** `profile_version` is the evolution gate; only
  the integer `1` is accepted by this feature. Unknown keys are rejected; future versions
  relax this only behind a new `profile_version` value.

## Data & State

- Pure transformation: YAML text -> validated frozen `DomainProfile` dataclass graph. No
  caching, persistence, state mutation, or migration. The parse layer performs no I/O; all
  filesystem access is confined to `load_domain_profile` and the CLI boundary, per the I/O
  Boundaries rule.

## Constraints & Risks

- Domain neutrality is an epic-wide invariant: the loader must contain no domain-specific
  behavior; domain specificity is runtime configuration read from the domain profile.
- Out of scope: the JSON schema files (feature #9002) and the standalone validators
  (feature #9003). This feature owns only the profile config contract and its typed loader.
- Substrate: PyYAML>=6.0 is declared in Poetry but not imported anywhere today; all
  existing YAML/frontmatter parsing is hand-rolled regex. This feature introduces the
  repository's first `import yaml`; reviewers should expect the previously-unused declared
  dependency to become load-bearing.
- Pyright strict mode may require `types-PyYAML` in the dev group if the bundled typeshed
  fallback stubs are insufficient; that is a new dev dependency requiring explicit approval
  and must be surfaced as a conditional plan step, not added silently.
- Convention keys are unvalidated by design; the artifact-kind vocabulary belongs to
  #9002/#9005.

## Implementation Strategy

- **Implementation scope:** new package `scripts/dev_tools/discovery/` (`__init__.py`,
  `domain_profile.py`, `profile_cli.py`); one `[tool.poetry.scripts]` line; test modules
  `tests/scripts/dev_tools/discovery/test_domain_profile.py` and
  `tests/scripts/dev_tools/discovery/test_profile_cli.py`.
- **New surface:** `DomainProfileError`, five frozen dataclasses,
  `parse_domain_profile_text`, `load_domain_profile`, `DEFAULT_PROFILE_FILENAME`,
  `parse_args`, `main`.
- **Dependency changes:** none at runtime (PyYAML is already declared); conditionally
  `types-PyYAML` (dev group) only if Pyright strict requires it, with explicit approval.
- **File-size limit:** every production and test file stays under 500 lines; if
  `domain_profile.py` approaches the limit, the dataclasses move to a
  `domain_profile_models.py` sibling (existing repository precedent), and an oversized test
  module splits into a `_part2` module.
- **Logging/telemetry:** none; the CLI communicates via stdout/stderr and exit codes.
- **Rollout:** no feature flags; the console script is inert until invoked.

## Testing Requirements

- Framework: pytest. Coverage thresholds per repository quality-tier policy: line >= 85%,
  branch >= 75%. `scripts/dev_tools` is already in the coverage source set, so the new
  package is measured automatically; no coverage exclusions are added.
- **No temporary files.** Parse-layer tests feed inline YAML strings to
  `parse_domain_profile_text` (no filesystem at all). `load_domain_profile` and CLI `main`
  tests use the `mem_fs_path` in-memory filesystem fixture from `tests/conftest.py`;
  pytest `tmp_path` is not used.
- Test layout mirrors production: `tests/scripts/dev_tools/discovery/`.
- Scenario matrix:
  - Positive: full profile (every optional field present); minimal profile (each default
    value asserted).
  - Negative, parametrized: each of the five required fields missing (dotted path asserted
    in the error); type mismatches (string where list, list where string, string
    `profile_version`, non-mapping section); empty-string roots; empty `legacy` list;
    unsupported `profile_version: 2`; unknown top-level key; unknown key in each section;
    malformed YAML syntax (source label asserted); non-mapping document; one profile with
    three defects reported in a single raise.
  - Direct-construction invariants: each dataclass raises `DomainProfileError` on invalid
    construction (covers `__post_init__` branches).
  - `load_domain_profile`: happy path and missing-file path via `mem_fs_path`.
  - Domain-neutrality contract test: production module sources contain no banned domain
    substring.
  - CLI: `parse_args` defaults and flags; `main` success text output (exit 0); `--json`
    output round-trips via `json.loads` (exit 0); missing file -> exit 1 with stderr
    message; malformed profile -> exit 1 with all field errors on stderr;
    default-filename resolution.

## Acceptance Criteria

- [x] The domain-profile configuration contract is documented in this spec with all
      required fields (`profile_version`, `legacy_source.root`, `target.root`,
      `technology_stack.legacy`, `artifacts.root`) and all optional fields with their
      defaults, using domain-neutral names.
- [x] A dataclass-based typed loader (`parse_domain_profile_text` /
      `load_domain_profile` in `scripts/dev_tools/discovery/domain_profile.py`) parses a
      valid profile into a frozen `DomainProfile` instance.
- [x] The loader raises `DomainProfileError` for each missing required field, naming the
      field's dotted path in the error message.
- [x] The loader raises `DomainProfileError` on malformed input: YAML syntax errors (with
      source label), non-mapping documents, type mismatches, empty required strings/lists,
      unsupported `profile_version`, and unknown keys.
- [x] A single invalid profile with multiple defects produces one `DomainProfileError`
      enumerating every defect.
- [x] The parser-technology decision is recorded and justified in this spec: PyYAML via
      `yaml.safe_load`, citing the already-declared unused Poetry dependency, the
      structural inability of both regex precedents (`push_down_claude_filesystem.py`
      `_FRONTMATTER_PATTERN`, `codex_native_converter/parser.py` `_parse_frontmatter`) to
      express nested maps/lists, and `safe_load` safety.
- [x] The `dev.discovery.profile` console script exists as one `[tool.poetry.scripts]`
      line targeting `scripts.dev_tools.discovery.profile_cli:main`.
- [x] The CLI loads and displays a resolved profile (declared values plus applied
      defaults) with exit code 0, supports `--json` output, and exits 1 with the full
      error message on stderr for a missing, unreadable, or invalid profile.
- [x] The loader and CLI production modules contain no domain-specific
      (TaskMaster/TMW/Outlook/VSTO/email/task-management) identifiers, verified by a
      domain-neutrality contract test.
- [x] Tests satisfy repository quality-tier policy: pytest, line coverage >= 85%, branch
      coverage >= 75%, no temporary files (in-memory filesystem fixture only), test tree
      mirroring the production tree.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: valid profile parse, each required-field-missing case, malformed-syntax case, type-mismatch case.
- [ ] CLI: load-and-show a resolved profile; non-zero exit on malformed/missing profile.
- [ ] Edge cases: optional fields defaulting, unknown-field handling.
