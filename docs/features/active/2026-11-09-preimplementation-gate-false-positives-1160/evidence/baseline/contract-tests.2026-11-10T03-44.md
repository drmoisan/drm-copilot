# Contract-Test Baseline (P0-T3)

Timestamp: 2026-11-10T03-43
Command: env -u VIRTUAL_ENV poetry run pytest -n auto tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- pytest (one parallel `-n auto` run): 68 passed, 0 failed, in 18.09s.

Timestamp: 2026-11-10T03-44
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary:
- Codex generator check: exit 0, no drift reported.
