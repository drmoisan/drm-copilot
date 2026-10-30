# P14-T4 Shared-registry safety verification and correction

Timestamp: 2026-10-29T10-23
Task: [P14-T4] Build and verify the schema registry once per catalog.
Command: poetry run pytest tests/discovery_runtime/test_catalog.py tests/discovery_runtime/test_schema_validation.py -p no:cacheprovider
EXIT_CODE: 0
Output Summary: `103 passed in 34.75s` after the correction: all 45 test_catalog.py cases (including the three P14-T2 tests) and all 58 test_schema_validation.py cases (including the P14-T3 test). Black "1 file left unchanged.", Ruff "All checks passed!", Pyright "0 errors, 0 warnings, 0 informations" over catalog.py and both test modules. `wc -l` of catalog.py = 399 (at most 500). No test file was modified by this task and no dependency was added.

## Library facts (read before editing)

Installed versions in the project virtual environment: referencing 0.37.0, jsonschema 4.26.0. Source read: `referencing/_core.py`.

| Fact | Observation in referencing/_core.py |
| --- | --- |
| `Registry` is immutable | `class Registry(Mapping[URI, Resource[D]])` is decorated `@frozen` (attrs) |
| `Resolver` is immutable | `class Resolver(Generic[D])` is decorated `@frozen` |
| `Registry.with_resources` returns a new registry | ends with `return evolve(self, resources=resources, uncrawled=uncrawled)`; `with_resource` delegates to it |
| `Registry.crawl` returns a new registry | ends with `return evolve(self, resources=..., anchors=..., uncrawled=EMPTY_UNCRAWLED)` |
| `Resolver.lookup` returns evolved state | builds the next resolver through `self._evolve(registry=retrieved.registry, base_uri=uri)`, which calls `evolve(...)`; the receiver is not changed |

## Callers of `registry()` (search over packages, scripts and tests)

| Caller | Use | Mutates registry or resolved contents |
| --- | --- | --- |
| `drm_copilot_discovery.schema_validation._validator` | passes `catalog.registry()` to a new `Draft202012Validator(schema, registry=..., format_checker=...)` | No |
| `SchemaCatalog.__post_init__` (before the change) | bare `self.registry()` call for eager closure verification; replaced by the stored build | No |
| tests/discovery_runtime/test_catalog.py: `test_registry_denies_unknown_runtime_retrieval`, `test_extension_accepts_local_refs_and_rejects_duplicate_namespace`, and the three P14-T2 tests | read-only `resolver().lookup(...)` and identity comparisons; one `.contents ==` comparison | No |
| tests/discovery_runtime/test_schema_validation.py: `test_repeated_validations_through_one_catalog_are_independent` | read-only `.contents` before and after validation | No |

A search for assignment or mutating calls on `.contents` (`.contents[...] =`, `.contents =`, `.contents.update/pop/clear/setdefault`) in packages, scripts and tests returned no match. The other `.registry` attribute uses in the tree belong to the activation store and the analyzer registry, which are unrelated to the schema catalog. No caller mutates the registry or resolved schema contents, so sharing proceeds.

## Change (packages/discovery-runtime/src/drm_copilot_discovery/catalog.py)

- `SchemaCatalog` gains the private field `_shared_registry` with `field(init=False, compare=False, repr=False)`; the frozen, keyword-only contract and equality and hashing over `documents` and `extensions` are unchanged.
- `__post_init__` ends with `object.__setattr__(self, "_shared_registry", _registry(self.documents + self.extension_documents(), self.extensions))` in place of the bare `self.registry()` call; `extension_documents()` is still called once during construction, so extension failures are still raised at construction.
- `registry()` returns the stored value and performs no build; its docstring states the shared immutable registry and why sharing is safe.
- The class docstring now states that verification happens once at construction and that validators are created per call over the shared registry.
- `_registry`, `load_catalog`, `schema` and `schema_for_alias` are unchanged.

Set O dispositions applied: every pre-existing test in both modules passes unchanged. `dataclasses.replace` re-runs `__post_init__`, so the replace-based negative tests still raise and each replaced catalog builds its own registry (asserted by `test_distinct_catalogs_do_not_share_a_registry`).

Result: PASS
