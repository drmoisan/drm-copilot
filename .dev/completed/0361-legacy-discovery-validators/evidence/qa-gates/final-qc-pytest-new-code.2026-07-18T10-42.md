Timestamp: 2026-07-18T10-42
Command: poetry run pytest --cov=scripts.dev_tools.schema_loading --cov=scripts.dev_tools.validate_discovery_profile --cov=scripts.dev_tools.validate_discovery_schema_artifacts --cov=scripts.dev_tools.validate_discovery_artifacts --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_schema_loading.py tests/scripts/dev_tools/test_validate_discovery_profile.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py
EXIT_CODE: 0
Output Summary: 38 passed, 0 failed. New-code coverage scoped to exactly the
four new modules (schema_loading.py, validate_discovery_profile.py,
validate_discovery_schema_artifacts.py, validate_discovery_artifacts.py; 165
statements, 44 branches): new-code line coverage = 93.33% (154/165
statements covered); new-code branch coverage = 88.64% (39/44 branches
covered). Both figures were computed from `coverage json` totals generated
immediately after this pytest run.

Per-file note: `schema_loading.py` alone shows 71% line / 64% branch within
this narrow scope, because its `file://` and `http(s)://` fetch-and-cache
branches are exercised by the pre-existing `test_validate_json.py` suite
(via `validate_json.py`'s thin `_load_schema`/`_cache_path` wrappers, e.g.
`test_load_schema_fetch_and_cache`, `test_validate_relative_schema`) rather
than duplicated in the five new test files run above, consistent with
Design Decision 3's non-duplication intent. The full-suite run (P7-T4)
confirms `schema_loading.py` reaches 82% line coverage once those
pre-existing tests are included, and the aggregate across all four new
modules in this scoped run (93.33% line, 88.64% branch) comfortably meets
the uniform thresholds (line >= 85%, branch >= 75%).
