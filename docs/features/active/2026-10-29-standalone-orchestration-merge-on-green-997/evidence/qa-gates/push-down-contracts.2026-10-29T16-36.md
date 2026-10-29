# Push-Down Contract Tests (issue #997)

Timestamp: 2026-10-29T16-36
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: 34 passed, 0 failed. The new hook's bundle copy, its core.json entry, and the dependency closure of the edited gate are accepted.
