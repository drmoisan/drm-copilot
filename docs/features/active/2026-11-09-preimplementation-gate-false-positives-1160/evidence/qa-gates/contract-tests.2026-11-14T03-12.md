# Contract Tests (cycle 4, [P3-T5])

Timestamp: 2026-11-14T03-12
Command: sh SCRATCH/issue-1160-c4-contracts.sh p3 (one env -u VIRTUAL_ENV poetry run pytest -n auto -p no:cacheprovider --no-cov run over tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py, tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py, tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py, tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py, tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py, tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py, and tests/scripts/dev_tools/test_execution_environment_brief_contracts.py; then env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check)
EXIT_CODE: 0
Output Summary: pytest: 130 passed, 0 failed, 0 errors, exit 0. Generator --check: exit 0, no output. Both bundle copies of the commands sibling and the three bundle copies of the execution-environment brief match their sources.
