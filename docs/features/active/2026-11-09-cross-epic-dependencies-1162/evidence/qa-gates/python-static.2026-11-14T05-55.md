# Python final QC static (P5-T4)

Timestamp: 2026-11-14T05-54
Command: sh SCRATCH/issue-1162-pyfull.sh (from the item worktree root): env -u VIRTUAL_ENV poetry run black --check . ; env -u VIRTUAL_ENV poetry run ruff check . ; env -u VIRTUAL_ENV poetry run pyright
EXIT_CODE: 0
Output Summary:
- Step 1 Black check: Command: poetry run black --check . | EXIT_CODE: 0 | findings: 0 ("1065 files would be left unchanged.")
- Step 2 Ruff: Command: poetry run ruff check . | EXIT_CODE: 0 | findings: 0 ("All checks passed!")
- Step 3 Pyright: Command: poetry run pyright | EXIT_CODE: 0 | findings: 0 ("0 errors, 0 warnings, 0 informations")
- Each EXIT_CODE is the tool's own exit status, captured before any output filtering. The run ended at 2026-11-14T05-55.
