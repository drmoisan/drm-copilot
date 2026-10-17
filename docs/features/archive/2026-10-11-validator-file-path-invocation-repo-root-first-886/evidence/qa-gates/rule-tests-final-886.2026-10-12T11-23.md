# Final rule-text and mirror tests (issue #886)

Timestamp: 2026-10-12T11-23

Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py

EXIT_CODE: 0

Output Summary: result line `159 passed in 0.60s`; no failed or error count; equals the P1-T18 count of 159. PowerShell and bats parity checks are covered by CI evidence only (no shell wrapper used).
