# Split Files — Pyright

Timestamp: 2026-09-30T14-14
Task: P1-T12
Working directory: worktree root

Command: poetry run pyright scripts/dev_tools/_orchestrator_state_routing.py scripts/dev_tools/_orchestrator_state_route_gates.py scripts/dev_tools/_orchestrator_state_promotion_tools.py tests/scripts/dev_tools/test_orchestrator_state_routing_split.py
EXIT_CODE: 0
Output Summary:
- Summary line: `0 errors, 0 warnings, 0 informations`
- Informational lines also printed: `venv .venv subdirectory not found in venv path` (environment notice) and a pyright version-update notice; neither is a diagnostic.
- No fix was required by this step, so no restart at P1-T10 was triggered by Pyright.

Result: PASS
