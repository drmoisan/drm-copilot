# Python Static Baseline (issue #1141, [P0-T1])

Timestamp: 2026-11-08T19-08
Command: env -u VIRTUAL_ENV poetry install; env -u VIRTUAL_ENV poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py; env -u VIRTUAL_ENV poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py; env -u VIRTUAL_ENV poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
EXIT_CODE: 0
Output Summary:
- poetry install (worktree root, VIRTUAL_ENV unset): EXIT_CODE 0; "No dependencies to install or update"; project installed in the worktree .venv.
- Black --check: EXIT_CODE 0; findings 0 ("1 file would be left unchanged.").
- Ruff check: EXIT_CODE 0; findings 0 ("All checks passed!").
- Pyright: EXIT_CODE 0; findings 0 ("0 errors, 0 warnings, 0 informations").

## Steps

| Step | Command | EXIT_CODE | Finding count |
| --- | --- | --- | --- |
| install | env -u VIRTUAL_ENV poetry install | 0 | n/a |
| format | env -u VIRTUAL_ENV poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py | 0 | 0 |
| lint | env -u VIRTUAL_ENV poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py | 0 | 0 |
| type check | env -u VIRTUAL_ENV poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py | 0 | 0 |
