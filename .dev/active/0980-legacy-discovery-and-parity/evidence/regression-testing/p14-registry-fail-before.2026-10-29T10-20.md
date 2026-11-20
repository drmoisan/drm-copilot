# P14-T2 Registry-sharing tests fail before the correction

Timestamp: 2026-10-29T10-20
Task: [P14-T2] [expect-fail] Add the registry-sharing tests to the catalog module before the correction.
Command: poetry run pytest tests/discovery_runtime/test_catalog.py -p no:cacheprovider
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `1 failed, 44 passed in 19.59s` on the uncorrected `packages/discovery-runtime/src/drm_copilot_discovery/catalog.py`. The single failing node is `tests/discovery_runtime/test_catalog.py::test_registry_is_built_once_per_catalog` with `AssertionError: registry built 4 times for one catalog` (`assert 4 == 1`): one build in `__post_init__` plus one per `registry()` call. The two other new tests, `test_distinct_catalogs_do_not_share_a_registry` and `test_extension_registry_is_scoped_to_its_catalog`, pass, as do all 42 pre-existing test cases.

## Added tests (tests/discovery_runtime/test_catalog.py)

- `test_registry_is_built_once_per_catalog`: patches `drm_copilot_discovery.catalog._registry` with a counting wrapper that delegates to the original; after `load_catalog()` and three `registry()` calls asserts a count of 1 and one identical registry object. Observed count before the correction: 4.
- `test_distinct_catalogs_do_not_share_a_registry`: two `load_catalog()` results return non-identical registries; `dataclasses.replace` of a catalog increments the counter by exactly one, and the copy's registry is not the original's.
- `test_extension_registry_is_scoped_to_its_catalog`: an extension identifier resolves through the extension catalog's registry and raises `Unresolvable` through a plain catalog's registry.

The tests use in-memory catalogs and a monkeypatched module attribute only; no temporary file, process or network access. Pre-existing tests in the module are unchanged (Set O).

Static gates on the changed file: Black "1 file left unchanged.", Ruff "All checks passed!", Pyright "0 errors, 0 warnings, 0 informations".

File size: `wc -l tests/discovery_runtime/test_catalog.py` = 353 (at most 500).

Result: PASS (expected failure observed)
