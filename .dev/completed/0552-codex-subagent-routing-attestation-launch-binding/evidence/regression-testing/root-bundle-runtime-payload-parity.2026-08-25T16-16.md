Timestamp: 2026-08-25T16-16
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
EXIT_CODE: 0
Output Summary:
- The complete source-customization and root/bundle runtime-payload parity suites passed.
- Runtime-state exclusion retains the required source customization files and omits `.codex/state/**` from publishable payload enumeration.
- Result: 18 passed in 0.18s.
