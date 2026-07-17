# legacy-discovery-acceptance-scenarios — Spec

- **Issue:** #364
- **Parent (optional):** epic `legacy-discovery-and-parity` (child feature; epic placeholder #9009)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T15-00
- **Status:** Draft
- **Version:** 0.2

## Overview

The `legacy-discovery-and-parity` epic delivers a domain-neutral capability for migrating a
legacy application to a modern architecture. One required output is a set of executable
acceptance scenarios derived from the machine-readable discovery artifacts, so a consumer
repository can verify source-to-target parity against concrete, reproducible scenarios rather
than prose.

This feature provides a deterministic acceptance-scenario generator that consumes three
discovery schemas — the Feature Contract, the Parity Matrix, and the Runtime Characterization
Scenario — and emits executable acceptance scenarios in a defined JSON output format. The
generator ships as a `dev.discovery.*` Python Poetry console-script. It is a pure transform
from input artifacts to an output document.

The design is grounded in the feature research at
`docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/research/2026-07-17T15-00-acceptance-scenario-generation-research.md`
and in the epic scope item 11 ("Acceptance-Scenario Generation") and section 4 schemas of
`docs/features/epics/legacy-discovery-and-parity/objective-source.md`.

## Scope

### In scope

- A Python generator module under `scripts/dev_tools/` that transforms the three input
  discovery artifacts into a single JSON acceptance-scenario document.
- A defined, versioned JSON output scenario-document format with structured Given/When/Then
  arrays.
- Byte-identical deterministic generation.
- A `dev.discovery.*` Poetry console-script exposing the generator.
- A single schema-location seam function that isolates schema-location knowledge so this
  feature can proceed before feature #9002 (schemas) lands.
- Named projection/adapter read surfaces for each of the three input schemas.
- Unit, determinism, negative-path, seam, and CLI tests meeting the repository quality-tier
  policy.

### Out of scope

- Reports (coverage report, parity report, completion report) — owned by feature #9010.
- Static analyzers (repository/project inventory, .NET/C#, VSTO/Office) — owned by features
  #9006 and #9014.
- The concrete schema field names and the `schemas/vN/` directory tree — owned by feature
  #9002. This feature designs against `objective-source.md` section 4 and isolates schema
  location behind one seam.
- MCP tool and VS Code command exposure — owned by feature #9011.
- Validators following the `validate_<artifact>_text` pattern — owned by feature #9003. This
  feature is a generator, not a validator.

## Behavior

Provide a deterministic acceptance-scenario generator that consumes the Feature Contract, the
Parity Matrix, and the Runtime Characterization Scenario, and emits executable acceptance
scenarios in the JSON output format defined below.

- Deterministic: identical input artifacts produce byte-identical scenario output.
- Domain-neutral: no TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior or
  identifiers.
- Ships a `dev.discovery.*` Python CLI entry point (Poetry console-script) for generation.
- Locates the input schemas via the schema-versioning convention defined by feature #9002,
  isolated behind a single schema-location seam so this feature can proceed before #9002 lands.

## Output Scenario Format

The generator emits one JSON acceptance-scenario-set document per invocation, serialized with
the repository's canonical deterministic form:

```
json.dumps(obj, sort_keys=True, indent=2, ensure_ascii=False) + "\n"
```

This mirrors the established byte-identical idiom in `scripts/dev_tools/format_json.py`
(sorted keys, fixed two-space indent, explicit trailing newline).

### Top-level document fields

| Field | Type | Description |
|---|---|---|
| `$schema` | string | Self-reference to the Acceptance Scenario Set schema, resolved per the #9002 versioning convention. |
| `schema_version` | string | Version string; mirrors the input schema-versioning convention. |
| `generator` | string | Constant identifier `"dev.discovery.acceptance-scenarios"`. |
| `source_digest` | string | SHA-256 over the concatenated canonicalized inputs. Deterministic; never a clock value. |
| `scenarios` | array | Array of scenario objects, sorted by a stable total-order key (see Deterministic Generation). |

### Scenario object fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Stable identifier derived from the Feature Contract identifier plus the parity/characterization reference. Deterministic; no RNG. |
| `title` | string | Human title carried from the Feature Contract. |
| `feature_ref` | string | Feature Contract identifier. |
| `parity_ref` | string \| null | Parity Matrix row identifier, or `null` when no parity row applies. |
| `characterization_ref` | string \| null | Runtime Characterization Scenario identifier, or `null` when none applies. |
| `given` | array of strings | Structured precondition steps. |
| `when` | array of strings | Structured action steps. |
| `then` | array of strings | Structured expected-outcome steps. |
| `evidence_refs` | array of strings | Evidence reference identifiers. |

The Given/When/Then triplet is carried as structured arrays inside the JSON document rather
than as free Gherkin text, so the output is both human-readable and machine-consumable. A JSON
array of scenario objects is directly consumable as a pytest-parametrizable data source by
downstream consumers.

### Rejected output formats (from research)

- Gherkin `.feature` plain text: no in-repo BDD dependency, no existing deterministic
  serializer or validator, and quoting/whitespace rules weaken byte-identical guarantees.
- Native pytest parametrization `.py` file: couples output to one runner and one language, and
  generated Python is harder to validate and to keep byte-stable across formatter versions.

## Deterministic Generation

Identical input artifacts must produce byte-identical output. The concrete mechanism:

- **Key sorting.** `json.dumps(..., sort_keys=True, indent=2)` sorts keys for the top-level
  document and every nested object.
- **Scenario ordering.** The `scenarios` array is sorted by a stable total-order key, for
  example `(feature_ref, parity_ref, characterization_ref, id)`, not by input traversal order,
  so reordering inputs or filesystem `glob` order cannot change output.
- **Input-path sorting.** Collected input paths are sorted before processing, because
  `pathlib.glob`/`rglob` order is not guaranteed stable across platforms. The generator does
  not depend on `iter_governed_files` yield order.
- **Set handling.** Any set used internally is converted to a sorted list via `sorted(...)`
  with a total-order key before serialization. A `set` is never serialized directly.

### No seeded RNG or injected clock

No seeded RNG or injected clock is required. Per the research (section 3) and
`.claude/rules/general-unit-test.md` "Determinism Infrastructure", seeded RNG and an injected
clock are required only if a nondeterministic input is involved, and none is. The generator is
a pure transform:

- Wall-clock time is never read in the generator. If a timestamp field is ever needed in
  output, it must be derived from input data (for example a schema `version` or an
  input-provided value), never from `datetime.now()`.
- `source_digest` is a SHA-256 over the canonicalized inputs — deterministic, not a clock
  value.
- No RNG is used; all identifiers are derived deterministically from input fields.

This keeps the "identical inputs produce byte-identical output" acceptance criterion provable
by a determinism test (generate twice, assert equal bytes) without any injected clock or seed
plumbing.

## Input Read Surfaces (projection/adapter)

Because feature #9002 owns the concrete field names, the generator reads each input schema
through a small, named projection (an internal adapter) — a documented mapping from "the
fields the generator reads" to "the schema path where they live." When #9002 fixes field
names, only the projection changes, not the generation logic. The generator must not assume
fields beyond those `objective-source.md` section 4 justifies; unknown or extra fields are
ignored.

The three consumed schemas (designed against `objective-source.md` section 4):

- **Feature Contract** — the unit of behavior to be verified. Projected fields: a stable
  feature identifier (populates `feature_ref` and seeds `id`), a human title (populates
  `title`), and a set of behavioral expectations/acceptance conditions (seed the
  `given`/`when`/`then` steps).
- **Parity Matrix** — source-to-target parity evidence keyed by feature. Projected fields: a
  row identifier that references a feature contract (populates `parity_ref`) and parity
  status/target-behavior expectations (shape `then` expectations).
- **Runtime Characterization Scenario** — observed runtime behavior. Projected fields: a
  scenario identifier (populates `characterization_ref`) and observed
  input/output or precondition/action/outcome observations (ground the `given`/`when` steps).

## Schema-Location Seam

All schema-location knowledge sits behind a single function so this feature can proceed before
#9002 lands and so #9002 later supplies the real location by changing one implementation:

```python
def resolve_discovery_schema(
    schema_name: str,
    *,
    root: Path,
    version: str | None = None,
) -> Path:
    """Return the filesystem path to a versioned discovery schema.

    schema_name is a domain-neutral key such as "feature-contract",
    "parity-matrix", or "runtime-characterization-scenario".
    Until #9002 lands, this raises a clear error naming the expected
    convention (e.g. schemas/v1/<schema_name>.schema.json); after #9002
    lands it returns the governed path resolved via the #9002 layout.
    """
```

Design points:

- Keyword-only `root` and `version` follow the general-code-change policy preference for
  keyword-style parameters with defaults, and mirror the repository pattern of resolving root
  via `Path(__file__).resolve().parents[2]`.
- This function is the sole place that knows the directory layout and `$schema` self-reference
  strategy. The generator and all tests reference it, never a literal schema path.
- Before #9002 lands, the seam's default-location branch raises a clear `FileNotFoundError`
  naming the expected `schemas/vN/` convention. Execution proceeds by injecting explicit
  input paths through the CLI; the generator does not require the schema tree to exist to run
  against caller-supplied input files.
- When #9002 lands, the seam's implementation resolves paths via the governed-glob machinery
  and the schemas' `$schema` self-reference; downstream code is unchanged.

## API / CLI Surface

- **Module:** `scripts/dev_tools/generate_acceptance_scenarios.py`.
- **Poetry console-script** (`pyproject.toml` `[tool.poetry.scripts]`):

  ```
  "dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
  ```

  This matches the quoted-dotted-key `dev.<name> = "scripts.dev_tools.<module>:main"` form
  already used for `dev.validate-json` and `dev.format-json`, and aligns with the
  `dev.discovery.*` namespace required by `objective-source.md` scope item 9.

- **Module structure** (following `validate_json.py` and `format_json.py`):
  - `from __future__ import annotations`; `TYPE_CHECKING`-guarded `Sequence`/`Iterable`
    imports.
  - `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace` building its own
    `argparse.ArgumentParser` with:
    - input path arguments for the three artifacts (feature contract, parity matrix, runtime
      characterization scenario), or a single input-directory argument;
    - `--output` path for the generated scenario document (stdout when omitted);
    - `--check` (optional) to assert the output on disk matches regenerated output without
      writing, mirroring `format_json`'s `--check` semantics.
  - `def main(argv=None) -> int` calling `parse_args(argv or sys.argv[1:])`, resolving root
    via `Path(__file__).resolve().parents[2]`, invoking the pure generation function, printing
    status, and returning an int exit code.
  - Pure generation logic (schema read + transform + canonical serialize) in standalone
    functions separate from argparse/I/O, per general-code-change "Separation of concerns".
    `main` is the thin I/O wrapper, keeping the transform testable without the filesystem.
  - `if __name__ == "__main__": sys.exit(main())`.

- **Exit-code convention:** `0` on success; `1` on any failure (missing input, non-object JSON
  root, JSON parse error, document missing a required field, or `--check` mismatch). No other
  codes are used, matching `validate_json.py` and `format_json.py`.

## Data & State

- The generator performs a pure in-memory transform: read three input JSON artifacts, project
  the required fields, assemble scenario objects, sort deterministically, and serialize.
- No caching, no persistence beyond writing the single output document (or emitting it to
  stdout).
- No migration or backfill.
- The only external location dependency (schema location from #9002) is isolated behind the
  `resolve_discovery_schema` seam.

## Domain-Neutrality Invariant

The generator must contain no domain-specific identifiers. Specifically, no
TaskMaster/TMW/Outlook/VSTO/email/task-management identifiers may appear in the generator
module or its output field names. Schema keys and output field names are generic
(`feature_ref`, `parity_ref`, `characterization_ref`, `given`, `when`, `then`,
`evidence_refs`) and the structure is generic over the input schemas. Domain specificity, when
present, is configuration supplied at runtime, per the epic "Shared Design" and
`objective-source.md` "Architectural Boundaries".

## Testing Obligations

Per `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` (feature
complexity band C3; coverage uniform across tiers: line >= 85%, branch >= 75%).

- **Test file location** (mirrored tree):
  `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`.
- **Unit / positive:** generation from conforming Feature Contract + Parity Matrix + Runtime
  Characterization inputs produces the expected scenario document; assert the structured
  `given`/`when`/`then` mapping and the derived stable `id`.
- **Determinism:** generate twice from identical in-memory inputs and assert byte-identical
  output; assert output is invariant to input ordering (shuffle input order, assert identical
  output).
- **Negative / malformed input:** missing input file, non-object JSON root, JSON parse error,
  and a document missing a required field. Assert exit code `1` and a clear message.
- **Schema-location seam:** assert `resolve_discovery_schema` raises a clear `FileNotFoundError`
  naming the expected convention when the schema tree is absent (pre-#9002), and that the
  generator runs against explicitly supplied input paths without the schema tree present.
  Monkeypatch the seam to verify downstream code calls it rather than hard-coded paths.
- **CLI:** `parse_args` defaults and flags (`--output`, `--check`), and `main([...])` return
  codes for success, failure, and `--check` mismatch.
- **No temporary files:** use the `mem_fs_path` fixture (`tests/conftest.py`) for any
  read/write. `tmp_path` and real temp files are prohibited by policy.
- **Structure:** Arrange-Act-Assert with descriptive names and docstrings.
- **File-size limit:** the module and the test file each stay under 500 lines.

## Constraints & Risks

- Depends on the schema shapes defined by #9002, which is prepared in parallel; design against
  `objective-source.md` section 4 and isolate schema location behind one seam.
- Determinism infrastructure (seeded RNG, injected clock) is not required because the generator
  is a pure transform with no nondeterministic input.
- Reports (#9010) and analyzers (#9006, #9014) are out of scope for this feature.
- Evidence output must be under
  `docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/evidence/<kind>/`
  only.

## Implementation Strategy

- **Scope of change:** add `scripts/dev_tools/generate_acceptance_scenarios.py`, add the one
  `pyproject.toml` console-script line, and add
  `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`.
- **New functions:** `resolve_discovery_schema(schema_name, *, root, version=None) -> Path`
  (schema-location seam); per-schema projection/adapter functions; a pure generation function
  producing the scenario-document object; a canonical serialize helper; `parse_args`; and
  `main(argv=None) -> int`.
- **Dependency changes:** none. The feature reuses `json`, `hashlib`, `argparse`, and
  `pathlib` from the standard library and the existing `validate_json.py`/`format_json.py`
  conventions.
- **Logging/telemetry:** status messages printed by `main`, consistent with the reference
  modules; no new telemetry surface.
- **Rollout:** no feature flag. The seam's pre-#9002 branch raises a clear error naming the
  expected convention, so behavior is well-defined before and after #9002 lands.

## Acceptance Criteria

- [ ] A Python module `scripts/dev_tools/generate_acceptance_scenarios.py` generates
      acceptance scenarios from the Feature Contract, Parity Matrix, and Runtime
      Characterization Scenario inputs.
- [ ] The output is a single JSON acceptance-scenario-set document with the top-level fields
      `$schema`, `schema_version`, `generator`, `source_digest`, and `scenarios`, and scenario
      objects with `id`, `title`, `feature_ref`, `parity_ref`, `characterization_ref`,
      `given`, `when`, `then`, and `evidence_refs`.
- [ ] Given/When/Then are emitted as structured string arrays, not free Gherkin text.
- [ ] Output is serialized with `json.dumps(obj, sort_keys=True, indent=2, ensure_ascii=False)`
      plus a trailing newline, and generation is byte-identical for identical inputs.
- [ ] Output is invariant to input ordering: the `scenarios` array is sorted by a stable
      total-order key and input paths are sorted before processing.
- [ ] The generator uses no seeded RNG and no injected clock; `source_digest` is a SHA-256 over
      the canonicalized inputs and no wall-clock value appears in output.
- [ ] Each input schema is read through a named projection/adapter so a #9002 field-name change
      touches only the adapter, not the generation logic.
- [ ] A single `resolve_discovery_schema(schema_name, *, root, version=None) -> Path` function
      isolates schema location, raises a clear error naming the expected `schemas/vN/`
      convention before #9002 lands, and allows the generator to run against caller-supplied
      input paths in the interim.
- [ ] A `dev.discovery.generate-acceptance-scenarios` Poetry console-script maps to
      `scripts.dev_tools.generate_acceptance_scenarios:main`, and the module exposes
      `def main(argv=None) -> int` with its own argparse parser.
- [ ] The CLI uses the `0`/`1` exit-code convention: `0` on success, `1` on any failure
      including missing/malformed input and `--check` mismatch.
- [ ] The generator contains no TaskMaster/TMW/Outlook/VSTO/email/task-management identifiers.
- [ ] Tests cover positive generation, determinism, negative/malformed input, the
      schema-location seam, and the CLI; use no temporary files (use `mem_fs_path`); and meet
      line coverage >= 85% and branch coverage >= 75%.
