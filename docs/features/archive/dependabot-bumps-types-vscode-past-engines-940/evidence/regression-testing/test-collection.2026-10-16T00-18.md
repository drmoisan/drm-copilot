# Test collection (P1-T2)

Timestamp: 2026-10-16T00-18
Command: poetry run pytest tests/scripts/dev_tools/test_dependabot_config_contract.py --collect-only -q --no-cov
EXIT_CODE: 0
Output Summary: Five node IDs listed, footer `5 tests collected in 0.15s`:
- test_npm_entry_ignores_types_vscode_for_all_update_types[root]
- test_npm_entry_ignores_types_vscode_for_all_update_types[extension]
- test_npm_entry_retains_typescript_major_ignore[root]
- test_npm_entry_retains_typescript_major_ignore[extension]
- test_exactly_two_target_npm_entries_are_checked
Note: `--no-cov` was added to the plan command to suppress coverage plugin output during collection only.
