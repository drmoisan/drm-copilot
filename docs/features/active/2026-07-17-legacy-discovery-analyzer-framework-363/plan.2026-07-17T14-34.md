# legacy-discovery-analyzer-framework - Plan

- **Issue:** #363
- **Parent (optional):** Epic legacy-discovery-and-parity (child feature #9006, Wave 1, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-34
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Depends on:** legacy-discovery-config-contract (#360), legacy-discovery-schemas (#359)
- **Integration branch:** epic/legacy-discovery-and-parity-integration

## Required References

- Policy compliance order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.github/instructions/*` Python policies.
- Authoritative requirements: `spec.md` (`## Acceptance Criteria`, 12 items) and `user-story.md` (`## Acceptance Criteria`, 8 items).
- Design source: `research/2026-07-17-analyzer-framework-research.md`.
- Epic shared-design constraints: `docs/features/epics/legacy-discovery-and-parity/epic.md`.

**All work must comply with these policies; do not duplicate their content here.**

## Evidence Location Invariant

All evidence artifacts produced by this plan MUST resolve under
`docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/<kind>/`
(`evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/other/`).
No `artifacts/` evidence path is permitted. Timestamp format is `yyyy-MM-ddTHH-mm`. Each
command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

## Language and Coverage Scope

- Language in scope: Python only. Coverage is mandatory: line coverage >= 85%, branch coverage
  >= 75%, and no regression on changed lines (`.claude/rules/general-unit-test.md`,
  `.claude/rules/quality-tiers.md`, `.claude/rules/python.md`).
- Toolchain order per `.claude/rules/python.md`: Black -> Ruff -> Pyright -> Pytest with coverage.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture and Policy Compliance

- [ ] [P0-T1] Read the policy files in the required precedence order (`CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`; then `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`) and record the read.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and an explicit list of every file read in the order above.
- [ ] [P0-T2] Capture the Black formatting baseline by running `poetry run black --check .`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/baseline-black.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and file count).
- [ ] [P0-T3] Capture the Ruff lint baseline by running `poetry run ruff check .`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/baseline-ruff.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [ ] [P0-T4] Capture the Pyright type-check baseline by running `poetry run pyright`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/baseline-pyright.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [ ] [P0-T5] Capture the Pytest coverage baseline by running `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/baseline-pytest-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including numeric baseline line-coverage and branch-coverage headline percentages and the passed/failed test count.

### Phase 1 — Upstream Dependency Verification and Package Scaffolding

- [ ] [P1-T1] Verify the upstream config-contract loader surface and record the dependency status by checking for `scripts/dev_tools/discovery/domain_profile.py` and its documented symbols (`load_profile`/`DomainProfileError`/`DEFAULT_PROFILE_FILENAME`) and for `schemas/discovery/v1/evidence-reference.schema.json`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/upstream-dependency-status.<yyyy-MM-ddTHH-mm>.md` records whether each path/symbol is present or absent and states that absence is a sequencing note (not a preflight blocker) resolved by the integration merge of #360 and #359 before execution.
- [ ] [P1-T2] Create the analyzer subpackage marker file `scripts/dev_tools/discovery/analyzer/__init__.py` that re-exports the public surface (`Analyzer`, `run_analyzer`, `main`) with import guards that tolerate the pre-merge absence of the shared package root.
  - Acceptance: `scripts/dev_tools/discovery/analyzer/__init__.py` exists, is under 500 lines, and exposes the named symbols in `__all__`.
- [ ] [P1-T3] Add the single Poetry console-script line `"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"` to `[tool.poetry.scripts]` in `pyproject.toml`.
  - Acceptance: `pyproject.toml` contains exactly one new `dev.discovery.inventory` entry mapping to `scripts.dev_tools.discovery.analyzer.cli:main`; no `dev.discovery.profile` entry is added (reserved by #360).

### Phase 2 — Value Objects and Enums (models.py)

- [ ] [P2-T1] Implement the frozen value objects and `UnitType(str, Enum)` in `scripts/dev_tools/discovery/analyzer/models.py`: `AnalyzerContext` (`source_root`, `include`, `exclude`, `artifact_root`, schema-relative base, `captured_at`), `ParseResult`, `ClassifyResult`, `EvidenceRecord` with `to_json_dict()`, `AnalyzerRunResult`, all `@dataclass(frozen=True, slots=True)`, type-only imports under `TYPE_CHECKING`.
  - Acceptance: `scripts/dev_tools/discovery/analyzer/models.py` defines the six value objects plus `UnitType` with `file|project|solution` members; file is under 500 lines; module is fully type-annotated.
- [ ] [P2-T2] Create `tests/scripts/dev_tools/discovery/analyzer/test_models.py` asserting immutability (frozen), `UnitType` membership, and that `EvidenceRecord.to_json_dict()` produces the exact Evidence Reference field set.
  - Acceptance: `tests/scripts/dev_tools/discovery/analyzer/test_models.py` exists, tests pass under `poetry run pytest tests/scripts/dev_tools/discovery/analyzer/test_models.py`, and covers frozen-mutation rejection and enum values.

### Phase 3 — Pipeline Protocol, Filesystem Seam, and Runner (pipeline.py)

- [ ] [P3-T1] Implement `scripts/dev_tools/discovery/analyzer/pipeline.py` defining the `Analyzer` `typing.Protocol` (with `name` and the four stage methods with `...` bodies), the `AnalyzerFileSystem` `Protocol`, a `RealAnalyzerFileSystem` implementation, and the `run_analyzer(analyzer, ctx, fs) -> AnalyzerRunResult` runner that invokes `parse -> classify -> map -> emit` in fixed order and threads outputs.
  - Acceptance: `scripts/dev_tools/discovery/analyzer/pipeline.py` exists, is under 500 lines, protocol stage bodies are `...` (type-only), and `run_analyzer` threads each stage output to the next.
- [ ] [P3-T2] Create `tests/scripts/dev_tools/discovery/analyzer/test_pipeline.py` with a fake `Analyzer` implementing the protocol that records call order, asserting `run_analyzer` invokes parse -> classify -> map -> emit in order and returns an `AnalyzerRunResult` carrying the emitted records and written paths (scenario 1).
  - Acceptance: `tests/scripts/dev_tools/discovery/analyzer/test_pipeline.py` exists and its stage-sequencing test passes with no filesystem access.

### Phase 4 — Inventory Analyzer: Enumeration, Filtering, Classification (inventory.py)

- [ ] [P4-T1] Implement `AnalyzerError(ValueError)` and the `InventoryAnalyzer` `parse` stage in `scripts/dev_tools/discovery/analyzer/inventory.py`: resolve `source_root`, fail fast with `AnalyzerError` naming the path when the resolved root does not `exists()`/`is_dir()`, and return consumer-relative POSIX paths from a seam-based walk in deterministic POSIX-sorted order.
  - Acceptance: `scripts/dev_tools/discovery/analyzer/inventory.py` defines `AnalyzerError` and `InventoryAnalyzer.parse`; the module is under 500 lines; `AnalyzerError` is distinct from `DomainProfileError`.
- [ ] [P4-T2] Implement the pure include/exclude filter helper in `inventory.py` applying `fnmatch` against consumer-relative POSIX paths (inventoried when matching at least one `include` pattern or `include` empty, AND matching no `exclude` pattern).
  - Acceptance: the filter is a pure function taking relative paths plus include/exclude tuples and returning the filtered ordered set, with no filesystem dependency.
- [ ] [P4-T3] Implement the pure classification helper and `InventoryAnalyzer.classify` in `inventory.py` assigning `UnitType` from a neutral, profile-supplied marker pattern table (no `.csproj`/`.sln` or stack literals; default markers are generic pattern data).
  - Acceptance: `classify` returns a `ClassifyResult` tagging each unit `file|project|solution` via profile-supplied markers; no stack-specific literal appears in the module.
- [ ] [P4-T4] Create `tests/scripts/dev_tools/discovery/analyzer/test_inventory.py` covering enumeration over an in-memory `mem_fs_path` fixture tree with deterministic POSIX ordering (scenario 2), parametrized include/exclude glob handling for include-only/exclude-only/both/empty-include cases (scenario 3), parametrized marker classification for matching and non-matching filenames (scenario 4), and the unreachable/missing-root `AnalyzerError` distinct from `DomainProfileError` (scenario 6).
  - Acceptance: `tests/scripts/dev_tools/discovery/analyzer/test_inventory.py` exists, uses only `mem_fs_path` (no temporary files), and all four scenario groups pass.

### Phase 5 — Evidence Reference Emission (emitter.py) and map/emit stages

- [ ] [P5-T1] Implement `scripts/dev_tools/discovery/analyzer/emitter.py` to build the Evidence Reference v1 JSON dict from an `EvidenceRecord`: `schema_version="1.0.0"` (matching `^1\.\d+\.\d+$`), scheme-less relative POSIX `$schema` path computed with `PurePosixPath`/`os.path.relpath(...).replace(os.sep, "/")` (never a drive letter or leading `/`), `id` matching `^[a-z0-9][a-z0-9._-]*$`, `kind="file"`, consumer-relative POSIX `location`, injected-clock `captured_at`, domain-neutral `description`, optional `content_hash` via stdlib `hashlib`, optional `tool="dev.discovery.inventory"`, inventory extras only under `metadata`, serialized with `json.dumps(..., sort_keys=True, indent=2)`.
  - Acceptance: `scripts/dev_tools/discovery/analyzer/emitter.py` exists, is under 500 lines, emits no top-level field outside the schema declared set except `metadata`, and never emits an absolute Windows path in `$schema`.
- [ ] [P5-T2] Implement `InventoryAnalyzer.map` and `InventoryAnalyzer.emit` in `inventory.py`: `map` builds one `EvidenceRecord` per inventoried unit; `emit` writes one Evidence Reference instance per record via the `AnalyzerFileSystem` seam under the resolved output root and returns the written paths.
  - Acceptance: `map` returns a tuple of `EvidenceRecord` (one per unit) and `emit` returns the written paths, writing exclusively through the filesystem seam.
- [ ] [P5-T3] Record the documented cross-feature emission-shape assumption (N Evidence Reference instances vs a single aggregate artifact) to reconcile with the schemas feature (#359).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/emission-shape-assumption.<yyyy-MM-ddTHH-mm>.md` states the adopted N-instances pattern, the reason, and that the shape is revisited before freeze if #359 confirms an aggregate artifact is preferred.
- [ ] [P5-T4] Create `tests/scripts/dev_tools/discovery/analyzer/test_emitter.py` (scenario 5): assert the produced dict has exactly the Evidence Reference field set (required plus optional only, no unexpected top-level keys), `schema_version` matches `^1\.\d+\.\d+$`, `$schema` is scheme-less relative (no drive letter, no leading `/`), `id` matches `^[a-z0-9][a-z0-9._-]*$`, `captured_at` derives from an injected clock, and validate the instance against `schemas/discovery/v1/evidence-reference.schema.json` using the dev `jsonschema` path with a skip guard when the schema file is absent pre-merge.
  - Acceptance: `tests/scripts/dev_tools/discovery/analyzer/test_emitter.py` exists, uses an injected clock (no wall-clock read), uses `mem_fs_path` for any write, and asserts field-set exactness and `$schema` POSIX-relative form.

### Phase 6 — CLI Wiring (cli.py, __main__.py)

- [ ] [P6-T1] Implement `scripts/dev_tools/discovery/analyzer/cli.py` with an `argparse` surface (positional `profile` defaulting to `DEFAULT_PROFILE_FILENAME`, `--output-dir`, `--json`) and `main(argv) -> int` that loads the profile via `scripts/dev_tools/discovery/domain_profile.py`, constructs `InventoryAnalyzer()`, runs `run_analyzer`, prints a `--json` run summary, and maps errors to exit codes: `0` success, `1` on `DomainProfileError`/`AnalyzerError` caught at the CLI boundary, `2` argparse usage error.
  - Acceptance: `scripts/dev_tools/discovery/analyzer/cli.py` exists, is under 500 lines, `main` returns int exit codes 0/1, and argparse owns exit code 2; the profile loader is imported at the CLI module boundary so tests can patch it there.
- [ ] [P6-T2] Implement `scripts/dev_tools/discovery/analyzer/__main__.py` delegating `python -m ...` to `cli.main` via `sys.exit(main())` under the `if __name__ == "__main__":` guard.
  - Acceptance: `scripts/dev_tools/discovery/analyzer/__main__.py` exists and delegates to `cli.main`; the guard line is coverage-excluded per existing `[tool.coverage.report] exclude_lines`.
- [ ] [P6-T3] Create `tests/scripts/dev_tools/discovery/analyzer/test_cli.py` (scenario 7): `--help`/bad args -> exit `2`; a valid run over an in-memory `mem_fs_path` tree with the profile loader patched at its CLI import location -> exit `0` with expected written paths and a `--json` summary; malformed profile (`DomainProfileError`) and unreachable root (`AnalyzerError`) -> exit `1`.
  - Acceptance: `tests/scripts/dev_tools/discovery/analyzer/test_cli.py` exists, patches the loader at the CLI import location, uses only `mem_fs_path`, and all three exit-code groups pass.

### Phase 7 — Domain-Neutrality Contract Test and End-to-End Integration

- [ ] [P7-T1] Create `tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py` (scenario 8) scanning every production module under `scripts/dev_tools/discovery/analyzer/` for banned substrings (case-insensitive: `taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`) and stack literals (`.csproj`, `.sln`) in code, field names, defaults, error messages, and docstrings.
  - Acceptance: `tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py` exists and fails if any banned substring or stack literal is present in a production analyzer module; it passes against the delivered modules.
- [ ] [P7-T2] Create `tests/scripts/dev_tools/discovery/analyzer/test_inventory_e2e.py` exercising the inventory analyzer end-to-end from an in-memory profile-driven `AnalyzerContext` through `run_analyzer` to a collection of schema-conforming Evidence Reference instances on the `mem_fs_path` seam, asserting deterministic byte-identical output for a fixed clock value.
  - Acceptance: `tests/scripts/dev_tools/discovery/analyzer/test_inventory_e2e.py` exists, produces one instance per inventoried unit, and asserts re-run determinism with a fixed injected clock; no temporary files are used.

### Phase 8 — Final QC Loop and Coverage Verification

- [ ] [P8-T1] Run the Black formatter check as the first QC stage with `poetry run black --check .`; if it reports changes, apply `poetry run black .` and restart the QC loop from this task.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/finalqc-black.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:`.
- [ ] [P8-T2] Run the Ruff lint stage with `poetry run ruff check .`; if it fails or auto-fixes files, correct and restart the QC loop from P8-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/finalqc-ruff.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:` (0 errors).
- [ ] [P8-T3] Run the Pyright type-check stage with `poetry run pyright`; if it fails, correct and restart the QC loop from P8-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/finalqc-pyright.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:` (0 errors, 0 warnings).
- [ ] [P8-T4] Run the Pytest coverage stage with `poetry run pytest --cov --cov-branch --cov-report=term-missing`; if any test fails or files change, correct and restart the QC loop from P8-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/finalqc-pytest-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:` including numeric post-change line-coverage and branch-coverage headline percentages and the passed test count.
- [ ] [P8-T5] Verify the coverage delta and thresholds by comparing the Phase 0 baseline against the Phase 8 post-change coverage and computing new/changed-code coverage for the new analyzer modules.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/coverage-delta.<yyyy-MM-ddTHH-mm>.md` reports baseline line/branch coverage, post-change line/branch coverage, and new/changed-code line and branch coverage, and confirms line >= 85%, branch >= 75%, and no regression on changed lines. If any required value is unavailable, the outcome is remediation-required, not PASS.
- [ ] [P8-T6] Verify traceability of all 12 spec.md acceptance criteria and all 8 user-story.md acceptance criteria to implementing tasks and passing tests.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/acceptance-traceability.<yyyy-MM-ddTHH-mm>.md` maps each acceptance criterion to its task ID(s) and test(s), with no unmapped criterion.

## Test Plan

- Unit: pipeline stage sequencing (P3-T2); value-object immutability and enum (P2-T2); inventory enumeration, include/exclude globs, marker classification, unreachable-root fail-fast (P4-T4); schema-conforming emission (P5-T4); CLI exit codes 0/1/2 (P6-T3); domain-neutrality contract (P7-T1).
- Integration: inventory analyzer end-to-end from profile-driven context to a schema-conforming collection of Evidence Reference instances with re-run determinism (P7-T2).
- Manual/CLI: `dev.discovery.inventory` load-and-emit with `--output-dir` and `--json`; non-zero exit on malformed profile or unreachable source root (exercised via P6-T3).
- Coverage evidence:
  - Baseline: `evidence/baseline/baseline-pytest-coverage.<yyyy-MM-ddTHH-mm>.md`.
  - Post-change: `evidence/qa-gates/finalqc-pytest-coverage.<yyyy-MM-ddTHH-mm>.md`.
  - Delta/threshold comparison: `evidence/qa-gates/coverage-delta.<yyyy-MM-ddTHH-mm>.md`.

## Open Questions / Notes

- Upstream sequencing: the config-contract loader (`scripts/dev_tools/discovery/domain_profile.py`, #360) and the discovery v1 schema files (`schemas/discovery/v1/`, #359) are absent in this worktree and merge into the integration branch before execution. P1-T1 records their presence/absence as a sequencing note; it is not a preflight blocker.
- Emission shape (N Evidence Reference instances vs aggregate artifact) is a documented cross-feature assumption pending confirmation from #359 (recorded in P5-T3).
- File-size limit: every production and test module must remain under 500 lines; the framework is split across `models.py`, `pipeline.py`, `inventory.py`, `emitter.py`, `cli.py`, and `__main__.py`.
- No new runtime dependency is added; production code uses stdlib only. `jsonschema` is used by tests only, guarded for pre-merge schema-file absence.
