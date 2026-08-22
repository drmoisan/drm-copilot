# TypeScript regression, fail-before (Issue #500)

Timestamp: 2026-08-21T23:10:11Z
Issue: #500
Tasks: [P1-T4], [P1-T5] — tagged `[expect-fail]`; a failing test is the expected outcome for these
tasks only.

Command:
```
npm run test:unit
```
(working directory: `extensions/drm-copilot`)

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- Test Suites: 1 failed, 194 passed, 195 total
- Tests: **1 failed**, 2654 passed, 2655 total
- The observed exit code equals the declared `ExpectedExitCode`.

## Failing test

Suite: `issue #462 AC8: the published blast-radius default is generic`
Test: `publishes no claude-runtime module into a layout-free destination`
Location: `test/lib/push-down/claude-config-carriage.test.ts:314`

Failure message:
```
Expected value: not "claude-runtime"
Received array:     ["claude-runtime", "config"]
```

The test publishes into a destination whose injected lister reports no entry at any path, so the
scan contributes nothing and the assembled module map is exactly `PAYLOAD_MODULES`. The published
`config/blast-radius.json` therefore carries the key set `["claude-runtime", "config"]`, proving
that `PAYLOAD_MODULES` in
`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` is the live source of
the `claude-runtime` umbrella in every published document. This is the TypeScript half of the
fail-closed direction and corresponds to research `## 4.5` item 10.

The remaining 2654 tests pass, so the failure is attributable to the newly added assertion and not
to a pre-existing red suite: the Phase 0 baseline recorded 195 of 195 suites and 2654 of 2654 tests
passing.
