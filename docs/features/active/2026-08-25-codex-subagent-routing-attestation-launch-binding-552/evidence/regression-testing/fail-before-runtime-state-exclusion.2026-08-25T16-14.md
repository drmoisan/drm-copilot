Timestamp: 2026-08-25T16-14
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_push_down_customizations_excludes_ephemeral_codex_state tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_root_and_bundle_payload_contract_excludes_ephemeral_codex_state
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Collected 2 named runtime-state exclusion regressions.
- `test_push_down_customizations_excludes_ephemeral_codex_state` failed because `.codex/state/powershell-batch-budget.ephemeral.json` remained in the published paths.
- `.codex/config.toml` and `.agents/skills/policy-compliance-order/SKILL.md` remained selected as required source customization paths.
- `test_root_and_bundle_payload_contract_excludes_ephemeral_codex_state` passed because the current root and bundle have no runtime-state file to compare.
- Result: 1 failed, 1 passed in 0.13s; the only observed failure is the intended state-file publication defect.
