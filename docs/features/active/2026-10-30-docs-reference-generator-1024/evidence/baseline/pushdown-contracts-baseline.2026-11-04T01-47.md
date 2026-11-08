# Push-Down Contract Tests Baseline (issue 1024)

Timestamp: 2026-11-04T01-47
Task: [P0-T8]
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary: 34 passed, 0 failed (the three test modules run unchanged; `poetry install` was run first because the worktree virtual environment had no pytest). No Python file was edited.
