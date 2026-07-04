# QA Gate — Bundle-Mirror Contract Test (Issue #207, Remediation Pass 1)

Timestamp: 2026-06-19T19-15

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v

EXIT_CODE: 0

Output Summary:
- 4 passed in 0.12s.
- test_bundled_claude_payload_contains_required_runtime_files PASSED
- test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED
- test_bundled_claude_payload_excludes_settings_local_json PASSED
- test_bundled_agent_memory_scopes_are_well_formed PASSED
- The previously failing test now passes. This test enumerates every non-memory
  .claude/** repo file and asserts byte-identical presence in the bundle, confirming
  no OTHER .claude file is out of sync, in addition to the two files synced in Phase 1.
