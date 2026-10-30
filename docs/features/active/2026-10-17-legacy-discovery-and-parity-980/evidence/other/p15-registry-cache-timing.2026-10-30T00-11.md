# P15-T18 — Registry cache timing (discovery runtime test tree)

Task: [P15-T18] Share one verified registry across catalogs built from identical bytes.
Branch: feature/legacy-discovery-and-parity-980
Issue: #980

Both runs use the same command, the same tree of tests (`tests/discovery_runtime`),
no coverage and no pytest cache, on the same host, one after the other. The only
change between them is the content-keyed registry cache in
`packages/discovery-runtime/src/drm_copilot_discovery/catalog.py` and the restated
sharing test in `tests/discovery_runtime/test_catalog.py`.

## Before (tree at the P15-T17 commit, before the cache)

Timestamp: 2026-10-30T00:03Z (run completed; started at 2026-10-29T23:58Z)
Command: `poetry run pytest tests/discovery_runtime -p no:cacheprovider -q`
EXIT_CODE: 0
Output Summary: `6146 passed in 304.69s (0:05:04)`

## After (working tree with the registry cache)

Timestamp: 2026-10-30T00:11Z (run completed; started at 2026-10-30T00:08Z)
Command: `poetry run pytest tests/discovery_runtime -p no:cacheprovider -q`
EXIT_CODE: 0
Output Summary: `6146 passed in 156.30s (0:02:36)`

## Comparison

| Measure | Before | After | Change |
| --- | --- | --- | --- |
| Wall-clock seconds reported by pytest | 304.69 | 156.30 | -148.39 s (-48.7%) |
| Tests passed | 6146 | 6146 | none |
| Tests failed | 0 | 0 | none |

The after value is lower than the before value, which satisfies the P15-T18
acceptance condition. Both runs passed every test, so the saving is not the
result of skipped or failing work.

## Reported full-suite figure (labelled as reported)

Reported (not measured here): the orchestrator-reported full Python suite
wall-clock without coverage was 294 s before this change. That figure covers a
different scope (the full suite rather than `tests/discovery_runtime` alone), was
taken on a different occasion, and is recorded beside the measured values only as
the figure the plan names. It is not used in the comparison above.

## Cache design recorded for the comparison

- `_require_schema_libraries()` runs before every registry access (`_registry`
  and `SchemaCatalog.registry()`), so a missing `jsonschema` or `referencing`
  library is reported even when the cache already holds the registry for the
  requested bytes.
- `_registry_key(documents, extensions)` is the SHA-256 of `canonical_json` over
  every identifier and document pair and every extension's namespace, identifier
  and sha256.
- `_REGISTRY_CACHE` has no eviction. Entries are immutable (`referencing.Registry`
  is frozen) and keyed by content, so the size is bounded by the number of
  distinct schema sets the process builds.
- Line counts after the change: `catalog.py` 479 lines, `test_catalog.py` 371
  lines (both at or below 500). No dependency was added (`pyproject.toml`
  unchanged).
