# Research: Acceptance-Scenario Generation (Issue #364, feature #9009)

- Feature: `legacy-discovery-acceptance-scenarios`
- Canonical issue: #364 (epic placeholder #9009)
- Epic: `legacy-discovery-and-parity`
- Depends on: `legacy-discovery-schemas` (#9002, prepared in parallel — schema files not yet present)
- Date: 2026-07-17
- Repository root (this run): `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3cd689991bf6de80`

## Scope Confirmation

This research covers only the deterministic acceptance-scenario generator described in
objective-source.md scope item 11 ("Acceptance-Scenario Generation") and its dependency on
the schemas of section 4. Reports (#9010) and analyzers (#9006, #9014) are out of scope and
were not researched. The generator must remain domain-neutral: it operates generically over
the schema shapes and must contain no TaskMaster/TMW/Outlook/VSTO/email/task-management
identifiers (epic.md "Shared Design"; objective-source.md "Architectural Boundaries").

## 1. Current State Analysis (verified)

### `dev.*` console-script substrate

Verified in `pyproject.toml` `[tool.poetry.scripts]` (lines 47-69). Two distinct forms exist:

- Package-CLI form: `atomic-executor = "scripts.dev_tools.atomic_executor.cli:main"` (line 48).
- Single-module form under the `dev.` namespace, e.g.
  `"dev.validate-json" = "scripts.dev_tools.validate_json:main"` (line 69),
  `"dev.format-json" = "scripts.dev_tools.format_json:main"` (line 60).

The `dev.` namespace uses quoted keys (the dot requires quoting in TOML) mapping to
`scripts.dev_tools.<module>:main`. This is the exact pattern the delegation prompt names.

### `main(argv=None) -> int` + argparse pattern (verified)

Both `scripts/dev_tools/validate_json.py` and `scripts/dev_tools/format_json.py` follow an
identical structure:

- A module-level `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace`
  building an `argparse.ArgumentParser` (validate_json.py:228-241; format_json.py:95-118).
- `def main(argv: Sequence[str] | None = None) -> int` that calls
  `parse_args(argv or sys.argv[1:])`, resolves the repo root via
  `Path(__file__).resolve().parents[2]`, does the work, prints messages, and returns an int
  exit code (validate_json.py:257-274; format_json.py:121-155).
- `if __name__ == "__main__": sys.exit(main())` (validate_json.py:277-278; format_json.py:158-159).
- `from __future__ import annotations` at the top; imports typed via `TYPE_CHECKING` guard
  (`Sequence`, `Iterable` from `collections.abc`).

Exit-code convention (verified): `return 0` on success, `return 1` on failure. `validate_json.main`
returns `1 if result.failed else 0` (line 274). `format_json.main` returns `1` on parse failure
or when `--check` detects needed changes, else `0` (lines 151-155). No other codes are used.

### Governed-glob / `$schema` resolution machinery (verified)

- `scripts/dev_tools/json_config.py` defines `GOVERNED_GLOBS` (lines 12-16:
  `scripts/**/*.json`, `docs/**/*.json`, `examples/**/*.json`), `EXCLUDE_GLOBS`
  (lines 19-29), and `iter_governed_files(root) -> Iterable[Path]` (lines 32-51). This is the
  "governed-glob machinery" the delegation prompt and epic "Shared Design" reference.
- `scripts/dev_tools/validate_json.py` `_load_schema(uri, cache_dir, base_path=None)`
  (lines 130-164) resolves a document's `$schema`:
  - Relative reference (no URI scheme): resolved against `base_path.parent` (lines 135-143).
  - `file://` scheme: absolute local path (lines 145-150).
  - `http(s)://`: fetched and cached under `.cache/schemas` by SHA-256 of the URI
    (`_cache_path`, lines 77-79; fetch/cache lines 155-164).
  - Any other scheme raises `ValueError("Unsupported schema URI scheme: ...")` (lines 152-153).
- `validate_file` (lines 167-225) reads the doc, requires an object root and a string
  `$schema`, loads the schema, and validates with `jsonschema.Draft202012Validator` when the
  optional dependency is present, otherwise a minimal built-in checker `_collect_schema_errors`
  (lines 82-127). `jsonschema` presence is detected at import via
  `importlib.util.find_spec("jsonschema")` (lines 19-23), and it is a declared dev dependency
  (`pyproject.toml:43`, `jsonschema = "^4.25.1"`).

### Schema directory state (verified)

No `schemas/vN/` tree exists yet. `Glob **/schemas/**/*.json` returns only `.vscode/schemas/*`
(VS Code editor schemas) and one `.cache/schemas/*` cache entry — none are discovery schemas.
This confirms #9002 has not landed and the schema-location seam (research question 4) is required.

### Determinism precedent (verified)

`format_json.py:55` produces canonical output with
`json.dumps(parsed, sort_keys=True, indent=2) + "\n"`. This is the repository's established
technique for byte-identical JSON: sorted keys, fixed 2-space indent, explicit trailing
newline. It is the direct precedent for deterministic scenario output.

### No-temp-files test infrastructure (verified)

`tests/conftest.py:146` defines the `mem_fs_path` fixture: an in-memory `pathlib.Path`-compatible
filesystem that monkeypatches selected `Path` methods so file operations under the returned root
run purely in memory. It exists specifically "to enforce repository policy against temporary file
usage in unit tests" (conftest.py:149-153). Tests use it for read/write scenarios instead of
`tmp_path` (see `tests/scripts/dev_tools/test_validate_json.py` throughout).

## 2. Candidate Approaches — Output Scenario Format (research question 1)

The generator must emit "executable acceptance scenarios" that are deterministic and
domain-neutral. Three reasonable formats were evaluated.

### Recommendation: JSON scenario-document format (governed by a versioned JSON schema)

Emit each scenario set as a single JSON document conforming to a versioned discovery schema
(an "Acceptance Scenario Set" schema, co-versioned under the #9002 convention), serialized with
the repository's canonical deterministic form
(`json.dumps(obj, sort_keys=True, indent=2, ensure_ascii=False) + "\n"`).

Proposed document shape (precise enough for spec.md to fix):

```
{
  "$schema": "<resolved per #9002 versioning convention>",
  "schema_version": "<version string, mirrors input convention>",
  "generator": "dev.discovery.acceptance-scenarios",
  "source_digest": "<sha256 of the concatenated canonicalized inputs>",
  "scenarios": [
    {
      "id": "<stable id derived from feature_contract id + parity/characterization ref>",
      "title": "<from feature contract>",
      "feature_ref": "<feature contract identifier>",
      "parity_ref": "<parity matrix row id, or null>",
      "characterization_ref": "<runtime characterization scenario id, or null>",
      "given": ["<precondition step>", ...],
      "when":  ["<action step>", ...],
      "then":  ["<expected-outcome step>", ...],
      "evidence_refs": ["<evidence reference id>", ...]
    }
  ]
}
```

The Given/When/Then triplet is carried as structured arrays inside the JSON document rather than
as free Gherkin text, so the output is both human-readable and machine-consumable.

Rationale grounded in repository conventions:

- The repository's discovery capability is schema-first (objective-source.md section 4: seven
  versioned JSON schemas). A JSON output document is validated by the same
  `validate_json.py` `$schema`/governed-glob machinery already in place (validate_json.py:167-225),
  giving the output a free deterministic validator and letting the completion-gate hooks (#9004)
  validate generated scenarios with no new loader code.
- Byte-identical determinism is trivially achieved with the established
  `json.dumps(..., sort_keys=True, indent=2)` idiom (format_json.py:55) — no bespoke text
  serializer.
- The format is domain-neutral: field names are generic (`given`/`when`/`then`/`feature_ref`),
  and structure is generic over the input schemas.
- A JSON array of scenario objects is directly consumable as a pytest-parametrizable data source
  by downstream consumers, so the "pytest-parametrizable" requirement is satisfied as a property
  of the JSON format rather than as a competing format.

### Rejected alternatives (brief)

- Gherkin `.feature` plain text: human-friendly and "executable" via a BDD runner, but adds a
  BDD dependency the repository does not have, has no existing deterministic serializer or
  validator in-repo, and quoting/whitespace rules make byte-identical output harder to guarantee.
  Rejected: no in-repo precedent and weaker determinism/validation story.
- Native pytest parametrization file (`.py` emitting `@pytest.mark.parametrize`): tightly couples
  output to one test runner and one language, and generated Python is harder to validate and to
  keep byte-stable across formatter versions. Rejected: less portable and not schema-validatable.
  The recommended JSON format already yields a parametrizable data source without this coupling.

## 3. Deterministic Generation (research question 2)

Sources of nondeterminism to control:

- Dict/JSON key ordering — controlled by `sort_keys=True` in `json.dumps` (format_json.py:55
  precedent). Applies to the top-level document and every nested object.
- Set iteration order and any deduplication — any set used internally must be converted to a
  sorted list before serialization (use `sorted(...)` with a total-order key). Do not serialize
  a `set` directly.
- Scenario ordering — the `scenarios` array must be sorted by a stable, total-order key (for
  example `(feature_ref, parity_ref, characterization_ref, id)`), not by input file traversal
  order, so reordering inputs or filesystem `glob` order cannot change output.
- Input file discovery order — `pathlib.glob`/`rglob` order is not guaranteed stable across
  platforms; sort collected input paths before processing (the generator should not depend on
  `iter_governed_files` yield order).

Seeded RNG / injected clock decision: not required for this feature. The generator is a pure
transform from input artifacts to an output document. Verified against the inputs described in
objective-source.md section 4: none of the three consumed schemas requires the generator to
invent timestamps or random identifiers. Per `.claude/rules/general-unit-test.md`
"Determinism Infrastructure" and the issue Constraints, seeded RNG and an injected clock are
required "only if any nondeterministic input is involved," and none is. Concretely:

- Do not read wall-clock time in the generator. If a timestamp field is ever needed in output,
  it must be derived from input data (for example a schema `version` or an input-provided value),
  never from `datetime.now()`. The recommended `source_digest` field is a SHA-256 over the
  canonicalized inputs (deterministic), not a clock value.
- No RNG is used; all identifiers are derived deterministically from input fields.

This keeps the "identical inputs produce byte-identical output" acceptance criterion provable by
a determinism test (generate twice, assert equal bytes) without any injected clock or seed plumbing.

## 4. Input-Schema Shapes (research question 3)

Designed against objective-source.md section 4 (the only authoritative source available; #9002
has not landed). The generator consumes three of the seven schemas:

- Feature Contract — the unit of behavior to be verified. Expected to carry, at minimum, a stable
  feature identifier, a human title/name, and a set of behavioral expectations/acceptance
  conditions that seed the `given`/`when`/`then` steps. Source: objective-source.md:73 (schema
  list) and scope item 11 ("generate executable acceptance scenarios from feature contracts").
- Parity Matrix — source-to-target parity evidence keyed by feature. Expected to carry rows that
  reference a feature contract and record parity status/target-behavior expectations, used to
  populate `parity_ref` and to shape `then` expectations. Source: objective-source.md:76 and
  scope item 11 ("parity/characterization evidence").
- Runtime Characterization Scenario — observed runtime behavior. Expected to carry a scenario
  identifier and observed input/output or precondition/action/outcome observations, used to
  populate `characterization_ref` and to ground `given`/`when` steps in observed behavior.
  Source: objective-source.md:75 and scope item 11.

Because #9002 owns the concrete field names, spec.md must specify the generator's read surface as
a small, named projection (an internal adapter) over each input schema — a documented mapping from
"the fields the generator reads" to "the schema path where they live" — so that when #9002 fixes
field names, only the projection changes, not the generation logic. The generator must not assume
fields beyond those objective-source.md section 4 justifies; unknown/extra fields are ignored.

## 5. Schema-Location Seam (research question 4)

The three input schemas must be located via the #9002 versioning convention (directory layout
such as `schemas/vN/`, a `version` field, a `$schema` self-reference), which reuses
`validate_json.py`'s governed-glob and `$schema` resolution (epic.md "Shared Design";
`json_config.iter_governed_files`, validate_json.py `_load_schema`). Since #9002 has not landed,
all schema-location knowledge must sit behind a single function so this feature can proceed and
so #9002 later supplies the real location by changing one implementation.

Recommended seam signature (single function, domain-neutral):

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
    Until #9002 lands, this raises FileNotFoundError with a message naming the
    expected convention (e.g. schemas/v1/<schema_name>.schema.json); after #9002
    lands it returns the governed path resolved via the #9002 layout.
    """
```

Design points:

- Keyword-only `root` and `version` follow the general-code-change policy preference for
  keyword-style parameters with defaults, and mirror the repo pattern of resolving root via
  `Path(__file__).resolve().parents[2]` (validate_json.py:259).
- The function is the sole place that knows the directory layout and `$schema` self-reference
  strategy; the generator and all tests reference it, never a literal path.
- Before #9002 lands, execution proceeds by injecting explicit schema/input paths through the CLI
  (see section 6) and stubbing/monkeypatching this seam in tests — the generator does not require
  the schema tree to exist to run against caller-supplied input files. The seam's default-location
  branch raises a clear `FileNotFoundError` naming the expected convention until #9002 provides it.
- When #9002 lands, the seam's implementation resolves paths via the governed-glob machinery and
  the schemas' `$schema` self-reference; downstream code is unchanged.

## 6. CLI Conventions and Recommended Script Name (research question 5)

Recommended module: `scripts/dev_tools/generate_acceptance_scenarios.py`.
Recommended `pyproject.toml` `[tool.poetry.scripts]` line (matching the existing `dev.` form at
lines 60/69):

```
"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
```

This aligns with the `dev.discovery.*` namespace required by objective-source.md scope item 9 and
the issue, and with the quoted-dotted-key `dev.<name> = "scripts.dev_tools.<module>:main"` form
already used for `dev.validate-json` and `dev.format-json`.

Module structure to follow exactly (verified against validate_json.py and format_json.py):

- `from __future__ import annotations`; `TYPE_CHECKING`-guarded `Sequence`/`Iterable` imports.
- `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace` with:
  - input path arguments for the three artifacts (feature contract, parity matrix, runtime
    characterization scenario), or a single input-directory argument;
  - `--output` path for the generated scenario document (stdout when omitted);
  - `--check` (optional) to assert the output on disk matches regenerated output without writing,
    mirroring `format_json`'s `--check` semantics (format_json.py:112-116, 153-154).
- `def main(argv: Sequence[str] | None = None) -> int` calling `parse_args(argv or sys.argv[1:])`,
  resolving root via `Path(__file__).resolve().parents[2]`, invoking the pure generation function,
  printing status, and returning `0`/`1`.
- Pure generation logic (schema read + transform + canonical serialize) in standalone functions
  separate from argparse/I/O, per general-code-change "Separation of concerns"; `main` is the thin
  I/O wrapper. This keeps the transform testable without the filesystem.
- Exit codes: `0` success; `1` on any failure (missing/malformed input, `--check` mismatch).
  No other codes, matching both reference modules.
- `if __name__ == "__main__": sys.exit(main())`.

The canonical `validate_<artifact>_text(text) -> list[str]` validator pattern
(`validate_orchestration_artifacts.py` exists as the reference; epic.md "Validator pattern") is a
sibling concern owned by #9003; this feature is a generator, not a validator, so it follows the
generator/CLI pattern of `format_json`/`validate_json`, not the validator subparser pattern.

## 7. Testing Approach (research question 6)

Per `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`
(feature complexity band C3; coverage is uniform across tiers: line >= 85%, branch >= 75%).

Test file location (mirrored tree, per general-unit-test.md "Test File Location"):
`tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`.

Test categories:

- Unit / positive: generation from conforming Feature Contract + Parity Matrix + Runtime
  Characterization inputs produces the expected scenario document; assert the structured
  `given`/`when`/`then` mapping and the derived stable `id`.
- Determinism: generate twice from identical in-memory inputs and assert byte-identical output;
  and assert output is invariant to input ordering (shuffle scenario input order, assert identical
  output) — this exercises the sort-key discipline from section 3.
- Negative / malformed input: missing input file, non-object JSON root, JSON parse error, and a
  document missing a required field. Assert exit code `1` and a clear message. Reuse the negative
  patterns in `test_validate_json.py` (invalid JSON, non-dict root, missing field).
- Schema-location seam: assert `resolve_discovery_schema` raises a clear `FileNotFoundError`
  naming the expected convention when the schema tree is absent (pre-#9002), and that the generator
  runs against explicitly supplied input paths without the schema tree present. Monkeypatch the seam
  to verify downstream code calls it rather than hard-coded paths.
- CLI: `parse_args` defaults and flags (`--output`, `--check`), and `main([...])` return codes for
  success, failure, and `--check` mismatch, following the `test_main_*` structure in
  `test_validate_json.py` (lines 232-438).

Constraints:

- No temporary files: use the `mem_fs_path` fixture (`tests/conftest.py:146`) for any read/write;
  `tmp_path` and real temp files are prohibited by policy and by that fixture's purpose.
- Arrange-Act-Assert structure with descriptive names/docstrings, per general-unit-test.md.
- Coverage is measured over `scripts/dev_tools` (`pyproject.toml:103` `[tool.coverage.run]`
  `source = ["src", "scripts/dev_tools"]`). Keep `main`'s untestable lines minimal
  (`if __name__ == "__main__"` is excluded via `[tool.coverage.report]` exclude_lines,
  pyproject.toml:118); all logic lives in tested pure functions to meet >= 85% line / >= 75% branch.
- File-size limit 500 lines applies to the module and the test file (general-code-change.md).

## Requirements Mapping (acceptance criteria -> design)

- "Python module under scripts/dev_tools generates scenarios from the three inputs" ->
  `scripts/dev_tools/generate_acceptance_scenarios.py` with pure transform functions (section 6).
- "Generation is deterministic" -> canonical `json.dumps(sort_keys=True, indent=2)` + sorted
  scenario array + sorted input paths; no clock/RNG (section 3).
- "Output format defined in spec.md and domain-neutral" -> JSON scenario-document schema
  (section 2), generic field names.
- "dev.discovery.* console-script with main(argv=None) -> int and its own argparse parser" ->
  `"dev.discovery.generate-acceptance-scenarios"` line + module structure (section 6).
- "Schema-location seam isolated behind one function" -> `resolve_discovery_schema(...)` (section 5).
- "No domain-specific identifiers" -> generic schema keys and field names; verified by review and
  by the domain-neutrality invariant (epic.md "Shared Design").
- "Tests satisfy quality-tier policy" -> section 7.

## Automation Feasibility

This feature is fully automatable via a Python CLI and unit tests. It touches no third-party UI
(no Azure portal, Entra, Outlook, or M365 admin center) and no external service. All inputs are
local JSON artifacts and all outputs are local files or stdout. There is no human-interaction
requirement: generation, determinism verification, negative-path handling, and CLI behavior are
all exercisable by pytest with the in-memory `mem_fs_path` fixture. The only external dependency
(schema location from #9002) is isolated behind the `resolve_discovery_schema` seam, which is
stubbable in tests, so this feature can be implemented and fully tested before #9002 lands.

## Evidence Location Invariant

Any evidence artifacts produced during implementation (baselines, QA gates, regression results,
coverage) must be written under
`docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Non-canonical paths
(`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`) are prohibited.
