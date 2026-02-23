# Python QA Gate Evidence

## Run 1 — Pyright scope remediation verification

Timestamp: 2026-02-22T00:04:05-05:00
Command: poetry run pyright
EXIT_CODE: 0
Output Summary:
- 0 errors, 0 warnings, 0 informations
- No diagnostics reported for files under node_modules/
GateStatus: PASS

## Run 2 — Targeted verification with coverage

Timestamp: 2026-02-22T01:26:00-05:00
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- 771 passed in 2.24s
- Coverage total: 81%
- Coverage warning observed: `src/lexile_corpus_tuner` module not imported in this run
GateStatus: PASS

## Run 3 — Final full toolchain loop (single uninterrupted clean pass)

Timestamp: 2026-02-22T01:55:00-05:00
Command: poetry run black .
EXIT_CODE: 0
Output Summary:
- All done; 113 files left unchanged

Timestamp: 2026-02-22T01:55:20-05:00
Command: poetry run ruff check
EXIT_CODE: 0
Output Summary:
- All checks passed

Timestamp: 2026-02-22T01:55:40-05:00
Command: poetry run pyright
EXIT_CODE: 0
Output Summary:
- 0 errors, 0 warnings, 0 informations

Timestamp: 2026-02-22T01:56:20-05:00
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- 771 passed in 2.48s
- Coverage total: 81%

GateStatus: PASS
