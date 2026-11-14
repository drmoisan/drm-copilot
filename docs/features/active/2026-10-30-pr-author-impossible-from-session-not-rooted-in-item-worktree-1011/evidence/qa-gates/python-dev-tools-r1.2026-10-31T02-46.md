# Python dev_tools Contract Suites (Issue #1011, Remediation Cycle 1, P3-T3)

Timestamp: 2026-10-31T02-46
Command: poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Full run: 8300 passed, 6 skipped, 0 failed (main-plan run python-dev-tools.2026-10-31T01-46.md also recorded zero failures).
- Named contract files, re-run together (`poetry run pytest <the seven files> -q -p no:cacheprovider -rs`): 156 passed, 0 failed, 0 skipped:
  - tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
  - tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
  - tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py
  - tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py
  - tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
  - tests/scripts/dev_tools/test_execution_environment_brief_contracts.py
  - tests/scripts/dev_tools/test_discovery_documentation_contracts.py
