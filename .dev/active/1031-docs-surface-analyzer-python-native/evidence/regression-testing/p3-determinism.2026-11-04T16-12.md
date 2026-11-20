# [P3-T6] PYTESTS/test_docs_python_native_determinism.py

Timestamp: 2026-11-04T16-12
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_determinism.py
EXIT_CODE: 0
Output Summary: 3 passed, 0 failed, 0 errors. The same request twice yields identical stdout bytes; every rotation and the reversal of the request file order yield identical bytes; a request with non-ASCII identifiers yields stdout whose every byte is below 0x80 while the decoded declaration keeps the identifier.
