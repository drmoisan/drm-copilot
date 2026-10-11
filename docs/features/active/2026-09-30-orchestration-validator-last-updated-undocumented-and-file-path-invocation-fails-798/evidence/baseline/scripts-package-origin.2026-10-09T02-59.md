# P0-T6 Scripts Package Origin Classification

Timestamp: 2026-10-09T02-59
Command: poetry run python -I -c "import importlib.util; s = importlib.util.find_spec('scripts'); print('SCRIPTS_ORIGIN', None if s is None else s.origin)"
EXIT_CODE: 0
Output Summary:
- One line beginning `SCRIPTS_ORIGIN` printed (exit 0). Printed path not recorded per plan.
- Classification: FOREIGN (the value names `scripts/__init__.py` in a different agent worktree of this repository, supplied by the shared environment's editable-install entry).
- Informational: the same probe with `-S` added prints `SCRIPTS_ORIGIN None` (exit 0), confirming `-S` removes the foreign route.
- OPERATOR_OVERRIDE: the `-S` override was not applied to the recorded command, because this task classifies how site-packages resolves `scripts`; `-S` would remove the route under observation. The `-S` variant is recorded above as supplementary data.
- FOREIGN is the residual hazard recorded in PD8; it does not stop the plan.
