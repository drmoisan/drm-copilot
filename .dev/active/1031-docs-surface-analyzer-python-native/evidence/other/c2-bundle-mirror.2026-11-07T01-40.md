# [P1-T3] Mirror contract tests and SHA-256 parity

Timestamp: 2026-11-07T01-40
Command: poetry run python -m pytest on the three contract modules; node run-jest.cjs on the two suites in extensions/drm-copilot/; sha256sum of each LIB and MIRROR pair
EXIT_CODE: 0
Output Summary: Pytest 34 passed, 0 failed; Jest 33 passed, 0 failed; 101 of 101 pairs equal.

## Results

| Run | Passed | Failed |
|---|---|---|
| `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` | 34 | 0 |
| `node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts test/packaging/discovery-resources.test.ts` | 33 | 0 |
| SHA-256 of every file under `LIB` against its `MIRROR` copy | 101 pairs equal | 0 unequal |

The `MIRROR` tree holds 101 files, so no file exists only on one side (S14).
