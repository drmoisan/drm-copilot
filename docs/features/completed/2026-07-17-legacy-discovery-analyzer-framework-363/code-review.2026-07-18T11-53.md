# Code Review — legacy-discovery-analyzer-framework (Issue #363)

- Timestamp: 2026-07-18T11-53
- Branch: `feature/legacy-discovery-analyzer-framework-363` (HEAD `f7a57ff8`)
- Diff base: `origin/epic/legacy-discovery-and-parity-integration`
- Files reviewed: all 7 production modules under `scripts/dev_tools/discovery/analyzer/`, all 8 test files
  under `tests/scripts/dev_tools/discovery/analyzer/`, and the `pyproject.toml` diff.

## Overall Assessment

The implementation is small, cohesive, and matches the spec's module decomposition exactly
(`models.py`, `pipeline.py`, `inventory.py`, `emitter.py`, `cli.py`, `__main__.py`, `__init__.py`).
Pure logic (filtering, classification, serialization) is separated from I/O behind the
`AnalyzerFileSystem` seam. All quality gates pass in a single verified pass. No blocking findings.

## Strengths

- `scripts/dev_tools/discovery/analyzer/pipeline.py` — `Analyzer` as a `typing.Protocol` with a thin
  `run_analyzer` runner is the simplest design that supports multiple implementations; no registry or
  service-locator indirection.
- `scripts/dev_tools/discovery/analyzer/inventory.py:72-129` — `filter_paths`, `classify_unit`, and
  `classify_paths` are pure functions with exact glob semantics matching the spec (empty include = all,
  `fnmatch.fnmatchcase` for platform-independent matching).
- `scripts/dev_tools/discovery/analyzer/emitter.py:34-62` — `compute_schema_ref` defends both failure
  modes (cross-drive `ValueError` re-raised with context; absolute/drive-letter result rejected), and both
  branches are covered by tests via monkeypatched `os.path.relpath`.
- `tests/.../test_pipeline.py:74-95` — `_ExplodingFileSystem` proves `run_analyzer` performs no I/O of its
  own; a precise architectural assertion.
- `tests/.../test_domain_neutrality.py` — the epic-wide invariant is enforced as a contract test
  parametrized over every production module, including a guard that the module list is non-empty
  (`test_production_modules_exist`).
- Determinism is asserted at the strongest level available: byte-identical re-run content
  (`test_inventory_e2e.py:77-95`).

## Non-Blocking Observations

1. **Unhandled `ValueError` path at the CLI boundary (Minor).**
   `emitter.compute_schema_ref` (`emitter.py:52-61`) raises plain `ValueError` when a scheme-less relative
   `$schema` path cannot be produced (e.g., artifact root and schema on different Windows drives). The CLI
   catches only `DomainProfileError` and `AnalyzerError` (`cli.py:143-154`), so this propagates as an
   unhandled traceback instead of a clean exit-1 message. The spec's exit-code contract names only the two
   caught errors, so this conforms to spec; consider wrapping the emit-stage `ValueError` in
   `AnalyzerError` in a follow-up so a misconfigured output drive produces the same operator experience as
   an unreachable root.

2. **Stage state stashed on the analyzer instance (Informational).**
   `InventoryAnalyzer` stores the run context in `self._ctx` during `parse` (`inventory.py:180`) because
   the `Analyzer` protocol signature does not thread `ctx` to later stages. `_require_ctx`
   (`inventory.py:161-165`) fails fast if stages run out of order, and a test covers it
   (`test_inventory.py:111-118`). This makes an analyzer instance single-run stateful; acceptable and
   documented, but worth noting for #9014 implementers (an instance should not be shared across concurrent
   runs).

3. **`_default_schema_path` depends on package depth (Informational).**
   `cli.py:64-67` computes the repo root as `Path(__file__).resolve().parents[4]`. Correct today; will
   silently break if the package is ever relocated. A comment naming the expected root anchor (or resolving
   via a sentinel file) would make the assumption explicit.

4. **`--json` summary paths use OS-native separators (Informational).**
   `cli.py:158` serializes `written_paths` with `str(path)`, so the run summary differs between Windows and
   POSIX hosts. The emitted artifacts themselves are POSIX-normalized; only the stdout summary varies. If
   downstream tooling consumes the summary, consider `as_posix()`.

5. **`walk_files` has no symlink-cycle guard (Informational).**
   `RealAnalyzerFileSystem.walk_files` (`pipeline.py:110-121`) recurses into every directory; a symlink
   cycle in a consumer tree would loop. Consistent with repo precedent and out of scope for the fixture-
   driven tests, but a candidate hardening item for the epic.

6. **Trivial style nit.** `models.py:160` uses `{key: value for key, value in self.metadata}` where
   `dict(self.metadata)` is equivalent.

## Toolchain Verification (independent)

- Black: pass (15 files unchanged).
- Ruff: pass.
- Pyright: 0 errors, 0 warnings.
- Pytest: 1735 passed full-suite; 56 passed in the analyzer subset (none skipped — the schema-validation
  tests executed because `schemas/discovery/v1/evidence-reference.schema.json` is present on the branch).
- Coverage: repo-wide 88.43% line / 87.05% branch; all analyzer modules 100%/100% (parsed from
  `artifacts/python/lcov.info`).

## Verdict

PASS — 0 blocking findings, 6 non-blocking observations (1 minor, 5 informational).
