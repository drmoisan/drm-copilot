# Baseline: Python static (P0-T2)

Timestamp: 2026-11-24T05-16
Command: env -u VIRTUAL_ENV poetry run black --check . ; env -u VIRTUAL_ENV poetry run ruff check . ; env -u VIRTUAL_ENV poetry run pyright (run from the item worktree root through SCRATCH/issue-1233-py-static.sh)
EXIT_CODE: 0
Output Summary:
- black --check: EXIT_CODE 0; "1071 files would be left unchanged."; 0 files would be reformatted (finding count 0). Black ran in check mode.
- ruff check: EXIT_CODE 0; "All checks passed!" (finding count 0).
- pyright: EXIT_CODE 0; "0 errors, 0 warnings, 0 informations" (finding count 0).

Environment: `env -u VIRTUAL_ENV poetry -C <item worktree> install` ran once before the first Poetry command (exit 0).
