# Jest Routing-Merge Parity (P6-T1)

Timestamp: 2026-09-29T17-57
Command: npm run test -- test/lib/push-down/claude-routing-merge-parity.test.ts (working directory: extensions/drm-copilot)
EXIT_CODE: 0

Output Summary:
- Exit code 0.
- `Test Suites: 1 passed, 1 total`
- `Tests:       9 passed, 9 total` (0 failed)
- The suite `issue #507: routing-merge behavioral parity fixture` runs `it.each` over the 9 cases of tests/fixtures/push_down/routing-merge-parity.json: the null-destination case through `RoutingMergeFileSystem` over `buildInMemoryFileSystem()`, five byte-equality cases through `mergeRoutingDocuments`, and three error cases asserting `RoutingMergeError`, message prefix, and `path`.
- The same fixture passes the Python case `tests/scripts/dev_tools/test_push_down_claude_parity.py::test_routing_merge_fixture_parity` (evidence/regression-testing/parity-pass-after.2026-09-29T17-54.md).
- Supporting checks on the new file: `npx eslint test/lib/push-down/claude-routing-merge-parity.test.ts` exit 0; `npx tsc -p tsconfig.jest.json --noEmit` reports 353 `error TS` lines (the baseline count), none in the new file.
- No file under extensions/drm-copilot/src/ changed.
