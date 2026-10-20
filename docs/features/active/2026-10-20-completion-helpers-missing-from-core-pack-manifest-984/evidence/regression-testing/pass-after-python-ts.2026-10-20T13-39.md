# Pass-After Run, Python and Jest (Issue #984)

Timestamp: 2026-10-20T13-39
Command: poetry run pytest tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -v (one process); then in extensions/drm-copilot/: node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts
EXIT_CODE: 0
Output Summary: after the manifest fixes of [P3-T1] and [P3-T2]: Pytest 33 passed, 0 failed (exit 0); Jest 24 passed, 0 failed (exit 0). Every test of the [P1-T6] fail-before set now passes.

| Runner | File | Passed | Failed |
|---|---|---|---|
| Pytest | `test_pack_manifest_dependency_scan.py` | 15 | 0 |
| Pytest | `test_push_down_pack_manifest_dependency_closure.py` | 16 | 0 |
| Pytest | `test_push_down_claude_pack_manifest_completeness.py` | 2 | 0 |
| Jest | `test/lib/push-down/claude-pack-manifest-completeness.test.ts` | 24 | 0 |
