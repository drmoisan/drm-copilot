Timestamp: 2026-08-25T16-14
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_push_down_customizations_excludes_ephemeral_codex_state tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_root_and_bundle_payload_contract_excludes_ephemeral_codex_state
EXIT_CODE: 0
Output Summary:
- Collected and passed both named runtime-state exclusion regressions.
- The source customization collector retains `.codex/config.toml` and `.agents/skills/policy-compliance-order/SKILL.md` while excluding `.codex/state/powershell-batch-budget.ephemeral.json`.
- The root/bundle payload contract applies the same publishability rule.
- Result: 2 passed in 0.09s.
