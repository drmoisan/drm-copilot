# Final QC: Python static (P5-T2)

Timestamp: 2026-11-24T11-40
Command: env -u VIRTUAL_ENV poetry run black --check . ; env -u VIRTUAL_ENV poetry run ruff check . ; env -u VIRTUAL_ENV poetry run pyright (run from the item worktree root through SCRATCH/issue-1233-py-static.sh at 2026-11-24T11-31)
EXIT_CODE: 0
Output Summary:
- Format: black --check .; exit 0; finding count 0 ("1071 files would be left unchanged."; 0 "would reformat" lines).
- Lint: ruff check .; exit 0; finding count 0 ("All checks passed!").
- Type check: pyright; exit 0; finding count 0 ("0 errors, 0 warnings, 0 informations").
- Zero findings, equal to baseline-python-static.2026-11-24T05-16.md.
