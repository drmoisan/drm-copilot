# Rule-text and mirror tests (issue #886, Phase 1)

Timestamp: 2026-10-12T11-20

Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py

EXIT_CODE: 0

Output Summary: result line `159 passed in 0.60s`; no failed or error count. This includes test_bundled_claude_payload_contains_all_repo_runtime_contracts, which passes with the two byte-identical rule files. The count 159 is the reference for P2-T5.
