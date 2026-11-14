# Python Static Baseline (P0-T2)

Timestamp: 2026-11-14T06-47
Command: sh SCRATCH/issue-1173-p0t2.sh (from the worktree root: env -u VIRTUAL_ENV poetry run black --check; poetry run ruff check; poetry run pyright; each over .claude/lib/docs/python/docs_python_native/cli_argparse.py, cli.py, call_sites.py)
EXIT_CODE: 0
Output Summary:
- Black --check: exit 0, "3 files would be left unchanged." (0 findings).
- Ruff check: exit 0, "All checks passed!" (0 findings).
- Pyright: exit 0, "0 errors, 0 warnings, 0 informations" (0 findings).
