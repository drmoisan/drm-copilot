# Baseline Evidence — Python (Remediation)

- Timestamp: 2026-02-23T20-34
- Command: poetry run black .
- EXIT_CODE: 0
- Output Summary: Black reported all files unchanged.

- Timestamp: 2026-02-23T20-34
- Command: poetry run ruff check
- EXIT_CODE: 1
- Output Summary: 1 lint finding (`TCH003`) in `tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py`.

- Timestamp: 2026-02-23T20-34
- Command: poetry run pyright
- EXIT_CODE: 0
- Output Summary: 0 errors, 0 warnings, 0 infos.

- Timestamp: 2026-02-23T20-34
- Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
- EXIT_CODE: 0
- Output Summary: 797 passed; coverage total 81%.
