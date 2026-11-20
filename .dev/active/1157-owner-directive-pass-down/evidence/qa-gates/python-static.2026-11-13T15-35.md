# Python final-QC static checks (issue #1157, cycle 1, P2-T2)

Timestamp: 2026-11-13T15-35
Command: sh SCRATCH/issue-1157-pystatic.sh tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py (in the item worktree with VIRTUAL_ENV unset: poetry run black --check <file>; poetry run ruff check <file>; poetry run pyright <file>)
EXIT_CODE: 0
Output Summary:
- File: tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py, the one Python file in the branch diff from the merge base.
- Black --check: "1 file would be left unchanged." (EXIT_CODE 0).
- Ruff: "All checks passed!" (EXIT_CODE 0).
- Pyright: "0 errors, 0 warnings, 0 informations" (EXIT_CODE 0).
