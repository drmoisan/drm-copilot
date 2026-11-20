# #507 Contract Search (P0-T7)

Timestamp: 2026-09-29T18-41
Command: grep -rln --include=*.py "orchestration-routing.json" scripts/dev_tools; grep -rln --include=*.py "orchestration-routing.json" tests/scripts/dev_tools; grep -rln "claude-customizations.ts" tests/scripts/dev_tools
Command actually executed (D-TOOLS): Grep tool, output_mode files_with_matches, with the same pattern, path, and glob (`*.py` for the first two; no glob for the third). Grep returns paths; order below is the tool's order, not selection.
EXIT_CODE: 0
Output Summary:
- Search 1: 10 files (exit 0). Search 2: 19 files (exit 0). Search 3: 2 files (exit 0). No selection made in this task.

## Search 1: `orchestration-routing.json` in scripts/dev_tools (*.py) - exit 0

```
scripts/dev_tools/push_down_claude_destination_writes.py
scripts/dev_tools/push_down_claude_routing_merge.py
scripts/dev_tools/push_down_claude_customizations.py
scripts/dev_tools/compute_complexity_floor.py
scripts/dev_tools/_orchestrator_state_routing.py
scripts/dev_tools/_orchestrator_state_model_routing_gate.py
scripts/dev_tools/resolve_delegation_model.py
scripts/dev_tools/resolve_codex_topology.py
scripts/dev_tools/resolve_codex_deployment.py
scripts/dev_tools/push_down_codex_and_agents_customizations.py
```

## Search 2: `orchestration-routing.json` in tests/scripts/dev_tools (*.py) - exit 0

```
tests/scripts/dev_tools/test_push_down_claude_routing_merge.py
tests/scripts/dev_tools/test_push_down_claude_parity.py
tests/scripts/dev_tools/test_push_down_claude_destination_writes.py
tests/scripts/dev_tools/test_push_down_claude_config_carriage.py
tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core.py
tests/scripts/dev_tools/test_resolve_delegation_model.py
tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py
tests/scripts/dev_tools/test_orchestration_routing_config_parity.py
tests/scripts/dev_tools/test_compute_complexity_floor.py
tests/scripts/dev_tools/test_compute_blast_radius.py
tests/scripts/dev_tools/test_codex_topology_policy_config_parity.py
tests/scripts/dev_tools/test_codex_model_policy_config_parity.py
tests/scripts/dev_tools/test_blast_radius_validation.py
tests/scripts/dev_tools/test_blast_radius_invariants.py
tests/scripts/dev_tools/push_down_customizations_test_support.py
tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
tests/scripts/dev_tools/blast_radius_parity_test_support.py
```

## Search 3: `claude-customizations.ts` in tests/scripts/dev_tools - exit 0

```
tests/scripts/dev_tools/test_push_down_claude_parity.py
tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
```
