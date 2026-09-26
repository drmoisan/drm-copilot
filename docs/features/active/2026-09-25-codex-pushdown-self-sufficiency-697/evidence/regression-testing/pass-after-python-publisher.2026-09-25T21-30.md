# Pass-After: Python Publisher Virtual Pairs (Issue #697, AC-4.1, AC-4.2, AC-4.4, AC-4.5)

Timestamp: 2026-09-25T21-30
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_variant_packs.py -q
EXIT_CODE: 0
Output Summary: `28 passed` (0 failed). The six new virtual-path tests pass; `test_push_down_customizations_copies_codex_and_agents_paths` keeps its four-path list because no module resource is seeded there.
