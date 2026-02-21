# Final QA Gates Evidence

- Timestamp: 2026-02-20T21-40
- Command: `poetry run black .` ; `poetry run ruff check` ; `poetry run pyright` ; `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- EXIT_CODE: 0

## Output Summary

- Formatter: `poetry run black .` passed (`85 files left unchanged`).
- Lint: `poetry run ruff check` passed (`All checks passed!`).
- Type-check: `poetry run pyright` passed (`0 errors, 0 warnings, 0 informations`).
- Tests: `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` passed (`795 passed in 13.69s`, total coverage `84%`).
