# Research: legacy-discovery-analyzer-framework (Issue #363, epic child #9006)

- Date captured: 2026-07-17
- Author: task-researcher (delegated)
- Feature: legacy-discovery-analyzer-framework (Wave 1, complexity C3)
- Epic: legacy-discovery-and-parity
- Depends on: legacy-discovery-config-contract (#360), legacy-discovery-schemas (#359)
- Scope boundary: domain-neutral framework + language-neutral repository/project
  inventory analyzer only. Excludes .NET/C# and VSTO/Office analyzers (sibling #9014).

This document records verified findings from the worktree and design recommendations
for the spec and atomic plan. Every recommendation cites the specific file(s) read.

---

## 0. Substrate confirmation (verified)

Confirmed by direct inspection, not assumption:

- **No AST/parser dependency exists.** `pyproject.toml` `[tool.poetry.dependencies]`
  (lines 16-34) lists `typer`, `PyYAML`, `numpy`, `click`, `pandas`, `scikit-learn`,
  `scipy`, `requests`, `beautifulsoup4`, `lxml`, `pyarrow`, `pdfplumber` and optional
  ML extras only. Grep for `roslyn|tree-sitter|tree_sitter|libcst|ast` against
  `pyproject.toml` returned no matches.
- **No Roslyn/tree-sitter anywhere as a dependency.** Repo-wide grep for
  `tree-sitter|tree_sitter|roslyn|Microsoft.CodeAnalysis` matched only documentation
  and mirrored customization files (`.claude/rules/csharp.md`, `README.md`, epic docs,
  `resources/**` mirrors), never a manifest or import.
- **No C# source in this repository.** Glob for `**/*.csproj` returned no files. This
  is consistent with the epic invariant that analyzers read a *consumer* repo's source
  at an external path (epic.md lines 99-100; objective-source.md lines 129-136).
- **No `import yaml` in `scripts/`.** Grep for `import yaml|from yaml|yaml.safe_load`
  under `scripts/` returned no matches. `PyYAML` is declared-but-unused today; its use
  is the config-contract feature's (#360) pending decision, not this feature's.
- **The `scripts/dev_tools/discovery/` package does not yet exist.** Glob returned no
  files. It is delivered by config-contract (#360) and merged before this feature runs.
- **`schemas/` does not yet exist.** Glob returned no files. Delivered by schemas (#359).
- **Coverage measures `scripts/dev_tools`.** `pyproject.toml` lines 102-110:
  `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, `omit` lists only
  `tests/*`, `*/tests/*`, `__pycache__`, `site-packages`. New analyzer production
  modules under `scripts/dev_tools/discovery/analyzer/` are therefore in the coverage
  denominator with no exclusion available (see `.claude/rules/general-unit-test.md`
  "Coverage Exclusion Policy").

---

## Q1. Parsing strategy: regex/plain-text vs AST/Roslyn/tree-sitter

**Recommendation: regex / plain-text (stdlib `pathlib`, `fnmatch`, `re`, `json`). No
new dependency. No AST/Roslyn/tree-sitter.**

Justification tied to evidence:

1. **Repo precedent is uniformly regex/plain-text over Markdown/text.** The single
   analyzer-shaped precedent, `scripts/dev_tools/codex_native_converter/`, classifies
   entirely by path shape and regex over file text. `classifier.py` uses
   `re.compile(...)` patterns (lines 44-57) and substring/path checks
   (`path_text.startswith(...)`, `path_text.endswith(...)`) — never a language parser.
   The TypeScript precedent `extensions/drm-copilot/src/lib/subagent-tree/transcript-parser.ts`
   parses line-by-line with `JSON.parse` inside a try/catch and skips non-conforming
   lines (lines 38-58), again no grammar.
2. **Domain-neutrality forbids embedded grammars.** The epic invariant (epic.md
   lines 104-106; objective-source.md lines 29-31, 129-136) is that the framework
   contains no stack-specific behavior. A C#/Roslyn or tree-sitter grammar would embed
   a specific language into the core framework, violating neutrality. Language-specific
   deep parsing is explicitly the concern of sibling #9014, not this feature.
3. **Simplicity-first design principle.** `.claude/rules/general-code-change.md`
   ("Design Principles": Simplicity first) and `.claude/rules/python.md` ("Adding new
   dependencies without explicit user instruction" is a Prohibited Behavior) both push
   toward stdlib. Objective-source.md line 99 and the issue (issue.md lines 41-43, 75-76)
   pre-state regex/plain-text as the expected choice and mark a heavy AST dependency as
   requiring explicit approval.
4. **The inventory analyzer needs no parsing at all beyond filename/extension
   recognition.** Repository/project enumeration and file inventory are directory-walk +
   filename-pattern-match operations. `fnmatch`/`pathlib.PurePosixPath.match` and simple
   extension checks are sufficient; deep content parsing is out of scope for the
   inventory analyzer.

Record this in `spec.md` as the explicit parsing-strategy decision (AC in issue.md
line 62). The framework should expose a `parse` stage as an *abstraction* so that #9014
can plug in richer text scanning later, but the framework itself ships only
plain-text/regex capability and the inventory analyzer's `parse` stage is a filesystem
walk, not a content parse.

---

## Q2. Schema mapping: which discovery v1 schema does inventory output conform to?

**Recommendation: emit the inventory as a collection of Evidence Reference instances —
one conforming `evidence-reference.schema.json` instance per inventoried unit — rather
than as a single bespoke artifact or as a `metadata` extension of some other artifact.**

Reasoning against the seven artifacts (Dependency B authoritative facts):

- Of the seven artifacts (feature-contract, coverage-ledger,
  runtime-characterization-scenario, parity-matrix, unspecified-behavior-record,
  product-decision-record, evidence-reference), six are *analytical* artifacts that
  encode human/agent reasoning about behavior, coverage, or decisions. A raw
  file/project inventory is not a reasoning product; it is observed evidence about the
  consumer repository's source tree.
- **Evidence Reference is defined as the shared leaf** all other artifacts point at
  (Dependency B). Its required fields map cleanly onto an inventoried unit:
  - `id` — a stable, `^[a-z0-9][a-z0-9._-]*$`-matching identifier for the unit.
  - `kind` — from the enum `file | log | trace | test_run | screenshot | recording |
    document | dataset | url | other`. Use `kind: "file"` for an enumerated source
    file, `kind: "dataset"` for a directory/project rollup if a single record must
    represent an aggregate, and `kind: "document"` only where semantically a document.
    A solution/project marker file is still a `file`.
  - `location` — the path in the *consumer repo's own terms* (Dependency B says
    `location` is a path/URI in the consumer repo's terms). Use the consumer-relative
    POSIX path (relative to `profile.legacy_source.root`), not the analyzer host's
    absolute path.
  - `captured_at` — ISO-8601 timestamp of the analyzer run (inject a clock; see Q6).
  - `description` — a domain-neutral human string, e.g. "Source file enumerated by
    repository inventory analyzer" — must contain no stack-specific identifiers.
  - Optional `content_hash` `{algorithm, value}` — recommended for files (e.g.
    `{"algorithm": "sha256", "value": "..."}`) to make inventory diffable; compute with
    stdlib `hashlib`. Optional `tool` — set to the analyzer's console-script name.
    Optional `metadata` — free-form object; use it to carry inventory-specific fields
    that are not first-class Evidence Reference fields (for example
    `{"unit_type": "project" | "solution" | "file", "size_bytes": N,
    "marker": "<matched-marker-pattern>"}`).

**Concrete emission shape per record (recommended):**

```json
{
  "$schema": "../../../schemas/discovery/v1/evidence-reference.schema.json",
  "schema_version": "1.0.0",
  "id": "inventory-file-<stable-slug-or-hash>",
  "kind": "file",
  "location": "src/relative/path/in/consumer/repo.ext",
  "captured_at": "2026-07-17T14:34:00Z",
  "description": "Source file enumerated by the repository inventory analyzer.",
  "content_hash": { "algorithm": "sha256", "value": "<hex>" },
  "tool": "dev.discovery.inventory",
  "metadata": { "unit_type": "file" }
}
```

Field-setting rules (cited to Dependency B and `validate_json.py`):

- `schema_version` — a string matching `^1\.\d+\.\d+$`; use `"1.0.0"` for v1.
- `$schema` — a **scheme-less RELATIVE path from the instance file to the schema file**;
  absolute Windows paths are prohibited (Dependency B). This is exactly what
  `scripts/dev_tools/validate_json.py::_load_schema` resolves: when
  `urlparse(uri).scheme` is empty it does `(base_path.parent / uri).resolve()`
  (lines 133-143). The relative depth (`../../../`) must be computed from the emitted
  instance's directory to the `schemas/discovery/v1/` directory; the analyzer must
  therefore know, or be told, its own output directory relative to the schema root. Make
  the output root and the schema root both derivable from the domain profile
  (`profile.artifacts.root` for output; schema root is repo-relative under `schemas/`),
  and compute the relative path with `os.path.relpath` / `PurePosixPath`.
- Every schema is `type: object`, `additionalProperties: false` at top level, with a
  single optional free-form `metadata` object (Dependency B). The emitter MUST NOT add
  any field outside the schema's declared set except inside `metadata`.

**Single-artifact vs collection — explicit flag:** the inventory is best expressed as a
**collection of Evidence Reference instances** (one file per unit, or a directory of
instances), not a single artifact. Rationale: Evidence Reference is a per-unit leaf;
`additionalProperties: false` at the top level plus a single `metadata` object means
there is no schema-sanctioned "array of units" container among the seven artifacts. A
future aggregate (e.g., a coverage-ledger that references these evidence ids by plain
string id — Dependency B says cross-references are plain string identifiers, never
`$ref`) can point at the collection. If the spec later wants one file on disk, emit a
directory of one-instance-per-unit files under `profile.artifacts.root`, named by the
`conventions_map` from `ArtifactsConfig`. Confirm the exact on-disk naming against the
`artifacts.conventions` mapping delivered by #360.

**Open item for spec:** confirm with the schemas feature (#359) whether an aggregate
"inventory" artifact is one of the intended uses of a `metadata`-carrying artifact, or
whether emitting N evidence-reference instances is the intended pattern. The evidence
above supports the N-instances pattern; flag this as the one cross-feature confirmation
needed before emission shape is frozen.

---

## Q3. Framework abstraction shape (parse -> classify -> map -> emit)

**Recommendation: a `typing.Protocol`-based stage contract plus frozen dataclass value
objects that flow between stages, driven by a thin pipeline runner function. Use
`Protocol` (not `abc.ABC`) for the analyzer/stage seam.**

Justification:

- `.claude/rules/python.md` line 63: "Prefer `typing.Protocol` (or `abc.ABC`) only when
  multiple implementations are expected." Here multiple implementations ARE expected:
  the framework (#9006), the inventory analyzer (this feature), and the .NET/VSTO
  analyzers (#9014) all plug into the same contract. An abstraction is warranted.
- The existing I/O-boundary seam in the repo uses `Protocol` + a `Real*` dataclass
  implementation: `scripts/dev_tools/new_active_feature_folder_models.py` defines
  `class FileSystem(Protocol)` (line 46) with method stubs and
  `@dataclass class RealFileSystem(FileSystem)` (lines 66-105). This is the established
  pattern to mirror for the filesystem seam.
- The converter precedent composes stages as *free functions* returning frozen
  dataclasses, not as methods on a base class: `engine.py` calls
  `discover_source_artifacts(...)` -> `classify_source_artifact(...)` ->
  `plan_target_paths(...)` -> render/validate/write (lines 120-141, 353-417). Each stage
  is pure or clearly side-effect-scoped, and value objects are `@dataclass(frozen=True,
  slots=True)` (`models.py` lines 153-437). The pipeline is orchestrated by a private
  `_run_conversion` function (engine.py lines 326-440), not a class hierarchy.

**Recommended stage contract.** Model the analyzer as a Protocol with four stage
methods, each consuming and producing typed value objects, so a concrete analyzer plugs
in by implementing the Protocol and the runner drives it uniformly:

```python
class Analyzer(Protocol):
    name: str                       # e.g. "inventory"; used for CLI/tool label
    def parse(self, ctx: AnalyzerContext) -> ParseResult: ...
    def classify(self, parsed: ParseResult) -> ClassifyResult: ...
    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]: ...
    def emit(self, records: tuple[EvidenceRecord, ...],
             fs: AnalyzerFileSystem) -> tuple[Path, ...]: ...
```

Data objects that flow between stages (all `@dataclass(frozen=True, slots=True)`):

- `AnalyzerContext` — resolved run inputs: the consumer `source_root: Path` (from
  `profile.legacy_source.root`), `include: tuple[str, ...]`, `exclude: tuple[str, ...]`,
  the output `artifact_root: Path` (from `profile.artifacts.root`), the schema-relative
  base needed for `$schema`, and a `captured_at` clock value.
- `ParseResult` — the raw enumeration: for the inventory analyzer, the ordered tuple of
  consumer-relative file paths (POSIX text). "Parse" here is a filesystem walk, per Q1.
- `ClassifyResult` — enumerated units tagged with a neutral `unit_type`
  (`file | project | solution`) via filename/extension marker recognition (Q4). Model
  `unit_type` as a `str Enum` mirroring `SourceKind`/`SourceEcosystem` in `models.py`
  (lines 64-123), which are `class X(str, Enum)`.
- `EvidenceRecord` — a typed value object with a `to_json_dict()` method (mirror
  `MappingRecord.to_json_dict` / `ValidationFinding.to_json_dict`, models.py lines
  221-250, 328-356) that serializes to the exact Evidence Reference field set from Q2.

A thin runner function drives the pipeline deterministically (mirror engine.py's
`_run_conversion`):

```python
def run_analyzer(analyzer: Analyzer, ctx: AnalyzerContext,
                 fs: AnalyzerFileSystem) -> AnalyzerRunResult:
    parsed = analyzer.parse(ctx)
    classified = analyzer.classify(parsed)
    records = analyzer.map(classified)
    written = analyzer.emit(records, fs)
    return AnalyzerRunResult(records=records, written_paths=written)
```

**How a concrete analyzer registers/plugs in:** the CLI constructs the concrete
`InventoryAnalyzer()` (a class implementing `Analyzer`) and hands it to `run_analyzer`.
No global registry is needed for a single analyzer; #9014 adds its analyzers the same
way (construct + pass to the runner), and if a registry becomes necessary later it is a
small dict keyed by `analyzer.name`. Do not build a service-locator/plugin-discovery
framework (`.claude/rules/python.md` "Dependency seams": do not introduce generic
service-locator patterns).

**Recommended module split (each < 500 lines per general-code-change.md "File Size
Limit"), under `scripts/dev_tools/discovery/analyzer/`:**

| Module | Responsibility |
|---|---|
| `analyzer/__init__.py` | Re-export `main` and the public `Analyzer` protocol surface (mirror converter `__init__.py`). |
| `analyzer/models.py` | Frozen dataclasses + enums: `AnalyzerContext`, `ParseResult`, `ClassifyResult`, `EvidenceRecord`, `AnalyzerRunResult`, `UnitType(str, Enum)`. Type-only import guards under `TYPE_CHECKING`. |
| `analyzer/pipeline.py` | The `Analyzer` Protocol, `AnalyzerFileSystem` Protocol + `RealAnalyzerFileSystem`, and the `run_analyzer` runner. Pure orchestration. |
| `analyzer/inventory.py` | `InventoryAnalyzer` implementing the four stages; pure enumeration/classification helpers (Q4). |
| `analyzer/emitter.py` | Build the Evidence Reference JSON dict from an `EvidenceRecord` (Q2), compute the relative `$schema` path, serialize deterministically (`json.dumps(..., sort_keys=True, indent=2)`), and write via the filesystem Protocol. |
| `analyzer/cli.py` | `argparse` surface + `main() -> int` (Q5). |
| `analyzer/__main__.py` | Delegate `python -m ...` to `cli.main` (mirror converter `__main__.py`). |

Keep pure logic (walking, classification, dict-building) in `inventory.py`/`emitter.py`
free functions and the runner in `pipeline.py`; keep all disk access behind
`AnalyzerFileSystem`. This satisfies general-code-change.md "I/O Boundaries" and
"Separation of concerns."

---

## Q4. Consumer-repo walking, language-neutral enumeration, and fail-fast

**Recommendation:** resolve the consumer root from the profile, walk it with a pure
enumeration function that takes an injected filesystem seam, filter with `fnmatch`
against `include`/`exclude`, and recognize solutions/projects by a neutral,
profile-informed set of filename/extension markers — never a hardcoded stack.

Details, cited:

1. **Root resolution.** `profile.legacy_source.root` is absolute, or relative to the
   profile file's directory (Dependency A). Resolve it the way the converter's inventory
   resolves roots: `source_root.resolve()` then build candidates beneath it
   (`inventory.py` lines 77-89, 148-166). The config loader validates shape only and does
   NOT check that `root` exists (Dependency A) — existence is this analyzer's concern.
2. **Fail-fast on missing/unreachable root.** Before walking, check the resolved root
   `exists()` and `is_dir()`. If not, raise a specific error. Mirror the converter CLI's
   guard which raises when the source root is not an existing directory
   (`codex_native_converter/cli.py` lines 127-129). Define a dedicated exception (e.g.
   `AnalyzerError(ValueError)`, paralleling `DomainProfileError(ValueError)` from #360)
   so the CLI can map it to exit code 1 (Q5). The error message must be domain-neutral
   and specific: name the unreachable path, not a stack.
3. **Include/exclude glob handling.** `profile.legacy_source.include` /`.exclude` are
   tuples of glob patterns (Dependency A). Apply them with stdlib `fnmatch.fnmatch` (or
   `PurePosixPath.match`) against the consumer-relative POSIX path of each enumerated
   file. Precedent for glob include/exclude with parent-based exclusion is
   `scripts/dev_tools/json_config.py::iter_governed_files` (lines 32-51): it globs
   includes, builds an excluded set, and skips any path whose parent is excluded.
   Mirror this: a file is inventoried when it matches at least one `include` pattern
   (or include is empty -> all) AND matches no `exclude` pattern. Evaluate on POSIX text
   so behavior is OS-independent (converter sorts by `path.as_posix()` throughout,
   inventory.py lines 120, 166, 217).
4. **Language-neutral solution/project recognition.** Recognize project/solution units
   by filename/extension *patterns* only, treated as data, not by embedding a specific
   stack. Two neutral sources for the marker set, in priority order:
   - Prefer markers derivable from the profile so neutrality is preserved: the domain
     profile carries `technology_stack.legacy` (Dependency A) and
     `artifacts.conventions`; the spec can define that project/solution marker patterns
     are supplied as configuration rather than hardcoded. This keeps the framework free
     of `.csproj`/`.sln` literals.
   - Where a default is unavoidable, express it as a neutral, extensible pattern table
     (e.g., a mapping of `unit_type -> tuple[glob, ...]`) with generic entries; do NOT
     name TaskMaster/TMW/Outlook/VSTO. Any concrete `.csproj`/`.sln` handling belongs to
     #9014, which plugs in through the `Analyzer` Protocol. This feature's inventory
     classifies a file as a `project`/`solution` unit when its name matches a
     profile-supplied marker glob, else `file`.
5. **I/O-boundary separation and temp-file-free testability.** Put the walk behind an
   `AnalyzerFileSystem` Protocol (mirror `FileSystem` Protocol in
   `new_active_feature_folder_models.py` line 46). Keep the classification/filter logic
   pure (takes a list of relative paths + include/exclude + marker table, returns
   classified units) so it is unit-testable with no filesystem at all. For end-to-end
   walking tests, use the `mem_fs_path` fixture in `tests/conftest.py` (lines 145-660),
   which monkeypatches `Path.mkdir/write_text/read_text/exists/is_file/is_dir/iterdir/
   glob/rglob/resolve` etc. to operate purely in memory under a `/__pytest_mem__/<n>`
   root. This satisfies general-unit-test.md "Creation and use of temporary files in
   tests is strictly prohibited." Note the fixture supports `rglob`/`glob` with `**`
   zero-depth handling (`_pattern_matches`, conftest.py lines 526-585), so a
   `Path.rglob`-based walk (as in converter `inventory.py` line 162) works under it.

---

## Q5. CLI wiring (`dev.discovery.*`)

**Recommendation:** one console script `dev.discovery.inventory` mapping to a module in
an `analyzer/` subpackage, using `argparse` with a `main() -> int` returning
standardized exit codes.

Cited details:

1. **Script name and mapping.** `pyproject.toml` `[tool.poetry.scripts]` (lines 47-69)
   uses the `dev.<area>` convention with dotted keys quoted, e.g.
   `"dev.validate-json" = "scripts.dev_tools.validate_json:main"`. Add:
   ```toml
   "dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
   ```
   The config-contract feature (#360) reserves `dev.discovery.profile` mapping into the
   shared `scripts/dev_tools/discovery/` package. To avoid module collision in that
   shared package, place this feature's modules in an **`analyzer/` subpackage**
   (`scripts/dev_tools/discovery/analyzer/`). The two features then share only the
   package root `scripts/dev_tools/discovery/__init__.py`; coordinate that
   `__init__.py`'s content at integration time (it is delivered by #360). This matches
   the multi-module subpackage layout of `codex_native_converter/`.
2. **argparse surface.** The repo's argparse precedent is `validate_json.py`
   (`parse_args` lines 228-241; `main(argv) -> int` lines 257-274) and
   `new_active_feature_folder_flow.py` (`parse_args` line 299, `main` line 354). Note the
   converter uses Typer, but the broader `dev.*` dev-tools convention and the
   `validate_<artifact>_text` validator family use `argparse`; the epic's "Validators"
   pattern (objective-source.md lines 80-83) is argparse-subparser. Recommend argparse
   for consistency with the discovery family. Proposed arguments:
   - positional `profile` (path), defaulting to
     `DEFAULT_PROFILE_FILENAME = "discovery-profile.yaml"` (Dependency A).
   - `--output` / `--output-dir` (path) — override `profile.artifacts.root`.
   - `--json` — emit a machine-readable run summary to stdout (list of written paths /
     record count), paralleling the converter's stdout summary (`cli.py` lines 153-186).
3. **Exit-code contract.** `0` success; `1` domain/analyzer error (malformed profile ->
   `DomainProfileError`, unreachable `legacy_source.root` -> `AnalyzerError`); `2`
   argparse usage error. argparse already exits `2` on usage errors by default. For `1`,
   follow `new_active_feature_folder_flow.py::main` which catches specific exceptions and
   `raise SystemExit(1)` (lines 368-373); or, mirroring `validate_json.py`, have
   `main() -> int` return `1` and let `__main__` do `sys.exit(main())`
   (validate_json.py lines 257-278). Recommend `main() -> int` returning `0`/`1`,
   catching `DomainProfileError` and `AnalyzerError` at the CLI boundary
   (general-code-change.md "Error Handling": broad handlers only at entrypoints with
   context), and letting argparse own `2`.
4. **`__main__.py`** delegates to `cli.main` under `SystemExit`, mirroring
   `codex_native_converter/__main__.py` (lines 20-23).

---

## Q6. Testing approach and coverage feasibility

Test tree mirrors production under
`tests/scripts/dev_tools/discovery/analyzer/` (general-unit-test.md "Test File
Location"; python.md "Organize tests to mirror code structure"). No temporary files;
use `mem_fs_path` only.

Scenario matrix (maps to issue.md "Test Conditions" and AC):

1. **Pipeline stage sequencing** — `run_analyzer` calls parse -> classify -> map ->
   emit in order and threads each stage's output to the next. Use a fake `Analyzer`
   implementing the Protocol that records call order (pure, no I/O).
2. **Inventory enumeration over an in-memory fixture tree** — build a small tree with
   `mem_fs_path` (write files via patched `Path.write_text`), assert the enumerated set
   and ordering (deterministic POSIX sort).
3. **Include/exclude glob handling** — parametrized (`pytest.mark.parametrize`, python.md
   "Pytest Rules") over include-only, exclude-only, both, and empty-include (=all)
   cases; assert filtered results. Pure function test, no filesystem needed for the
   filter itself.
4. **Solution/project marker classification** — parametrized over marker-matching and
   non-matching filenames; assert `unit_type`. Pure.
5. **Schema-conforming emission** — build `EvidenceRecord`s, run the emitter, assert the
   produced dict has exactly the Evidence Reference field set (required + optional only),
   `schema_version` matches `^1\.\d+\.\d+$`, `$schema` is a scheme-less relative path
   (no drive letter, no leading `/`), `id` matches `^[a-z0-9][a-z0-9._-]*$`,
   `additionalProperties`-cleanliness (no unexpected top-level keys). Determinism:
   `captured_at` supplied by an injected clock (python.md "Dependency seams": accept an
   optional callable default for time; general-unit-test.md "Controllable clock"). Do
   NOT read wall-clock time in production code under test.
6. **Unreachable / missing `legacy_source.root`** — point the context at a non-existent
   in-memory path, assert `AnalyzerError` with a message naming the path; assert it is
   distinct from a malformed-profile `DomainProfileError`.
7. **CLI exit codes** — invoke `main(["--help"])`/bad args -> `2`; valid run over an
   in-memory tree -> `0` and expected written paths; malformed profile / unreachable
   root -> `1`. Patch the profile loader at its import location in the CLI module
   (python.md "Patch at the import location used by the unit under test").

**Coverage feasibility:** all four stages, the runner, the emitter, and the CLI are
exercised by the matrix above. Because logic is split into pure functions (filter,
classify, dict-build) plus a thin filesystem seam, line >= 85% and branch >= 75%
(quality-tiers.md uniform thresholds) are achievable without temp files. `scripts/dev_tools`
is measured (pyproject.toml line 103) and no `exclude`/`omit` for production analyzer
modules is permitted (general-unit-test.md "Coverage Exclusion Policy"), so the CLI and
`__main__` wiring must stay minimal. `pyproject.toml` `[tool.coverage.report]
exclude_lines` (lines 112-122) already excludes `if __name__ == .__main__.:`,
`if TYPE_CHECKING:`, and `@abstractmethod`, so Protocol stubs and the `__main__` guard
do not count against coverage; keep the `Analyzer` Protocol method bodies as `...` so
they fall under the type-only allowance (python.md line 91).

---

## Q7. Dependency and risk notes

- **No new runtime dependency required.** Recommendation Q1-Q6 uses only stdlib:
  `pathlib`, `fnmatch`, `re`, `json`, `hashlib`, `argparse`, plus `dataclasses`,
  `enum`, `typing`. This satisfies python.md "Prohibited Behaviors: Adding new
  dependencies without explicit user instruction" and general-code-change.md
  "Dependencies." `jsonschema` (dev dependency, pyproject.toml line 43) and
  `validate_json.py` are already present for *tests* to validate emitted instances
  against the discovery schema; no production dependency on `jsonschema` is needed
  because `validate_file` degrades to a minimal built-in validator when `jsonschema` is
  absent (`validate_json.py` lines 19-23, 204-211).
- **Sequencing consideration (not a planning blocker).** The config-contract loader
  (`scripts.dev_tools.discovery.domain_profile`, Dependency A) and the schema files
  under `schemas/discovery/v1/` (Dependency B) do not exist in this worktree yet
  (verified: both globs empty). Implementation-time imports of `domain_profile` and any
  reference to `schemas/discovery/v1/*.schema.json` will only resolve after the
  integration merge brings #360 and #359 in. This is a sequencing note for the executor
  (design against the documented contracts; the merge precedes execution per issue.md
  lines 71-74 and epic.md `depends_on`), and it does not block research, spec, or
  atomic-plan preparation or preflight.
- **Domain-neutrality risk.** The single highest-risk failure mode is leaking a
  stack-specific literal (`.csproj`, `.sln`, TaskMaster/TMW/Outlook/VSTO/email) into a
  marker table, default, field name, error message, or docstring. Mitigation: source all
  project/solution markers from the profile (Q4) and add a test asserting the production
  modules contain no domain-specific identifiers (issue.md AC line 61; the converter
  suite has analogous neutrality expectations). Feature-review will treat any such
  identifier as Blocking.
- **`$schema` relative-path risk on Windows.** Dependency B prohibits absolute Windows
  paths in `$schema`. The emitter must compute the relative path with POSIX separators
  (`PurePosixPath` / `os.path.relpath(...).replace(os.sep, "/")`) and never emit a drive
  letter. Covered by the emission test (Q6 scenario 5).

---

## Summary of recommendations

| # | Question | Recommendation |
|---|---|---|
| 1 | Parsing strategy | regex/plain-text, stdlib only; no AST/Roslyn/tree-sitter. Inventory `parse` = filesystem walk. |
| 2 | Schema mapping | Collection of `evidence-reference.schema.json` v1 instances, one per unit; `kind=file` (or `dataset`/`document`), `location`=consumer-relative POSIX path, `schema_version="1.0.0"`, `$schema`=scheme-less relative path, inventory extras under `metadata`. Confirm N-instances vs aggregate with #359. |
| 3 | Framework shape | `typing.Protocol` `Analyzer` (parse/classify/map/emit) + frozen dataclass value objects + thin `run_analyzer` runner; modules under `discovery/analyzer/` (models, pipeline, inventory, emitter, cli, __main__), each < 500 lines. |
| 4 | Repo walking | Resolve `legacy_source.root`; fail-fast `AnalyzerError` if missing/unreachable; `fnmatch` include/exclude on POSIX text; neutral profile-supplied project/solution markers; pure logic behind `AnalyzerFileSystem` Protocol; test with `mem_fs_path`. |
| 5 | CLI | `dev.discovery.inventory` -> `scripts.dev_tools.discovery.analyzer.cli:main`; argparse (`profile` positional default `discovery-profile.yaml`, `--output-dir`, `--json`); exit codes 0/1/2; `analyzer/` subpackage avoids collision with #360's reserved `dev.discovery.profile`. |
| 6 | Testing | 7-scenario matrix, injected clock, `mem_fs_path` only, tests mirror production tree; line >= 85%/branch >= 75% feasible; keep CLI/`__main__` minimal (measured, not excludable). |
| 7 | Deps/risks | Stdlib only, no new runtime dep; #360/#359 modules absent until integration merge (sequencing note, not a blocker); guard domain-neutrality and Windows `$schema` relative-path. |

## Files and precedents cited

- `docs/features/epics/legacy-discovery-and-parity/objective-source.md` (scope §8, research questions, ACs)
- `docs/features/epics/legacy-discovery-and-parity/epic.md` (manifest, shared design, DAG)
- `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/issue.md` (problem/behavior/AC)
- `scripts/dev_tools/codex_native_converter/{engine,classifier,mapping,inventory,cli,__main__,__init__,models}.py` (pipeline/stage/CLI precedent)
- `extensions/drm-copilot/src/lib/subagent-tree/{types,transcript-parser,tree-assembler}.ts` (second pure parse->assemble precedent)
- `pyproject.toml` (`[tool.poetry.scripts]`, `[tool.coverage.run]`, dependency list)
- `tests/conftest.py` (`mem_fs_path` in-memory filesystem fixture)
- `scripts/dev_tools/validate_json.py`, `scripts/dev_tools/json_config.py` ($schema relative resolution, governed-glob include/exclude)
- `scripts/dev_tools/new_active_feature_folder_models.py` (`FileSystem` Protocol + `RealFileSystem`), `new_active_feature_folder_flow.py` (argparse `main` + `SystemExit(1)`)
- `.claude/rules/python.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`
