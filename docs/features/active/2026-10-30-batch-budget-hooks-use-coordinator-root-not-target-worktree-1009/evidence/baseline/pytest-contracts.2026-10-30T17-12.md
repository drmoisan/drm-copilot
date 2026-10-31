# Baseline Contract Pytests (CONTRACT-PYTESTS, issue #1009)

Timestamp: 2026-10-30T17-12
Command: poetry run pytest <the eleven CONTRACT-PYTESTS module paths under tests/scripts/dev_tools/> -q -rA -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary: 167 passed, 0 failed in 1.78s.

| Module | Passed | Failed |
|---|---|---|
| test_push_down_claude_resource_contracts.py | 14 | 0 |
| test_push_down_codex_and_agents_resource_contracts.py | 9 | 0 |
| test_push_down_claude_pack_manifest_completeness.py | 2 | 0 |
| test_push_down_codex_and_agents_pack_manifest_completeness.py | 2 | 0 |
| test_push_down_pack_manifest_dependency_closure.py | 18 | 0 |
| test_execution_environment_brief_contracts.py | 19 | 0 |
| test_single_pass_preflight_contracts.py | 12 | 0 |
| test_claude_rules_frontmatter.py | 8 | 0 |
| test_orchestrator_state_required_keys_docs.py | 52 | 0 |
| test_orchestrator_state_remediation_docs.py | 15 | 0 |
| test_parallel_issue_adoption_skill_contracts.py | 16 | 0 |
