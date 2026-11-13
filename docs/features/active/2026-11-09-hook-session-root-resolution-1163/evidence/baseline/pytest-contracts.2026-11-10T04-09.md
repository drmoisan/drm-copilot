# Pytest Contract Baseline (issue #1163)

Timestamp: 2026-11-10T04-09
Command: env -u VIRTUAL_ENV poetry run pytest -n auto -q -p no:cacheprovider tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py -rf (run from the item worktree root through SCRATCH/issue-1163-pytest.sh)
EXIT_CODE: 0
Output Summary: 198 passed, 0 failed, 0 errors (pytest-xdist, -n auto) in 17.93 s. No Python production file is in scope, so the run carries no coverage arguments.
