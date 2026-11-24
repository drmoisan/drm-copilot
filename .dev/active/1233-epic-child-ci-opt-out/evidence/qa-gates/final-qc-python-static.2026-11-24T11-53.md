# Final QC: Python static (P5-T2, restarted loop)

Timestamp: 2026-11-24T11-53
Command: env -u VIRTUAL_ENV poetry run black --check . ; env -u VIRTUAL_ENV poetry run ruff check . ; env -u VIRTUAL_ENV poetry run pyright (through SCRATCH/issue-1233-py-static.sh, run p5b-py-static)
EXIT_CODE: 0
Output Summary:
- Format: black --check .; exit 0; finding count 0 ("1071 files would be left unchanged.").
- Lint: ruff check .; exit 0; finding count 0 ("All checks passed!").
- Type check: pyright; exit 0; finding count 0 ("0 errors, 0 warnings, 0 informations").
