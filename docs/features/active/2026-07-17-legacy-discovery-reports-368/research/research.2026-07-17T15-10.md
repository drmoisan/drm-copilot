# legacy-discovery-reports (#368) — Preparation Research

- Feature: legacy-discovery-reports (issue #368), child of epic legacy-discovery-and-parity
- Epic sources read: `docs/features/epics/legacy-discovery-and-parity/objective-source.md`
  (section 12 "Reports", line 115), `docs/features/epics/legacy-discovery-and-parity/epic.md`
  ("Shared Design", lines 102-126)
- Researcher: task-researcher (preparation mode)
- Date: 2026-07-17

## 0. Upstream Dependency Status (verified in this worktree)

This preparation runs against the epic integration branch, which contains only the epic
manifest. Verified by search: no `legacy-discovery-schemas` or `legacy-discovery-validators`
code exists anywhere in this worktree.

- `Grep "legacy.discovery"` under `scripts/` → no matches.
- `Glob docs/features/active/**/legacy-discovery*/**` → no matches (only this feature's own
  folder, `2026-07-17-legacy-discovery-reports-368`, exists under `docs/features/active/`).
- `Glob **/schemas/**` → only unrelated `.vscode/schemas/*.schema.json` (VS Code JSON-schema
  files for editor config) and one cached schema under `.cache/schemas/`. No
  `schemas/v1/` or similar versioned-schema directory exists anywhere in the repo, which is
  consistent with the epic's own statement that "the repository has no existing versioning
  layout" (objective-source.md line 71).

**Every claim below about the concrete field-level shape of the Coverage Ledger or Parity
Matrix, the exact validator module names/paths for `legacy-discovery-validators`, and the exact
`schemas/vN/` directory layout is an upstream-dependency assumption**, derived only from the
epic's prose contract (objective-source.md §4 "Machine-Readable Schemas", line 70-78; epic.md
"Schema-versioning convention" and "Validator pattern", lines 107-113) and not from any
merged code. This research designs the report code against that documented contract with an
explicit seam (Section 4) so field mapping can be finalized once #9002/#9003 land.

## 1. CLI Substrate: `dev.discovery.*` Console Scripts

### 1.1 Canonical module pattern (verified)

Root `pyproject.toml` `[tool.poetry.scripts]` (lines 47-69) shows two forms:

- Flat module: `"dev.format-json" = "scripts.dev_tools.format_json:main"` (line 60) and
  `"dev.validate-json" = "scripts.dev_tools.validate_json:main"` (line 69).
- Subpackage with dedicated `cli.py`: `"dev.atomic-executor" = "scripts.dev_tools.atomic_executor.cli:main"`
  (line 56) and `"codex-native-converter" = "scripts.dev_tools.codex_native_converter.cli:main"`
  (line 49).

Every "Dev Tools Alias" entry key is prefixed `dev.` followed by a **hyphenated** command name
(`dev.format-json`, `dev.new-active-feature`, `dev.resolve-execute-plan`, etc.) — hyphens, never
underscores, appear in the script key even though the underlying Python module/package uses
`snake_case` (`format_json.py`, `new_active_feature_folder.py`). This is the naming convention
verified across all 14 aliases at lines 56-69.

Both module shapes expose `def main(argv: Sequence[str] | None = None) -> int` with an
`argparse`-based parser and a `if __name__ == "__main__": sys.exit(main())` guard:
- `scripts/dev_tools/format_json.py` lines 121-159 (`main`), lines 95-118 (`parse_args`).
- `scripts/dev_tools/validate_json.py` lines 257-278 (`main`), lines 228-241 (`parse_args`).
- `scripts/dev_tools/plan_progress_report.py` lines 371-396 (`main`), lines 328-368 (`_parse_args`).
- `scripts/dev_tools/validate_orchestration_artifacts.py` lines 323-356 (`main`) — this module
  uses an **argparse subparser** dispatch (`build_parser`, lines 144-252, with
  `subparsers = parser.add_subparsers(dest="artifact_type", required=True)` at line 168), which
  is the pattern the epic's "Validator pattern" shared-design note explicitly points to
  ("mirroring `validate_orchestration_artifacts.py`", epic.md line 113).

### 1.2 Naming form for `dev.discovery.*`

