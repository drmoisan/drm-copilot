# Contract Tests ([P3-T5])

Timestamp: 2026-11-13T19-08
Command: sh SCRATCH/issue-1160-r4-contract.sh (env -u VIRTUAL_ENV poetry run pytest -n auto -q --no-cov tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py; then env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check)
EXIT_CODE: 0
Output Summary: one pytest -n auto run: `130 passed`, 0 failed (exit 0). Generator `--check`: exit 0, no output. Run on head `38ac34e95a5d330c25effc19292ee642c35e7547`.
