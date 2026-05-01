# Final Python Targeted Coverage Evidence

Timestamp: 2026-05-01T00-00Z
Command: `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing`
EXIT_CODE: 0

## Output Summary

48 passed, 0 failed, 0 skipped.

`scripts.dev_tools.codex_native_converter` package total: **95%** (937 stmts, 50 missed).

V2 addition coverage:
- `parser.py`: 88 stmts, 9 missed — **90%** (missed: lines 89, 94, 141-142, 174-175, 257-259)
- `section_intent.py`: 41 stmts, 10 missed — **76%** (missed: lines 163-166, 179-182, 203-204, 214-215, 240-243)
- `intermediate_state.py`: 30 stmts, 4 missed — **87%** (missed: lines 96, 128, 150, 174 — serializer branches for non-empty collections exercised via integration path)
- `engine.py`: 203 stmts, 8 missed — **96%** (missed: lines 200, 209, 317, 331, 469, 477, 521, 734)

Other key converter files:
- `models.py`: 134 stmts, 1 missed — **99%**
- `cli.py`: 44 stmts, 0 missed — **100%**
- `validation.py`: 59 stmts, 1 missed — **98%**
- `reporting.py`: 117 stmts, 3 missed — **97%**
- `inventory.py`: 45 stmts, 2 missed — **96%**
- `mapping.py`: 48 stmts, 2 missed — **96%**
- `classifier.py`: 79 stmts, 6 missed — **92%**
- `rewrites.py`: 46 stmts, 4 missed — **91%**