No existing script key in this repository uses more than one segment after `dev.`
(`Grep "dev\.[a-z-]+\.[a-z-]+"` against `pyproject.toml` → no matches). The `dev.discovery.*`
three-segment form is therefore a namespace the epic itself mandates
(objective-source.md line 101: "Python CLI commands under the `dev.discovery.*` namespace"),
not an existing repo pattern to imitate verbatim — it extends the existing flat
`dev.<hyphenated-name>` convention with one additional fixed namespace segment (`discovery`).

Recommended concrete keys for this feature, consistent with the hyphenated-name convention
observed in every other alias:

```
"dev.discovery.coverage-report" = "scripts.dev_tools.discovery.coverage_report:main"
"dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"
"dev.discovery.completion-report" = "scripts.dev_tools.discovery.completion_report:main"
```

### 1.3 Module location: subpackage vs. single module

Precedent strongly favors a subpackage for a multi-command, multi-module feature:
`scripts/dev_tools/atomic_executor/` contains 18 files (`cli.py`,
`cli_execute_one_task.py`, `cli_preflight.py`, `cli_task_runtime.py`, `cli_workspace.py`,
`feature_resolver.py`, `plan_discovery.py`, `plan_parser.py`, `prompt_builder.py`,
`qc_runner*.py`, etc.) — verified via `Glob scripts/dev_tools/atomic_executor/*.py`. Each
`pyproject.toml` script for that feature (`atomic-executor`, `dev.atomic-executor`) maps to the
single `atomic_executor/cli.py:main`, which imports and dispatches to the decomposed modules
(`scripts/dev_tools/atomic_executor/cli.py` lines 16-60 show imports from
`cli_copilot_runtime`, `cli_execute_one_task`, `cli_preflight`, `cli_task_runtime`,
`cli_workspace`, `feature_resolver`, `plan_discovery`, `plan_parser`, `prompt_builder`).

This feature has three distinct console-script entry points (coverage, parity, completion),
each needing its own `parse_args`/`main`, plus shared rendering-determinism and
validator-invocation logic. A `scripts/dev_tools/discovery/` subpackage (mirrored by
`tests/scripts/dev_tools/discovery/`) is the module-location decision recommended in Section 6,
consistent with this precedent rather than three unrelated flat modules or one large combined
module (which would risk exceeding the 500-line limit, `.claude/rules/general-code-change.md`
"File Size Limit").

## 2. Test Layout (verified)

- Convention: `tests/scripts/dev_tools/test_<module>.py` for flat modules
  (`tests/scripts/dev_tools/test_validate_json.py`, `test_format_json.py`,
  `test_plan_progress_report.py` — verified via `Glob`), and
  `tests/scripts/dev_tools/<subpackage>/test_<module>.py` for subpackages
  (`tests/scripts/dev_tools/atomic_executor/test_cli.py`,
  `test_plan_parser.py`, `test_feature_resolver.py`, etc. — verified via `Grep`). This mirrors
  `.claude/rules/general-unit-test.md` "Test File Location": test tree mirrors production
  source tree, no colocation in `src`/`scripts`.
- `tests/conftest.py` line 39-64 inserts the repo root onto `sys.path` for imports (no package
  install required for tests to resolve `scripts.dev_tools.*`).
