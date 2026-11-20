# Final QC - Python Static - [P4-T3]

Timestamp: 2026-11-19T12-52
Command: sh SCRATCH/issue-1049-py-static.sh (env -u VIRTUAL_ENV poetry run black --check, poetry run ruff check, poetry run pyright, each on tests/scripts/dev_tools/test_poshqc_bundled_parity.py), step T3 of sh SCRATCH/issue-1049-final.sh issue-1049-final1
EXIT_CODE: 0
Output Summary: Black exit 0, `1 file would be left unchanged.`, 0 findings. Ruff exit 0, `All checks passed!`, 0 findings. Pyright exit 0, `0 errors, 0 warnings, 0 informations`.

| Step | Command | Exit | Findings |
| --- | --- | --- | --- |
| Format | poetry run black --check tests/scripts/dev_tools/test_poshqc_bundled_parity.py | 0 | 0 (`1 file would be left unchanged.`) |
| Lint | poetry run ruff check tests/scripts/dev_tools/test_poshqc_bundled_parity.py | 0 | 0 (`All checks passed!`) |
| Type check | poetry run pyright tests/scripts/dev_tools/test_poshqc_bundled_parity.py | 0 | 0 (`0 errors, 0 warnings, 0 informations`) |
