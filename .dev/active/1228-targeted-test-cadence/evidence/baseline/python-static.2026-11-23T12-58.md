# Phase 0 Python Static Baseline - Issue #1228 ([P0-T2])

Timestamp: 2026-11-23T12-58
Command: sh SCRATCH/issue-1228-pystatic.sh p0 (from the item worktree root with VIRTUAL_ENV unset: `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright`; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`)
EXIT_CODE: 0
Output Summary:
- Black check: EXIT_CODE 0; 0 files would be reformatted, 1071 files would be left unchanged (finding count 0).
- Ruff: EXIT_CODE 0; "All checks passed!" (finding count 0).
- Pyright: EXIT_CODE 0; "0 errors, 0 warnings, 0 informations" (finding count 0).
- Codex generator `--check`: EXIT_CODE 0; no drift reported (finding count 0).

Run window: 2026-11-23T12-57 to 2026-11-23T12-58 (UTC). Worktree venv used (`.venv` of the item worktree).
