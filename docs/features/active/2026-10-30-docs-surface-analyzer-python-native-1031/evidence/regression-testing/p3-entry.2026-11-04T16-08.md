# [P3-T2] PYLIB/run_docs_python_native.py

Timestamp: 2026-11-04T16-08
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_entry.py
EXIT_CODE: 0
Output Summary: 5 passed, 0 failed, 0 errors. Cases: version_info (3, 10, 14) returns 4 and writes exactly one version-below-floor error object; (3, 11, 0) delegates to docs_python_native.protocol.main and returns 0; ensure_package_path inserts an absent directory at index 0 and leaves a present one unchanged (local lists only); ast.parse(<entry script text>, feature_version=(3, 6)) succeeds, so an older interpreter reaches the version check.
