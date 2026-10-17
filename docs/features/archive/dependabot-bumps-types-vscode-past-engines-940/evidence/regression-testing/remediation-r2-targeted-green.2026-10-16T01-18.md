# remediation-r2-targeted-green

Timestamp: 2026-10-16T01-18
Command: poetry run pytest tests/scripts/dev_tools/test_dependabot_config_contract.py -v --no-cov -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- 5 passed in 0.35s. PASSED lines for exactly these node IDs:
  - test_npm_entry_ignores_types_vscode_for_all_update_types[root]
  - test_npm_entry_ignores_types_vscode_for_all_update_types[extension]
  - test_npm_entry_retains_typescript_major_ignore[root]
  - test_npm_entry_retains_typescript_major_ignore[extension]
  - test_exactly_two_target_npm_entries_are_checked
- Pre-edit grep -c -F -e "items[0]" printed 1; post-edit prints 0. Post-edit counts: "no typescript ignore item restricted to" 1; "lacks a typescript ignore" 1.
