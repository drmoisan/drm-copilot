# Targeted pytest after remediation edits (P1-T3)

Timestamp: 2026-10-16T00-52
Command: poetry run pytest tests/scripts/dev_tools/test_dependabot_config_contract.py -v --no-cov -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Final pytest line: `5 passed in 0.22s`.
- PASSED node IDs (all in tests/scripts/dev_tools/test_dependabot_config_contract.py):
  - test_npm_entry_ignores_types_vscode_for_all_update_types[root]
  - test_npm_entry_ignores_types_vscode_for_all_update_types[extension]
  - test_npm_entry_retains_typescript_major_ignore[root]
  - test_npm_entry_retains_typescript_major_ignore[extension]
  - test_exactly_two_target_npm_entries_are_checked
- Token counts (P1-T1, P1-T2): `@functools.cache` 1, `import functools` 1, `no unrestricted ignore item for` 1, `not in items[0]` 0, `lacks an ignore item for` 1.