- `tests/conftest.py` lines 145-660 define the `mem_fs_path` fixture: an autouse-free, opt-in,
  fully in-memory `pathlib.Path` monkeypatch (not `tmp_path`) that satisfies the repo's
  "no runtime temp files in unit tests" rule (`.claude/rules/general-unit-test.md` "External
  Dependencies"; `.claude/rules/python.md` "Prohibited Behaviors"). `test_validate_json.py`
  uses `mem_fs_path` directly (lines 42-78); `test_format_json.py` and
  `test_plan_progress_report.py` instead hand-roll a `dict[Path, str]` store and
  `monkeypatch.setattr(Path, "read_text", ...)` (format_json test lines 15-40;
  plan_progress_report tests operate on pure functions with no I/O). Both styles are accepted
  in this codebase; `mem_fs_path` is the more complete fixture and is preferred for any new
  test that needs directory/glob/iterdir semantics rather than single-file read/write.
- Coverage invocation: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  (`.claude/rules/python.md` line 16); `pyproject.toml` `[tool.pytest.ini_options]` (lines
  97-100) fixes `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"` and
  `testpaths = ["tests"]`; `[tool.coverage.run]` (lines 102-110) sets
  `source = ["src", "scripts/dev_tools"]`, so any new module under `scripts/dev_tools/discovery/`
  is automatically in the coverage denominator.
- Coverage-exclusion policy (`.claude/rules/general-unit-test.md` "Coverage Exclusion Policy"):
  no production file under `scripts/dev_tools/` may be added to `[tool.coverage.run] omit`
  (current `omit` list at lines 105-110 is `tests/*`, `*/tests/*`, `__pycache__`,
  `site-packages` only — no production path is excluded). New report-rendering modules must
  stay within this rule; any exclusion of new discovery-report modules would be a Blocking
  finding under feature-review.

## 3. Validator Integration Seam

### 3.1 Canonical pattern (verified)

`validate_orchestrator_state_text(text: str, *, require_complete: bool = False, ...) -> list[str]`
(`scripts/dev_tools/validate_orchestrator_state.py` lines 378-500) is the concrete reference
implementation the epic's shared design cites (epic.md line 111-113): it takes a raw JSON text
string, parses it internally (`json.loads`, line 397), returns an empty list on success or a
list of human-readable error strings, and never mutates its input. `validate_file` in
`validate_json.py` (lines 167-225) demonstrates the file-reading variant that layers `$schema`
resolution on top of the same text-in/errors-out contract.

The stable CLI dispatcher (`validate_orchestration_artifacts.py`, lines 255-320) reads the file
once (`_read_text`, lines 39-59, itself a thin, monkeypatchable wrapper around
`path.read_text(encoding="utf-8")`) and routes to the artifact-specific `validate_<x>_text`
function based on an argparse subparser value. This read-once-dispatch-by-type shape is the
pattern the future `legacy-discovery-validators` CLI is expected to follow, per the epic's
shared design (epic.md line 111-113).

### 3.2 Expected interface reports must call (upstream-dependency assumption)

Since `legacy-discovery-validators` is not present, this feature must design against the
*expected* shape rather than an *observed* one. Based on the canonical pattern above, the
expected upstream interface is:

```python
def validate_coverage_ledger_text(text: str, *, ...) -> list[str]: ...
def validate_parity_matrix_text(text: str, *, ...) -> list[str]: ...
```

exposed from an upstream module such as `scripts.dev_tools.legacy_discovery_validators` (exact
module path TBD when #9003 merges).

### 3.3 Recommended seam (injectable, no temp files)

To keep the dependency injectable/mockable in unit tests without importing not-yet-existing
upstream code and without touching disk:

- Define, inside this feature's own module, a narrow `Protocol` (per
  `.claude/rules/general-code-change.md` "Public APIs and Compatibility" and
  `.claude/rules/python.md` "Dependency seams") describing the callable shape the report layer
  needs, e.g.:

  ```python
  class ArtifactValidator(Protocol):
      def __call__(self, text: str) -> list[str]: ...
  ```

- Have each report's I/O-boundary function accept the validator as an injected parameter with a
  default that imports and binds the real upstream `validate_<artifact>_text` function lazily
  (so importing the report module does not hard-fail before #9003 is merged, and unit tests can
  pass a stub/fake `ArtifactValidator` without any temp file or real upstream import).
- Fail fast: if the injected validator returns a non-empty error list, raise a specific
  exception (e.g. `ArtifactValidationError`) before any rendering occurs, and have the CLI
  `main()` catch it, print the errors, and return a non-zero exit code — mirroring
  `validate_orchestration_artifacts.py` lines 344-352 (`if errors: ... return 1`).
- This "import upstream function directly, inject as a parameter with a real default" seam
  (not "shell out to a dev CLI subprocess") is consistent with `.claude/rules/general-code-change.md`
  "I/O Boundaries" ("Core domain logic must be testable without touching the network or
  filesystem") and avoids the subprocess/temp-file surface a CLI-shell-out approach would
  require.

## 4. Deterministic Rendering Techniques (verified precedent)

- `format_json.py` line 55: `json.dumps(parsed, sort_keys=True, indent=2) + "\n"` is the
  repo's existing canonicalization precedent — `sort_keys=True`, fixed `indent`, explicit
  trailing `"\n"`. The equivalent test comment at
  `tests/scripts/dev_tools/test_format_json.py` line 45 confirms the exact expected byte output
  (`"{}\n"`) is asserted directly, i.e. determinism is verified by literal string equality, not
  by a fuzzy comparison.
- For report text (not necessarily JSON), the same discipline applies: build output via pure
  functions that take structured data and return a deterministic string (see
  `plan_progress_report.py` `render_markdown_table`, lines 256-286, which sorts rows
  deterministically before formatting — `build_report_rows` sorts by
  `(r.feature, r.plan_type)` at line 227 — and joins with `"\n"` at line 286, matching POSIX/LF
  newline discipline throughout the module).
- No wall-clock or RNG appears in any reviewed rendering path. Where a report needs a
  "generated at" field (not required by the acceptance criteria as currently drafted — see
  Section 7), `.claude/rules/general-unit-test.md` "Determinism Infrastructure" requires a
  `Clock`-style injected callable, never a direct `datetime.now()`/`time.time()` call in
  rendering code; the default parameter pattern in `.claude/rules/python.md` "Dependency seams"
  (`clock: Callable[[], datetime] = datetime.now`) is the sanctioned mechanism if a timestamp is
  added later.
- Recommended technique for this feature's JSON-shaped or table-shaped report bodies:
  `json.dumps(data, sort_keys=True, ensure_ascii=True, separators=(",", ":")) + "\n"` for a
  compact byte-identical machine-oriented body, or the `sort_keys=True, indent=2` form (matching
  `format_json.py`) for a human-readable body — pick one and hold it constant per report type;
  do not mix. Any Python collection that determines ordering in the *output* (dict iteration,
  set iteration) must be explicitly sorted before rendering (as `plan_progress_report.py` does
  for its rows) — dict insertion order alone is not a safe determinism guarantee for reports
  that build up their content from artifact fields non-deterministically enumerated (e.g., a set
  of ledger row IDs).

## 5. Report Content Model (domain-neutral, minimal, upstream-contract-shaped)

Because the Coverage Ledger and Parity Matrix field-level schemas are not present (Section 0),
the content model below only assumes the presence of the artifact-category-level fields the
epic documents by name, and is explicitly designed so field-level mapping is finalized when
#9002 merges.

- **Coverage report** (from Coverage Ledger): a deterministic listing of ledger entries
  (whatever the ledger's row/entry field turns out to be named) with a **stable per-entry sort
  key** (candidate: entry ID or, if absent, a case-insensitive sort over all present string
  fields, joined) and an aggregate summary count (total entries, counts by status if the ledger
  exposes a status/coverage-state field). No domain vocabulary (no "TaskMaster", "Outlook",
  etc.) may appear in the renderer; any human-facing labels must come from the artifact's own
  field values, not from framework-hardcoded domain strings.
- **Parity report** (from Parity Matrix): analogous — a deterministic listing of parity-matrix
  rows plus an aggregate summary (counts by parity status if such a field exists in the
  matrix). Same sorting/labeling discipline as the coverage report.
- **Completion report** (aggregate readiness across artifacts): a pure aggregation over the
  outputs of the coverage and parity renderers (and any other discovery artifacts the epic
  names — Feature Contract, Runtime Characterization Scenario, Unspecified Behavior Record,
  Product Decision Record, Evidence Reference — objective-source.md lines 72-78) — a count of
  artifacts present/validated and a readiness signal derived purely from validator pass/fail
  results, not from new domain-specific business logic. Because the other four artifact
  validators are also upstream and unbuilt, the completion report's *minimal* viable v1 scope for
  this feature should be restricted to aggregating over Coverage Ledger + Parity Matrix only
  (the two artifacts this feature explicitly depends on per epic.md line 155:
  "depends_on: [legacy-discovery-schemas, legacy-discovery-validators]"), with the aggregation
  function structured so additional artifact categories can be added as parameters/inputs
  later without a rewrite.

### Separation of pure rendering vs. I/O (per general-code-change.md "I/O Boundaries")

Following the `plan_progress_report.py` precedent exactly:
- Pure: `parse_<artifact>(text: str) -> <ArtifactModel>` (or reuse the parsed `dict` directly if
  no dataclass is warranted yet, given the schema is not final), `build_<report>_rows(...)`,
  `render_<report>(...) -> str`. These functions take already-loaded data/strings and return
  strings; no `Path`, no `open()`, no `sys.argv` inside them.
- I/O boundary: `read_artifact_text(path: Path) -> str` (thin wrapper, easily monkeypatched, no
  temp files needed in tests — matches `_read_text` in
  `validate_orchestration_artifacts.py` lines 39-59), `validate_or_raise(text, validator)`
  (Section 3.3), `write_report(path: Path, content: str) -> None`.
- `main(argv=None) -> int` wires the two together and owns the process exit code, matching every
  reviewed CLI module's `main`.

## 6. Schema-Versioning Consumption (upstream-dependency assumption)

Epic.md's shared design (line 107-110) states #9002 defines directory layout, a version field,
and `$schema` self-reference "reusing `scripts/dev_tools/validate_json.py`'s governed-glob and
`$schema` resolution machinery rather than introducing new schema-loading code." Verified
mechanics of that existing machinery, for report authors to reuse conceptually (not literally
call, since reports validate via the injected validator seam, not by re-implementing schema
resolution):

- `validate_json.py` `validate_file` (lines 167-225) reads `data.get("$schema")` from the
  artifact itself (line 197) and resolves it via `_load_schema` (lines 130-164), which supports
  relative-file, `file://`, and `http(s)://` schema URIs, with `http(s)` schemas cached under a
  configurable `--cache-dir` (default `.cache/schemas`, `parse_args` line 239).
  `json_config.iter_governed_files` (lines 32-52) implements the "governed glob" concept: a
  fixed include/exclude glob pair (`GOVERNED_GLOBS` / `EXCLUDE_GLOBS`, `json_config.py` lines
  12-29) that enumerates JSON files under specific repo subtrees.
- For this feature, the practical consumption pattern is: the artifact's own `$schema` value
  (once #9002 defines it) indicates the schema version in effect. The reports do **not** need to
  re-derive the version independently — the *validator* (Section 3) is the component
  responsible for resolving `$schema` and version-checking; the report layer's only
  version-awareness responsibility is to accept a parsed artifact dict whose shape may vary by
  version and route to the correct field-mapping function. The cleanest seam is a small
  `resolve_field_mapping(artifact: dict) -> FieldMapping` dispatcher keyed off whatever version
  indicator field #9002 defines (candidate: a `schema_version` or embedded `$schema` path
  segment such as `.../v1/coverage-ledger.schema.json`), so that a v2 schema can be supported
  later by adding one new mapping function rather than editing the renderer.

## 7. File-Size and Module Decomposition Proposal

Given the 500-line limit (`.claude/rules/general-code-change.md` "File Size Limit") and the
atomic_executor subpackage precedent (Section 1.3), recommended decomposition:

```
scripts/dev_tools/discovery/
    __init__.py
    io.py                # read_artifact_text, write_report, validator injection Protocol
    coverage_report.py   # pure render + parse_args/main for dev.discovery.coverage-report
    parity_report.py     # pure render + parse_args/main for dev.discovery.parity-report
    completion_report.py # aggregation over coverage+parity outputs + parse_args/main
    rendering.py          # shared deterministic-formatting helpers (sort/format primitives)
```

with mirrored tests under `tests/scripts/dev_tools/discovery/`
(`test_io.py`, `test_coverage_report.py`, `test_parity_report.py`, `test_completion_report.py`,
`test_rendering.py`). This keeps each module small and cohesive (single artifact type per
report module, shared primitives factored into `rendering.py` and `io.py`), avoids one
oversized combined module, and gives each `pyproject.toml` script entry a distinct,
independently testable `main`.

## 8. Behavior Semantics / Requirements Mapping

From `spec.md` / `user-story.md` (already drafted for this feature, both currently template
placeholders outside the "Behavior" and "Acceptance Criteria" sections, which are filled in and
verified identical across `issue.md`, `spec.md`, `user-story.md`):

| Acceptance criterion | Design mapping |
|---|---|
| Coverage report rendered deterministically from Coverage Ledger | `coverage_report.py`: `parse → build_rows (sorted) → render` pure pipeline (Section 5) |
| Parity report rendered deterministically from Parity Matrix | `parity_report.py`, same pipeline shape |
| Completion report presents aggregate readiness | `completion_report.py`, aggregates validator pass/fail + entry counts over coverage+parity (v1 scope; extensible) |
| Byte-identical output for identical input | Deterministic sort + fixed `json.dumps`/table-formatting discipline (Section 4); no `main` writes non-deterministic timestamps unless injected |
| Fail-fast validation before rendering | Injected `ArtifactValidator` Protocol raises before any render call (Section 3.3) |
| `dev.discovery.*` CLI entry points, correct exit codes | Three `main(argv=None) -> int` functions, 0 success / 1 on validation or read failure, per `pyproject.toml [tool.poetry.scripts]` additions (Section 1.2) |
| No domain-specific identifiers in the framework | Renderer never emits hardcoded domain vocabulary; all labels come from artifact field values |
| Tests meet quality-tier coverage (>=85% line, >=75% branch) | Pure-function-heavy design (Section 5) maximizes testable surface without I/O mocking; `mem_fs_path` fixture (Section 2) covers the thin I/O boundary |

Edge cases to cover in tests (from `spec.md` "Seeded Test Conditions" and this design):
malformed/non-conforming artifact (validator returns non-empty errors → non-zero exit, no
render attempted); empty ledger/matrix (zero entries — report renders header/summary only, no
crash); repeated identical-input runs produce byte-identical string output (property-style
assertion: render twice, assert string equality); CLI success and failure exit codes for each
of the three entry points independently.

## 9. Testing Implications

- Unit-test-heavy design per Section 5's pure/I-O split: parsing, row-building, and rendering
  functions are pure and require no fixture beyond plain Python data; only the thin
  `read_artifact_text` / `write_report` boundary needs `monkeypatch` on `Path` methods (the
  hand-rolled dict-store style from `test_format_json.py`, or the fuller `mem_fs_path` fixture
  for directory-aware scenarios) — no `tmp_path`/temp files anywhere, consistent with repo
  policy.
- Determinism must be tested directly: render the same synthetic artifact dict twice and assert
  string equality (byte-for-byte), not merely "renders without error."
- Fail-fast validation must be tested by injecting a fake `ArtifactValidator` that returns
  non-empty errors and asserting the report function raises before any write occurs (assert the
  write function/mock was never called).
- CLI-level tests should call each `main(argv=[...])` with a monkeypatched validator/I-O seam
  and assert the returned exit code, mirroring
  `validate_orchestration_artifacts.py` `main` (lines 323-352) test-style coverage rather than
  spawning a subprocess.
- Coverage tooling: no new `omit` entries permitted for `scripts/dev_tools/discovery/**`
  (Section 2); the module decomposition in Section 7 is sized so each file's uncovered-line
  surface, if any, stays visible and small rather than hidden behind a broad exclusion.
- Property-based tests are not mandated for this module under `.claude/rules/quality-tiers.md`
  (property tests are required only for T1/T2 modules; `scripts/dev_tools` CLI/report code has
  not been assigned a tier — `quality-tiers.yml` does not currently exist at the repo root,
  confirmed via `Glob quality-tiers.yml` returning no results, a pre-existing gap tracked at
  `docs/features/potential/promoted/2026-07-09-quality-tiers-yml-missing-at-repo-root.md`, not
  something this feature needs to remediate). Regardless of tier-gap status, the uniform >=85%
  line / >=75% branch coverage floor applies per `.claude/rules/general-unit-test.md`.

## Rejected Alternatives (brief)

- **Single flat module (`scripts/dev_tools/discovery_reports.py`) housing all three report
  renderers.** Rejected: three renderers plus shared rendering/I-O helpers would likely exceed
  the 500-line limit and mixes unrelated report types in one file, contrary to
  `.claude/rules/python.md` "Small, cohesive modules." The subpackage decomposition (Section 7)
  is preferred and matches the `atomic_executor` precedent.
- **Shelling out to the upstream validator CLI as a subprocess** (rather than importing
  `validate_<artifact>_text` as an injected callable). Rejected: introduces a subprocess/temp-file
  surface, is harder to unit-test deterministically without real files, and contradicts
  `.claude/rules/general-code-change.md` "I/O Boundaries" ("Core domain logic must be testable
  without touching the network or filesystem"). The direct-import-with-injected-default seam
  (Section 3.3) is preferred and mirrors the repo's existing validator-consumption pattern in
  `validate_orchestration_artifacts.py`.

## Open Items for Execution Time

- Exact field names inside the Coverage Ledger and Parity Matrix (blocked on #9002 merging).
- Exact upstream validator module path/function names for
  `validate_coverage_ledger_text` / `validate_parity_matrix_text` (blocked on #9003 merging).
- Exact `schemas/vN/` directory layout and version-field name (blocked on #9002's
  schema-versioning convention decision, epic.md line 107-110, objective-source.md line 143).
- Whether the completion report's v1 scope should be exactly coverage+parity only, or whether
  preparation/planning wants to defer completion-report delivery until more discovery-artifact
  validators exist — flagged here as a scoping question for the plan, not resolved by this
  research.
