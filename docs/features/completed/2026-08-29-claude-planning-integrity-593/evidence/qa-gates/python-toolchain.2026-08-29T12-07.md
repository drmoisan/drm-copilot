# Python Final Toolchain

Timestamp: 2026-08-29T13:38:00-04:00

Commands:

1. `git status --porcelain | Measure-Object -Line`; `poetry run black .`; `git status --porcelain | Measure-Object -Line`
2. `poetry run ruff check .`
3. `poetry run pyright`
4. `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: Black reported `458 files left unchanged`; the pre- and post-format status counts were both 38. Ruff reported `All checks passed`. Pyright reported `0 errors, 0 warnings, 0 informations`. Pytest completed with 4,216 passed and 5 skipped; the printed `scripts.dev_tools` coverage table reported 15,210 statements, 1,109 missed, and 93% total line coverage. No formatter restart was required.
