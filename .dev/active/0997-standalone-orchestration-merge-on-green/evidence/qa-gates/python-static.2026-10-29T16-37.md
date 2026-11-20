# Python Static Checks (issue #997)

Timestamp: 2026-10-29T16-37
Command: poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py; poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py; poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
EXIT_CODE: 0
Output Summary:
- black --check: EXIT_CODE 0; output `1 file would be left unchanged.`
- ruff check: EXIT_CODE 0; output `All checks passed!`
- pyright: EXIT_CODE 0; output `0 errors, 0 warnings, 0 informations` (pyright also printed a newer-version notice).
