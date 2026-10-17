# Python Type-Check Baseline (P0-T18)

Timestamp: 2026-10-13T00-11
Command: poetry run pyright tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py scripts/dev_tools/_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py tests/scripts/dev_tools/test_check_quality_tiers.py
EXIT_CODE: 0
BASE: fd81a43b45de65078236da6c1cbfd077c3eb010c

Output:
```
venv .venv subdirectory not found in venv path <worktree>.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

Output Summary: PASS. `0 errors, 0 warnings, 0 informations`. The venv-path notice and the pyright version notice are informational and do not affect the result.
