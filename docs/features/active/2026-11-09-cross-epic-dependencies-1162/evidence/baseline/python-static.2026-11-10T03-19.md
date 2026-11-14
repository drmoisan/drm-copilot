# Python static baseline (P0-T3)

Timestamp: 2026-11-10T03-19
Command: env -u VIRTUAL_ENV poetry run black --check . ; poetry run ruff check . ; poetry run pyright (run from the item worktree root through sh SCRATCH/issue-1162-pystatic.sh)
EXIT_CODE: 0
Output Summary:
- Step 1 Black check: Command: poetry run black --check . | EXIT_CODE: 0 | findings: 0 ("1060 files would be left unchanged.")
- Step 2 Ruff: Command: poetry run ruff check . | EXIT_CODE: 0 | findings: 0 ("All checks passed!")
- Step 3 Pyright: Command: poetry run pyright | EXIT_CODE: 0 | findings: 0 ("0 errors, 0 warnings, 0 informations")
