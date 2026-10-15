# Final QC: Python Pyright

Timestamp: 2026-09-30T09-54

Plan task: [P2-T3]

QC_PASS: 3

Command: poetry run pyright scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py scripts/dev_tools/validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py

EXIT_CODE: 0

Output Summary: 0 errors, 0 warnings, 0 informations.

## Output (verbatim, worktree root replaced per rule 2)

```text
venv .venv subdirectory not found in venv path <WORKSPACE_ROOT>.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

## Result

PASS: EXIT_CODE 0 and `0 errors, 0 warnings, 0 informations` present. The `.venv` notice and the version notice are informational and are not diagnostics.
