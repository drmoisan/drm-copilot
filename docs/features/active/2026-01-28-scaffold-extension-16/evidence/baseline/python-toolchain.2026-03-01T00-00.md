# Baseline Python Toolchain Evidence

## Command 1
Timestamp: 2026-03-02T00:24:14Z
Command: poetry run black .
EXIT_CODE: 0
Output Summary: `black` completed successfully; 234 files unchanged.

## Command 2
Timestamp: 2026-03-02T00:24:31Z
Command: poetry run ruff check
EXIT_CODE: 0
Output Summary: `ruff` checks passed.

## Command 3
Timestamp: 2026-03-02T00:24:40Z
Command: poetry run pyright
EXIT_CODE: 0
Output Summary: `pyright` reported 0 errors, 0 warnings.

## Command 4
Timestamp: 2026-03-02T00:25:00Z
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary: `pytest` passed (798 passed), coverage total 81%, with warning that `src/lexile_corpus_tuner` was not imported.
