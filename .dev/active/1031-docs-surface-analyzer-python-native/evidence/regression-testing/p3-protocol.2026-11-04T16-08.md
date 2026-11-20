# [P3-T1] PKG/__init__.py and PKG/protocol.py

Timestamp: 2026-11-04T16-08
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_protocol.py
EXIT_CODE: 0
Output Summary: 31 passed, 0 failed, 0 errors. Cases: a valid round trip with files sorted, a parse-error file without facts and ASCII stdout bytes; import-table diagnostics under each selected analyzer; dispatch of all four analyzers with a console script; request defects returning exit 2: malformed JSON, non-UTF-8 bytes, duplicate key, non-finite number, non-object root, unknown key at the request, console-script, file and limits levels, wrong protocol_version (2 and boolean), empty, repeated and unknown analyzers, non-string root, missing fields, repeated path, out-of-range and boolean limits, too many files, oversized text; an injected analyzer exception returning exit 3 with a message that quotes no source text; an interpreter below 3.11 returning exit 4.
