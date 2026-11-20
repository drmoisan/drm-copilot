# TypeScript regression, pass-after (Issue #500)

Timestamp: 2026-08-22T00:14:00Z
Issue: #500
Task: [P7-T4]

Pairs with the fail-before artifact
`evidence/regression-testing/typescript-regression-fail-before.2026-08-21T23-10.md`.

Command:

```
npm run test:unit
```

(working directory: `extensions/drm-copilot`; byte-identical to the fail-before command)

EXIT_CODE: 0
ExpectedExitCode: 0

Output Summary:

```
Test Suites: 195 passed, 195 total
Tests:       2656 passed, 2656 total
Snapshots:   0 total
```

Zero failures. The fail-before run recorded exit code 1 with 1 failed suite and 1 failed test.

## The published-document assertion named

Suite: `issue #462 AC8: the published blast-radius default is generic`
Test: `publishes no claude-runtime module into a layout-free destination`
Source: `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`

| Run | Result | Detail |
| --- | --- | --- |
| Fail-before | FAILED | `Expected value: not "claude-runtime"` / `Received array: ["claude-runtime", "config"]` |
| Pass-after | PASSED | The published `modules` key set no longer contains `claude-runtime`. |

The published document is now derived from `PAYLOAD_MODULES = { config: ["config/**"] }` unioned
with the destination's own observed layout, so a layout-free destination receives the key set
`["config"]`.

Test count moved from the Phase 0 baseline of 2654 to 2656: the [P1-T4] published-document assertion
and the [P2-T6] payload-module negative assertion.
