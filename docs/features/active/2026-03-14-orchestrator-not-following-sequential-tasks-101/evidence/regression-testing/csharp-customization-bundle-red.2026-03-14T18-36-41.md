Timestamp: 2026-03-14T18:36:41-04:00
Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence
EXIT_CODE: 1
Output Summary: EXPECTED RED — the bundled C# customization mirror is out of sync with the root contract files, so parity fails before the missing shared-skill assertion is reached.

Failure Excerpt:
AssertionError: assert mirror_agent_path.read_text(encoding="utf-8") == root_agent

Pytest Summary:
1 failed, 4 deselected in 0.07s
