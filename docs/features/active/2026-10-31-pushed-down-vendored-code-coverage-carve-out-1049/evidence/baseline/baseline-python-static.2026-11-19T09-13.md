# Baseline - Python Static - [P0-T9]

Timestamp: 2026-11-19T09-13
Command: sh SCRATCH/issue-1049-py-static.sh (env -u VIRTUAL_ENV poetry run black --check, poetry run ruff check, poetry run pyright, each on tests/scripts/dev_tools/test_poshqc_bundled_parity.py; Poetry env resolved inside this worktree)
EXIT_CODE: 0
Output Summary: Black exit 0, `1 file would be left unchanged.`, 0 findings. Ruff exit 0, `All checks passed!`, 0 findings. Pyright exit 0, `0 errors, 0 warnings, 0 informations`.
