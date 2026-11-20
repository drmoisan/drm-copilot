# Final Python Test + Coverage Evidence

Timestamp: 2026-05-01T00-00Z
Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing`
EXIT_CODE: 0

## Output Summary

1060 passed, 14 skipped (skips are for `.codex`/`.agents` directories that are gitignored and unavailable in CI). 0 failures.

Overall coverage: **84%** across `src` and `scripts/dev_tools` (8024 statements, 1253 missed).

Key v2 addition coverage figures:
- `scripts/dev_tools/codex_native_converter/engine.py`: 203 stmts, 8 missed — **96%**
- `scripts/dev_tools/codex_native_converter/intermediate_state.py`: 30 stmts, 4 missed — **87%**
- `scripts/dev_tools/codex_native_converter/parser.py`: 88 stmts, 9 missed — **90%**
- `scripts/dev_tools/codex_native_converter/section_intent.py`: 41 stmts, 10 missed — **76%**
- `scripts/dev_tools/codex_native_converter/models.py`: 134 stmts, 1 missed — **99%**
- `scripts/dev_tools/codex_native_converter/reporting.py`: 117 stmts, 3 missed — **97%**
- `scripts/dev_tools/codex_native_converter/validation.py`: 59 stmts, 1 missed — **98%**
