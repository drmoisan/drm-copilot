# P6-T1 post-NCF1 operand comparison

Timestamp: 2026-10-21T04-55

Command: `WORKSPACE/.venv/Scripts/python.exe -I -S -B SCRATCH/issue-980-p6t1-gateway-configure-ncf1-operands.py SCRATCH/issue-980-p6t1-gateway-configure-factory-2026-10-21T04-51.json`

EXIT_CODE: 0

Output Summary: One installed RegistryLocation contract derivation and exact frozen helper operand comparison; no factory or operation calls.

```json
{
  "actual_components": 13,
  "actual_inside_workspace": false,
  "actual_length": 183,
  "actual_relative_to_resolved_base": "Packages/OpenAI.Codex_2p2nqsd0c76g0/LocalCache/Local/drm-copilot/discovery/workspaces/2116a6d141446602e30b45afb51098744bbde38df691d952267c5de7bd760b99",
  "actual_within_resolved_base": true,
  "base_absolute": true,
  "base_resolves_equal": true,
  "blocked_events": [],
  "calls": {
    "for_host": 1,
    "forbidden_port": 0
  },
  "component_differences": [
    {
      "actual": "Packages",
      "actual_length": 8,
      "component_index": 5,
      "expected": "drm-copilot",
      "expected_length": 11,
      "zone": "fixed-suffix"
    },
    {
      "actual": "OpenAI.Codex_2p2nqsd0c76g0",
      "actual_length": 26,
      "component_index": 6,
      "expected": "discovery",
      "expected_length": 9,
      "zone": "fixed-suffix"
    },
    {
      "actual": "LocalCache",
      "actual_length": 10,
      "component_index": 7,
      "expected": "workspaces",
      "expected_length": 10,
      "zone": "fixed-suffix"
    },
    {
      "actual": "Local",
      "actual_length": 5,
      "component_index": 8,
      "expected": "2116a6d141446602e30b45afb51098744bbde38df691d952267c5de7bd760b99",
      "expected_length": 64,
      "zone": "fixed-suffix"
    },
    {
      "actual": "drm-copilot",
      "actual_length": 11,
      "component_index": 9,
      "expected": null,
      "expected_length": null,
      "zone": "fixed-suffix"
    },
    {
      "actual": "discovery",
      "actual_length": 9,
      "component_index": 10,
      "expected": null,
      "expected_length": null,
      "zone": "fixed-suffix"
    },
    {
      "actual": "workspaces",
      "actual_length": 10,
      "component_index": 11,
      "expected": null,
      "expected_length": null,
      "zone": "fixed-suffix"
    },
    {
      "actual": "2116a6d141446602e30b45afb51098744bbde38df691d952267c5de7bd760b99",
      "actual_length": 64,
      "component_index": 12,
      "expected": null,
      "expected_length": null,
      "zone": "fixed-suffix"
    }
  ],
  "contract_module": "drm_copilot_discovery.activation_filesystem",
  "dont_write_bytecode": true,
  "expected_components": 9,
  "expected_length": 130,
  "factory_calls": 0,
  "fixed_suffix": "drm-copilot/discovery/workspaces/2116a6d141446602e30b45afb51098744bbde38df691d952267c5de7bd760b99",
  "guard_operands_equal": false,
  "isolated": 1,
  "no_site": 1,
  "resolved_base_components": 5,
  "service_imported": false,
  "state_absolute": true,
  "workspace_digest": "2116a6d141446602e30b45afb51098744bbde38df691d952267c5de7bd760b99",
  "workspace_identity_retained": true
}
```

The installed RegistryLocation.for_host derives the layout and identity. Only the frozen helper path expressions are evaluated; no factory, service, Git, test or writer call. Exact host operands are preserved only in the raw stdout member.
