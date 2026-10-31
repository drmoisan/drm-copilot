# Contract Baseline (issue #1006)

Timestamp: 2026-10-31T08-06
Task: P0-T10

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: `34 passed in 0.95s`; zero failures.

Command: poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: no output; no generated file is out of date.
