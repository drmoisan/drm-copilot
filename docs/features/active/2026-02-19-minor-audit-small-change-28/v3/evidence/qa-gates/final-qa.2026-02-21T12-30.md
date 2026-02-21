Timestamp: 2026-02-21T12-30
Command: poetry run black .
EXIT_CODE: 0
Output Summary: All done; 87 files left unchanged.

Command: poetry run ruff check
EXIT_CODE: 0
Output Summary: All checks passed.

Command: poetry run pyright
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations.

Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 809 passed in 15.99s; total coverage 84%.
