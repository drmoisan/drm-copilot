# Import Direction and Harvester Location

Timestamp: 2026-09-30T14-14
Task: P1-T8
Working directory: worktree root
Note: recorded after the final clean P1-T10 to P1-T12 loop pass.

## Command 1 — positive control

Command: grep -c -F -e "def load_routing_matrix" scripts/dev_tools/_orchestrator_state_route_gates.py
EXIT_CODE: 0
Output Summary: `1` (the path resolves and the moved definition is present).

## Command 2 — no back-reference to the routing module

Command: grep -c -F -e "_orchestrator_state_routing" scripts/dev_tools/_orchestrator_state_route_gates.py scripts/dev_tools/_orchestrator_state_promotion_tools.py
EXIT_CODE: 1
Output Summary:
- `scripts/dev_tools/_orchestrator_state_route_gates.py:0`
- `scripts/dev_tools/_orchestrator_state_promotion_tools.py:0`

## Command 3 — harvesters defined in the routing module

Command: grep -c -E -e "^def (_receipt_agents|_receipt_skills|_mcp_tools)\(" scripts/dev_tools/_orchestrator_state_routing.py
EXIT_CODE: 0
Output Summary: `3`.

Result: PASS
