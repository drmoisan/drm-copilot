# P0-T2 Python Static Baseline

Timestamp: 2026-11-16T00-36
Command: env -u VIRTUAL_ENV poetry run black --check scripts/dev_tools/ tests/scripts/dev_tools/
EXIT_CODE: 0
Output Summary: "674 files would be left unchanged." 0 findings.

## Ruff

Command: env -u VIRTUAL_ENV poetry run ruff check scripts/dev_tools/ tests/scripts/dev_tools/
EXIT_CODE: 0
Output Summary: "All checks passed!" 0 findings.

## Pyright

Command: env -u VIRTUAL_ENV poetry run pyright scripts/dev_tools/ tests/scripts/dev_tools/
EXIT_CODE: 0
Output Summary: "0 errors, 0 warnings, 0 informations". 0 findings.
