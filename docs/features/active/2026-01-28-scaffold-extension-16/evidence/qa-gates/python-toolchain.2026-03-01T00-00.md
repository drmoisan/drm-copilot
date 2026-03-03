# Python QA Gates

## Command 1
Timestamp: 2026-03-02T00:53:40Z
Command: poetry run black .
EXIT_CODE: 0
Output Summary: Black passed; 235 files unchanged.

## Command 2
Timestamp: 2026-03-02T00:53:58Z
Command: poetry run ruff check
EXIT_CODE: 0
Output Summary: Ruff passed with no findings.

## Command 3
Timestamp: 2026-03-02T00:54:10Z
Command: poetry run pyright
EXIT_CODE: 0
Output Summary: Pyright passed (0 errors, 0 warnings, 0 informations).

## Command 4
Timestamp: 2026-03-02T00:54:30Z
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary: Pytest passed (798 passed) with total coverage 81%; coverage warning notes `src/lexile_corpus_tuner` was not imported.
