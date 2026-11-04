# [P1-T2] PKG/source.py

Timestamp: 2026-11-04T15-57
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_source.py
EXIT_CODE: 0
Output Summary: 41 passed, 0 failed, 0 errors. Cases: BOM (one removed), CRLF then CR, form feed / U+2028 / U+2029 / U+0085 not line breaks, empty text, trailing LF; parse failures (SyntaxError, null-byte ValueError, injected RecursionError / MemoryError / ValueError, tokenize failure) with no warning emitted for an invalid escape; statement, single-line, multi-line and multi-decorator header spans, decorator and parameter spans; every literal_string branch (accepted: plain, implicit concatenation, escape, raw; rejected: empty, leading or trailing whitespace, C0 control, bytes, f-string, number, name, surrogate, None). No __pycache__ under .claude/lib/docs/python after the run.
