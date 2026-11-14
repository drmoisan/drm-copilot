# [P5-T5] Push-down contract tests

Timestamp: 2026-11-04T17-09
Command: sh SCRATCH/issue-1031-pytest.sh issue-1031-p5t5.out tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -v (poetry run pytest --strict-markers --strict-config)
EXIT_CODE: 0
Output Summary: 34 passed, 0 failed, 0 errors. Named cases passing: test_bundled_claude_payload_contains_all_repo_runtime_contracts, test_bundled_claude_files_are_listed_in_some_pack_manifest, test_claude_manifest_powershell_dependency_closure, test_every_psscriptroot_occurrence_is_recognized.

Command: sh SCRATCH/issue-1031-jest.sh issue-1031-p5t5j.out test/lib/push-down/claude-pack-manifest-completeness.test.ts (node run-jest.cjs in extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: Test Suites: 1 passed, 1 total; Tests: 24 passed, 24 total; 0 failed.
