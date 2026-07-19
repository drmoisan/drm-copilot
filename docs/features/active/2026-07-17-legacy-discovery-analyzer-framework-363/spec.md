# legacy-discovery-analyzer-framework — Spec

- **Issue:** #363
- **Parent (optional):** Epic legacy-discovery-and-parity (child feature #9006, Wave 1, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Depends on:** legacy-discovery-config-contract (#360), legacy-discovery-schemas (#359)
- **Integration branch:** epic/legacy-discovery-and-parity-integration

## Overview

The legacy-discovery-and-parity epic requires a reusable, domain-neutral mechanism to read a
consumer repository's source and emit machine-readable discovery artifacts. Without a shared
analyzer framework, every stack-specific analyzer (the .NET/C# and VSTO/Office analyzers in
sibling feature #9014 and later skills in #9008) would re-implement the
parse -> classify -> map -> emit pipeline, artifact emission, and CLI wiring independently,
reintroducing duplication and inconsistent artifact shapes.

This feature delivers two things:

1. A language-neutral analyzer **framework**: a stage-based pipeline abstraction
   (`parse -> classify -> map -> emit`) that concrete analyzers plug into, plus a thin runner.
2. The first concrete analyzer, the **repository/project inventory analyzer**: language-neutral
   solution/project enumeration and file inventory that reads a consumer repository at the path
   declared by the domain profile and emits discovery-schema-conforming Evidence Reference
   artifacts.

The framework establishes the contract that downstream analyzers (#9014) plug into. This
feature does NOT implement the .NET/C# or VSTO/Office analyzers; those are sibling feature
#9014 and plug in through the `Analyzer` protocol defined here.

## Scope

### In scope

- A language-neutral `Analyzer` protocol with four stages (parse, classify, map, emit) and a
  thin `run_analyzer` runner.
- Frozen dataclass value objects that flow between the stages.
- A filesystem seam (`AnalyzerFileSystem` protocol plus a real implementation) so enumeration
  logic is testable without temporary files.
- The repository/project inventory analyzer: consumer-repository enumeration honoring
  `include`/`exclude` globs, neutral project/solution marker classification, and Evidence
  Reference emission.
- Artifact emission conforming to the discovery v1 Evidence Reference schema
  (`schemas/discovery/v1/evidence-reference.schema.json`).
- A `dev.discovery.inventory` Poetry console-script CLI mapping to
  `scripts.dev_tools.discovery.analyzer.cli:main` with exit codes 0/1/2.
- The parsing-strategy Specification Decision (recorded and justified below).
- A domain-neutrality contract test over the framework and inventory production modules.
- Unit and integration tests meeting repository quality-tier policy.

### Out of scope

- The .NET/C# inventory analyzer and the VSTO/Office analyzer (sibling feature #9014). This
  feature must not embed `.csproj`/`.sln` literals, namespace/type enumeration, Ribbon-XML, or
  COM-interop detection.
- The domain-profile configuration contract and its loader (upstream feature #360). This
  feature consumes `scripts/dev_tools/discovery/domain_profile.py`; it does not implement it.
- The discovery JSON schemas (upstream feature #359). This feature emits instances that conform
  to `schemas/discovery/v1/evidence-reference.schema.json`; it does not author the schemas.
- Deep content parsing / AST analysis of consumer source files (see Specification Decision).
- MCP-tool and VS Code exposure of the CLI (feature #9011).
- The `dev.discovery.profile` console script (reserved by feature #360).

## Specification Decision: Parsing Strategy

**Decision: regex / plain-text using the Python standard library only
(`pathlib`, `fnmatch`, `re`, `json`, `hashlib`). No new runtime dependency. No
AST / Roslyn / tree-sitter.**

Justification (grounded in the feature research artifact
`research/2026-07-17-analyzer-framework-research.md`):

1. **No AST or parser dependency exists in the repository.** The `pyproject.toml`
   `[tool.poetry.dependencies]` block lists no `roslyn`, `tree-sitter`, `tree_sitter`,
   `libcst`, or grammar library. Adding one would require explicit approval per
   `.claude/rules/python.md` ("Adding new dependencies without explicit user instruction" is a
   Prohibited Behavior).
2. **Repository precedent is uniformly regex/plain-text.** The analyzer-shaped precedent
   `scripts/dev_tools/codex_native_converter/` classifies entirely by path shape and regex over
   file text, never a language parser.
3. **Domain-neutrality forbids embedded grammars.** A C#/Roslyn or tree-sitter grammar would
   embed a specific language into the core framework, violating the epic-wide domain-neutrality
   invariant. Language-specific deep parsing is explicitly the concern of sibling #9014.
4. **Simplicity-first.** The inventory analyzer needs no parsing beyond filename/extension
   recognition. Repository/project enumeration and file inventory are directory-walk plus
   filename-pattern-match operations; `fnmatch` and simple extension checks are sufficient.

The framework exposes a `parse` stage as an abstraction so that #9014 can plug in richer text
scanning later. The framework itself ships only plain-text/regex capability, and the inventory
analyzer's `parse` stage is a filesystem walk, not a content parse.

## Behavior

### Framework abstraction

The framework defines an `Analyzer` protocol (`typing.Protocol`, not `abc.ABC`, because
multiple implementations are expected: this feature's inventory analyzer plus #9014's
analyzers) with four stage methods and a `name` attribute:

```python
class Analyzer(Protocol):
    name: str
    def parse(self, ctx: AnalyzerContext) -> ParseResult: ...
    def classify(self, parsed: ParseResult) -> ClassifyResult: ...
    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]: ...
    def emit(
        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
    ) -> tuple[Path, ...]: ...
```

A thin runner drives the pipeline deterministically and threads each stage's output into the
next:

```python
def run_analyzer(
    analyzer: Analyzer, ctx: AnalyzerContext, fs: AnalyzerFileSystem
) -> AnalyzerRunResult:
    parsed = analyzer.parse(ctx)
    classified = analyzer.classify(parsed)
    records = analyzer.map(classified)
    written = analyzer.emit(records, fs)
    return AnalyzerRunResult(records=records, written_paths=written)
```

A concrete analyzer plugs in by implementing the protocol; the CLI constructs the concrete
`InventoryAnalyzer()` and hands it to `run_analyzer`. No global registry or service-locator /
plugin-discovery mechanism is introduced (prohibited by `.claude/rules/python.md`). If a
registry becomes necessary later it is a small dict keyed by `analyzer.name`.

### Inventory analyzer

1. Resolve the consumer source root from the domain profile
   (`profile.legacy_source.root`). The loader validates shape only and does not check that the
   root exists; existence is the analyzer's concern.
2. Fail fast: before walking, verify the resolved root `exists()` and `is_dir()`. If not, raise
   `AnalyzerError` with a domain-neutral message naming the unreachable path. This is distinct
   from a malformed-profile `DomainProfileError`.
3. Walk the consumer tree behind the `AnalyzerFileSystem` seam. Compute each file's
   consumer-relative POSIX path (relative to the resolved root).
4. Apply include/exclude filtering with stdlib `fnmatch` against the consumer-relative POSIX
   path: a file is inventoried when it matches at least one `include` pattern (or `include` is
   empty, meaning all) AND matches no `exclude` pattern.
5. Classify each inventoried unit's `unit_type` (`file`, `project`, or `solution`) by matching
   the filename against a neutral, profile-supplied marker pattern set. Where a default marker
   set is unavoidable it is expressed as a generic, extensible pattern table; it never names a
   specific stack (no `.csproj`/`.sln` literals in this feature's production code).
6. Map each classified unit to an `EvidenceRecord` and emit one Evidence Reference v1 instance
   per unit under the resolved output root.

### CLI

`dev.discovery.inventory` runs the inventory analyzer end-to-end from a domain profile to a
collection of schema-conforming artifacts, returning standardized exit codes.

## Contracts

### Framework abstraction contract

- `Analyzer` protocol with `name: str` and the four stage methods above. Stage method bodies in
  the protocol are `...` (type-only, excluded from coverage per `[tool.coverage.report]
  exclude_lines`).
- `run_analyzer(analyzer, ctx, fs) -> AnalyzerRunResult` invokes the stages in the fixed order
  `parse -> classify -> map -> emit` and threads outputs.
- Value objects (all `@dataclass(frozen=True, slots=True)`):
  - `AnalyzerContext` — resolved run inputs: `source_root: Path`,
    `include: tuple[str, ...]`, `exclude: tuple[str, ...]`, `artifact_root: Path`, the
    schema-relative base needed to compute `$schema`, and a `captured_at` value produced by an
    injected clock.
  - `ParseResult` — the ordered tuple of consumer-relative POSIX file paths from the walk.
  - `ClassifyResult` — enumerated units tagged with `unit_type` via a `UnitType(str, Enum)`
    (`file | project | solution`).
  - `EvidenceRecord` — a typed value object with a `to_json_dict()` method serializing to the
    Evidence Reference field set.
  - `AnalyzerRunResult` — `records: tuple[EvidenceRecord, ...]` and
    `written_paths: tuple[Path, ...]`.

### Filesystem seam contract

- `AnalyzerFileSystem` protocol exposes the disk operations the analyzer requires (directory
  walk, existence/type checks, write). A `RealAnalyzerFileSystem` implements it against the
  real filesystem. Pure enumeration/classification logic takes the seam or plain data so it is
  testable via the in-memory `mem_fs_path` fixture with no temporary files.

### Inventory analyzer contract

- `InventoryAnalyzer` implements `Analyzer` with `name = "inventory"`.
- `parse` performs the filesystem walk (via the seam) and returns consumer-relative POSIX
  paths.
- `classify` applies include/exclude filtering (pure) and assigns `unit_type` from the
  profile-supplied marker table (pure).
- `map` builds one `EvidenceRecord` per inventoried unit.
- `emit` writes one Evidence Reference instance per record via the filesystem seam and returns
  the written paths.

### Artifact emission contract (discovery v1 Evidence Reference)

The inventory is emitted as a **collection of Evidence Reference v1 instances**, one conforming
instance per inventoried unit, not as a single bespoke aggregate artifact. Each emitted
instance:

- Sets `schema_version` to a string matching `^1\.\d+\.\d+$`; use `"1.0.0"` for v1.
- Sets `$schema` to a **scheme-less relative path** from the emitted instance file to
  `schemas/discovery/v1/evidence-reference.schema.json`, computed with POSIX separators
  (`PurePosixPath` / `os.path.relpath(...).replace(os.sep, "/")`). It never emits a drive
  letter or a leading `/` (absolute Windows paths are prohibited).
- Sets `id` to a stable identifier matching `^[a-z0-9][a-z0-9._-]*$` (for example
  `inventory-file-<stable-slug-or-hash>`).
- Sets `kind` to a value from the schema enum; `"file"` for an enumerated source file. A
  solution/project marker file is still a `file`.
- Sets `location` to the consumer-relative POSIX path (relative to
  `profile.legacy_source.root`), expressed in the consumer repository's own terms, not the
  analyzer host's absolute path.
- Sets `captured_at` to the ISO-8601 timestamp supplied by the injected clock.
- Sets `description` to a domain-neutral human string (for example, "Source file enumerated by
  the repository inventory analyzer."). It contains no stack-specific identifiers.
- Optionally sets `content_hash` `{algorithm, value}` (recommended for files; computed with
  stdlib `hashlib`, for example `{"algorithm": "sha256", "value": "<hex>"}`) and `tool` (set to
  the console-script name `dev.discovery.inventory`).
- Carries inventory-specific extras only inside the single optional free-form `metadata`
  object (for example `{"unit_type": "file" | "project" | "solution", "size_bytes": N}`). The
  emitter MUST NOT add any field outside the schema's declared set except inside `metadata`.
- Is serialized deterministically (`json.dumps(..., sort_keys=True, indent=2)`).

**Documented cross-feature assumption:** the research artifact flagged one open confirmation to
reconcile with the schemas feature (#359): whether an aggregate "inventory" artifact is an
intended use of a `metadata`-carrying artifact, or whether emitting N Evidence Reference
instances is the intended pattern. The evidence supports the N-instances pattern, which this
spec adopts. If #359 later confirms an aggregate artifact is preferred, the emission shape is
revisited before it is frozen; this is recorded as an assumption, not a resolved decision.

### CLI contract

- Poetry console script: `"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"`.
- The module lives in an `analyzer/` subpackage
  (`scripts/dev_tools/discovery/analyzer/`) to avoid collision with feature #360's reserved
  `dev.discovery.profile` in the shared `scripts/dev_tools/discovery/` package. The two
  features share only the package root `__init__.py` (delivered by #360; coordinated at
  integration).
- `argparse` surface:
  - positional `profile` (path), defaulting to `DEFAULT_PROFILE_FILENAME` from the config
    contract (`"discovery-profile.yaml"`).
  - `--output-dir` (path) — override `profile.artifacts.root`.
  - `--json` — emit a machine-readable run summary to stdout (written paths / record count).
- `main(argv) -> int` returns the exit code; `__main__.py` delegates via `sys.exit(main())`.
- Exit-code contract:
  - `0` — success.
  - `1` — domain/analyzer error: malformed profile (`DomainProfileError`) or unreachable
    `legacy_source.root` (`AnalyzerError`), caught at the CLI boundary.
  - `2` — argparse usage error (argparse default).

## Inputs / Outputs

- **Inputs:**
  - CLI positional `profile` (path to the domain profile; default `discovery-profile.yaml`).
  - CLI flags `--output-dir`, `--json`.
  - The domain profile fields `legacy_source.root`, `legacy_source.include`,
    `legacy_source.exclude`, and `artifacts.root`, read via the config-contract loader
    `scripts/dev_tools/discovery/domain_profile.py`.
  - The consumer repository source tree at `legacy_source.root` (external to this repository).
  - An injected clock (`Callable`) supplying `captured_at`; defaults to a wall-clock provider
    in production, overridden in tests.
- **Outputs:**
  - A collection of Evidence Reference v1 JSON instances (one per inventoried unit) written
    under the resolved output root.
  - An optional stdout run summary when `--json` is passed.
  - Standardized process exit codes 0/1/2.
- **Config keys and defaults:** `profile` positional defaults to `DEFAULT_PROFILE_FILENAME`;
  output root defaults to `profile.artifacts.root` unless overridden by `--output-dir`.
- **Versioning / backward-compatibility constraints:** emitted instances declare
  `schema_version` matching `^1\.\d+\.\d+$` (`"1.0.0"` for v1) and reference the v1 schema via a
  relative `$schema` path.

## Data & State

- **Data flow:** domain profile -> `AnalyzerContext` -> filesystem walk (`ParseResult`) ->
  filter + classify (`ClassifyResult`) -> `EvidenceRecord` tuple -> serialized Evidence
  Reference instances on disk.
- **Data transformations and invariants:** enumeration is deterministic (POSIX-sorted); the
  same tree and profile produce byte-identical output given a fixed clock value. `location` is
  always consumer-relative POSIX text. `$schema` is always a scheme-less relative POSIX path.
- **Caching or persistence details:** none. The analyzer is stateless per run; output is
  written to the resolved output root.
- **Migration or backfill requirements:** none.

## Constraints & Risks

- **Domain-neutrality invariant (epic-wide, highest-risk failure mode).** Framework and
  inventory production modules must contain no TaskMaster / TMW / Outlook / VSTO / email /
  task-management identifiers in code, field names, defaults, error messages, or docstrings.
  Any stack-specific literal (for example `.csproj`, `.sln`) leaking into a marker table,
  default, field name, error message, or docstring is a Blocking finding. Mitigation: source
  all project/solution markers from the profile and add a domain-neutrality contract test.
- **Scope boundary.** This feature is the framework plus the language-neutral inventory only.
  It must not design or include the .NET/C# or VSTO/Office analyzers (#9014).
- **Upstream sequencing (not a planning blocker).** The config-contract loader
  (`scripts/dev_tools/discovery/domain_profile.py`, #360) and the schema files under
  `schemas/discovery/v1/` (#359) do not exist in this worktree yet; both merge into the
  integration branch before this feature executes. Design against their documented contracts;
  treat their presence at execution time as a sequencing assumption.
- **Consumer-repository reality.** The analyzer reads an external consumer repository at the
  profile-declared path; this repository (drm-copilot) contains no C# source of its own.
- **Windows `$schema` relative-path risk.** The emitter must compute the relative path with
  POSIX separators and never emit a drive letter or leading `/`.
- **File-size limit.** No production or test file exceeds 500 lines; the framework is split
  across sub-500-line modules.
- **Coverage measurement.** `scripts/dev_tools` is in the coverage denominator with no
  exclusion available for the new analyzer production modules, so CLI and `__main__` wiring
  must stay minimal.

## Implementation Strategy

- **Implementation scope:** add a new `scripts/dev_tools/discovery/analyzer/` subpackage and a
  mirrored test tree; add one `pyproject.toml` console-script line. Design against, do not
  reimplement, the #360 loader and #359 schemas.
- **New modules to add (each < 500 lines), under `scripts/dev_tools/discovery/analyzer/`:**
  - `__init__.py` — re-export `main` and the public `Analyzer` protocol surface.
  - `models.py` — frozen dataclasses and enums: `AnalyzerContext`, `ParseResult`,
    `ClassifyResult`, `EvidenceRecord`, `AnalyzerRunResult`, `UnitType(str, Enum)`; type-only
    imports guarded under `TYPE_CHECKING`.
  - `pipeline.py` — the `Analyzer` protocol, `AnalyzerFileSystem` protocol plus
    `RealAnalyzerFileSystem`, and the `run_analyzer` runner (pure orchestration).
  - `inventory.py` — `InventoryAnalyzer` implementing the four stages, plus pure
    enumeration/classification helpers; defines `AnalyzerError(ValueError)`.
  - `emitter.py` — build the Evidence Reference JSON dict from an `EvidenceRecord`, compute the
    relative `$schema` path, serialize deterministically, and write via the filesystem seam.
  - `cli.py` — `argparse` surface plus `main(argv) -> int`.
  - `__main__.py` — delegate `python -m ...` to `cli.main` under `SystemExit`.
- **Dependency changes:** none. Standard library only (`pathlib`, `fnmatch`, `re`, `json`,
  `hashlib`, `argparse`, `dataclasses`, `enum`, `typing`). `jsonschema` is a dev dependency used
  only by tests to validate emitted instances against the schema; no production dependency on it
  is added.
- **Logging/telemetry additions:** use the repository's established logging pattern for
  analyzer errors; the `--json` summary is the machine-readable run output. No new telemetry
  system.
- **Rollout plan:** no feature flag. The CLI coexists with feature #360's reserved
  `dev.discovery.profile`; the `analyzer/` subpackage isolates this feature's modules from the
  shared package root.

## Testing Requirements

- Test tree mirrors production at `tests/scripts/dev_tools/discovery/analyzer/`. Colocation in
  the production source tree is prohibited.
- No temporary files. Filesystem behavior is exercised via the in-memory `mem_fs_path` fixture
  in `tests/conftest.py`.
- Determinism: `captured_at` is supplied by an injected clock (`Callable`); production code
  under test never reads wall-clock time directly.
- Coverage: line >= 85% and branch >= 75%, no reduction on changed lines. No production analyzer
  module is excluded from coverage.
- Scenario matrix (maps to the acceptance criteria below):
  1. Pipeline stage sequencing — `run_analyzer` invokes parse -> classify -> map -> emit in
     order and threads outputs, verified with a fake `Analyzer` implementing the protocol.
  2. Inventory enumeration over an in-memory fixture tree — assert the enumerated set and
     deterministic POSIX ordering.
  3. Include/exclude glob handling — parametrized over include-only, exclude-only, both, and
     empty-include (= all) cases (pure function test).
  4. Solution/project marker classification — parametrized over matching and non-matching
     filenames; assert `unit_type` (pure function test).
  5. Schema-conforming emission — assert the produced dict has exactly the Evidence Reference
     field set (required plus optional only), `schema_version` matches `^1\.\d+\.\d+$`,
     `$schema` is a scheme-less relative path (no drive letter, no leading `/`), `id` matches
     `^[a-z0-9][a-z0-9._-]*$`, and no unexpected top-level keys; validate against the v1 schema.
  6. Unreachable / missing `legacy_source.root` — assert `AnalyzerError` naming the path;
     assert it is distinct from a malformed-profile `DomainProfileError`.
  7. CLI exit codes — `--help` / bad args -> `2`; valid run over an in-memory tree -> `0` with
     expected written paths; malformed profile / unreachable root -> `1`. Patch the profile
     loader at its import location in the CLI module.
  8. Domain-neutrality contract test — assert the framework and inventory production modules
     contain no TaskMaster / TMW / Outlook / VSTO / email / task-management identifiers and no
     `.csproj`/`.sln` literals in code, field names, defaults, error messages, or docstrings.
- Feature QA evidence for this feature is written under
  `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/<kind>/` per
  the evidence-and-timestamp-conventions skill.

## Acceptance Criteria

- [x] A language-neutral analyzer base abstraction/pipeline (`parse -> classify -> map -> emit`)
      exists as a `typing.Protocol` `Analyzer` with a thin `run_analyzer` runner, and a concrete
      analyzer implementing the protocol plugs into the runner.
- [x] Frozen dataclass value objects (`AnalyzerContext`, `ParseResult`, `ClassifyResult`,
      `EvidenceRecord`, `AnalyzerRunResult`) flow between the stages, and `run_analyzer` invokes
      the four stages in the fixed order and threads each stage's output to the next.
- [x] The repository/project inventory analyzer enumerates solutions/projects and file inventory
      for a consumer repository located via the domain profile `legacy_source.root`.
- [x] Enumeration honors `include`/`exclude` globs applied with `fnmatch` against
      consumer-relative POSIX paths (match at least one include or empty-include = all, and no
      exclude), with deterministic POSIX ordering.
- [x] Project/solution units are classified by a neutral, profile-supplied marker pattern set
      with no hardcoded stack-specific literals.
- [x] An unreachable or missing `legacy_source.root` fails fast with a domain-neutral
      `AnalyzerError` naming the path, distinct from a malformed-profile `DomainProfileError`.
- [x] Each emitted artifact is an Evidence Reference v1 instance with `schema_version` matching
      `^1\.\d+\.\d+$`, a scheme-less relative `$schema` path (no drive letter, no leading `/`),
      an `id` matching `^[a-z0-9][a-z0-9._-]*$`, and the required fields
      `id`/`kind`/`location`/`captured_at`/`description`, with `location` a consumer-relative
      POSIX path and inventory extras only under `metadata`.
- [x] The `dev.discovery.inventory` console script maps to
      `scripts.dev_tools.discovery.analyzer.cli:main`, runs the inventory analyzer end-to-end,
      and returns exit codes `0` (success), `1` (domain/analyzer error), and `2` (usage error).
- [x] The parsing-strategy decision (regex/plain-text, stdlib only, no AST/Roslyn/tree-sitter)
      is recorded and justified in the Specification Decision section of this spec.
- [x] Framework and inventory production modules contain no domain-specific identifiers,
      verified by a domain-neutrality contract test.
- [x] Tests satisfy repository quality-tier policy: pytest, line coverage >= 85%, branch
      coverage >= 75%, test tree mirrors production at
      `tests/scripts/dev_tools/discovery/analyzer/`, no temporary files (in-memory `mem_fs_path`
      fixture), and `captured_at` supplied by an injected clock.
- [x] No production or test file exceeds 500 lines, and no production analyzer module is
      excluded from coverage measurement.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit and integration as applicable)
- [x] Edge cases and error handling covered by tests (unreachable root, malformed profile,
      empty include, glob exclusion, usage error)
- [x] Docs updated (this spec, user-story, and feature-folder links)
- [x] Domain-neutrality contract test present and passing
- [x] Toolchain pass completed (Black -> Ruff -> Pyright strict -> pytest with coverage) in a
      single clean pass

## Seeded Test Conditions (from potential)

- [x] Unit coverage: pipeline stage sequencing; inventory enumeration over an in-memory fixture
      tree; include/exclude glob handling; marker classification; artifact emission conforms to
      schema; CLI success and error exit codes.
- [x] Integration scenarios: inventory analyzer end-to-end from a domain profile to a
      schema-conforming collection of artifacts.
- [x] CLI/API examples: `dev.discovery.inventory` load-and-emit; non-zero exit on malformed
      profile or unreachable source root; `--json` run summary.
