# Phase 0 static baseline: Python (P0-T2)

Timestamp: 2026-11-08T13-54
Command: sh SCRATCH/issue-1130-pystatic.sh (from the worktree root with env -u VIRTUAL_ENV and the main-checkout interpreter: python -m black --check; python -m ruff check; python -m pyright --venvpath <main checkout root>; each on tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py)
EXIT_CODE: 0
Output Summary:
- Black: "1 file would be left unchanged." (exit 0); files whose formatter output differs: none.
- Ruff (no --fix): "All checks passed!" (exit 0); 0 findings.
- Pyright: "0 errors, 0 warnings, 0 informations" (exit 0).
