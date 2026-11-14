# Push-Down Contract Tests (issue #1006)

Timestamp: 2026-10-31T08-30
Task: P7-T2
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: `34 passed in 0.72s`; zero failures. Every edited `.claude` file has an equal-text bundle copy, every bundled file is in a pack manifest, and the dependency closure holds.
