# Baseline Python Type Check (Issue #849)

Timestamp: 2026-10-10T09-51
Task: P0-T7
Command: poetry run pyright scripts/dev_tools/_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py
EXIT_CODE: 0

## Output (verbatim, worktree path replaced by "worktree root")

```text
venv .venv subdirectory not found in venv path worktree root.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

The first line is a Pyright configuration notice: the worktree has no `.venv` subdirectory, so Pyright resolved the interpreter through the Poetry environment instead. The version notice is informational.

Output Summary: "0 errors, 0 warnings, 0 informations" for the three files at baseline.
