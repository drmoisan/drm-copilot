Timestamp: 2026-08-25T16-16
Command: poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_resolve_codex_deployment.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py --cov=scripts.dev_tools.resolve_codex_deployment --cov=scripts.dev_tools.generate_codex_agent_variants --cov=scripts.dev_tools.push_down_codex_filesystem --cov-branch --cov-report=term-missing
EXIT_CODE: 1
Output Summary:
- Result: 56 passed, 1 failed in 0.66s.
- The sole failure is `test_routed_delegation_launch_binding`, which requires the later P2-T7/P2-T8 normal routed-delegation contract in `.codex/agents/orchestrator.toml`; those tasks are outside Batch A and remain unchecked.
- All Batch A runtime-state publication and root/bundle payload tests passed.
- Coverage: `push_down_codex_filesystem.py` 93%; `resolve_codex_deployment.py` 100%; `generate_codex_agent_variants.py` 89%; total 93%.
- The command did not report any required bundle payload entry under `.codex/state/`.
