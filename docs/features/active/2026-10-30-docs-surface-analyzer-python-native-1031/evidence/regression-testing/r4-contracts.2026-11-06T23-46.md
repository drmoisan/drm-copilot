# [P4-T3] Push-down contract tests

Timestamp: 2026-11-06T23-46
Command: poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py; node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts test/packaging/discovery-resources.test.ts in extensions/drm-copilot; branch-current Invoke-PoshQCTest over TESTS/Docs.Manifest.Tests.ps1
EXIT_CODE: 0
Output Summary: Pytest 34 passed, 0 failed, including test_bundled_claude_payload_contains_all_repo_runtime_contracts and test_bundled_claude_files_are_listed_in_some_pack_manifest. Jest 2 suites, 33 tests passed, 0 failed. Pester tests 7, failures 0, errors 0.
