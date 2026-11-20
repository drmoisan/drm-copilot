# Python Static Baseline (Phase 0, [P0-T1])

Timestamp: 2026-11-08T18-39
Command: env -u VIRTUAL_ENV poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py; env -u VIRTUAL_ENV poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py; env -u VIRTUAL_ENV poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
EXIT_CODE: 0
Output Summary: Black: "1 file would be left unchanged." (exit 0, 0 files to reformat). Ruff: "All checks passed!" (exit 0, 0 findings). Pyright: "0 errors, 0 warnings, 0 informations" (exit 0). The worktree environment was prepared first with `env -u VIRTUAL_ENV poetry install` (exit 0, "No dependencies to install or update"), a micro-action needed to run the three tools; [P0-T3] records it again.

## Steps

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format (check) | `env -u VIRTUAL_ENV poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 0 | 0 files would be reformatted |
| Lint | `env -u VIRTUAL_ENV poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 0 | 0 |
| Type check | `env -u VIRTUAL_ENV poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 0 | 0 errors, 0 warnings |
