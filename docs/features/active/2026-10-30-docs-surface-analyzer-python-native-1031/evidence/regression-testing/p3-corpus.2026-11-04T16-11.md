# [P3-T4] PYTESTS/test_docs_python_native_corpus.py

Timestamp: 2026-11-04T16-11
Command: poetry run python -m pytest --strict-markers --strict-config -v -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_corpus.py
EXIT_CODE: 0
Output Summary: 4 passed (one test per identifier: python-architecture, python-cli, python-http, python-public-api), 0 failed, 0 errors. Interpreter: Python 3.13.18. S1: emitted facts equal the 1022 expected elements with .py paths plus the 1031 native_only_elements for every file that parses on the running interpreter; the three files no supported interpreter parses (lex_indent, lex_unclassified, lex_unterminated) report parse-error. S2: every retained diagnostic_classes row is reported with the same code, path and analyzer_id, and no resolved or scanner-only row is.
