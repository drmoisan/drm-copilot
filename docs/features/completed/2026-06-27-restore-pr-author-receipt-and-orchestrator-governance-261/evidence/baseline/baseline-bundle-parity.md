# Baseline — Bundle Parity (pytest)

Timestamp: 2026-06-27T23-40

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q

EXIT_CODE: 0

Output Summary: 9 passed in 0.13s. Both bundle-parity contract suites pass at baseline. The .claude byte-identical mirror contract and the .codex/.agents contract are green before any edits. Runtime hook, claude mirror, and codex mirror are in their pre-change state.
