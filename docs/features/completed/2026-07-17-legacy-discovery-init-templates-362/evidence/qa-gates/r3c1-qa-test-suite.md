# QA Gate: Test Suite with Coverage (Specific Scope) — r3c1-qa-test-suite.md

Timestamp: 2026-07-18T18-40

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v --cov=scripts/dev_tools --cov-branch --cov-report=term-missing

EXIT_CODE: 0

## Output Summary

All 7 tests in the specific scope PASSED (100%). The previously-failing test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` now PASSES.

Coverage for scripts/dev_tools:
- Line coverage: 2% (expected; only the test file imports and uses scripts/dev_tools)
- Branch coverage: 10% (expected; only the test file imports and uses scripts/dev_tools)
- Total statements analyzed: 11616
- Statements covered: 265 (2%)

## Test Results

```
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files PASSED [ 14%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED [ 28%] [KEY TEST - NOW PASSING]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_pack_manifests_are_outside_the_parity_scope PASSED [ 42%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_excludes_settings_local_json PASSED [ 57%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_excludes_variant_subtree_from_parity PASSED [ 71%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_variant_subtree_is_bundle_only_and_non_colliding PASSED [ 85%]
tests/scripts/dev_tools/test_bundled_agent_memory_scopes_are_well_formed PASSED [100%]

============================== 7 passed in 3.09s ==============================
```

## Status

The critical test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is now passing, confirming that all four missing agent files have been successfully added to the bundled extension payload and are byte-identical to the source files.
