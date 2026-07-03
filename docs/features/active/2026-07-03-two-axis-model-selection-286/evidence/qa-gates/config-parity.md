# Config Parity — model_policy / model_budget

Timestamp: 2026-07-03T16-43

Command: `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`
EXIT_CODE: 0

Output Summary: 1 passed. `test_canonical_and_bundled_routing_config_are_byte_identical` confirms `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json` are byte-identical after the additive `model_policy` and `model_budget` blocks were added.
