# Phase 2 — Pass-After Evidence for Both Fail-First Tests

Timestamp: 2026-08-28T12-47

Task: [P2-T5]

Command: `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts test/extension.collect-pr-context.test.ts` (working directory `extensions/drm-copilot`)

EXIT_CODE: 0

The recorded exit code is the exit code of the test command itself, captured directly and not
from a pipeline tail.

## Output Summary

### The two tests added in [P1-T2] and [P1-T3], now passing

1. `collectPrContextServiceCall › writes exactly the paths it reports in result.artifacts`
   (added by `[P1-T2]`, in
   `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts`). It failed at
   `[P1-T2]` with the written set carrying the bare relative pair against a reported set carrying
   the workspace-joined pair. It now passes: the single set equality holds, and that one value is
   the workspace-joined pair.

2. `drm-copilot collectPrContext command behavior › collectPrContext passes workspace-joined
   paths to the node:fs write boundary` (added by `[P1-T3]`, in
   `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`). It failed at `[P1-T3]`
   with `node:fs` `writeFileSync` recording the two repository-relative arguments. It now passes:
   both recorded arguments are the workspace-joined paths and none is repository-relative.

### Counts for the two files

```
Test Suites: 2 passed, 2 total
Tests:       14 passed, 14 total
```

- `test/lib/pr-context/pr-context-service-call.test.ts`: 4 passed, 0 failed.
- `test/extension.collect-pr-context.test.ts`: 10 passed, 0 failed.
- Combined: **14 passed, 0 failed**.

### Micro-actions taken inside this task to reach exit 0

Two corrections in `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` were
mechanically necessary and neither removes an assertion.

1. **The `node:fs` double now serves reads consistently with its writes.** Its `readFileSync`
   mock previously threw `ENOENT` unconditionally while `writeFileSync` recorded into
   `writtenFiles`. The read-back verification added by `[P2-T3]` reads each artifact back through
   the same filesystem, so that double reported a false verification failure on seven positive-path
   tests. This is precisely the risk the spec's Risks section names — "read-back verification
   produces a false failure on a filesystem that does not return the bytes just written, for
   example a filesystem double in a test that records writes but does not serve reads" — and the
   correction is precisely the mitigation the spec states for it: "every test double used in a
   positive-path test serves reads consistently with its writes". The mock now returns the
   recorded content when the path was written and throws `ENOENT` otherwise, so its negative
   behaviour for unwritten paths is unchanged.

2. **Assertions naming a repository-relative artifact path now name the workspace-joined path.**
   Five assertions in that file were superseded by the `[P2-T1]` correction: two `has` checks, two
   summary-content `get` lookups, one sorted key-set equality, and the two log-line substrings.
   Each was retargeted to the same observation against the workspace-joined path through the two
   named constants `WORKSPACE_SUMMARY_PATH` and `WORKSPACE_APPENDIX_PATH`. No assertion was
   deleted, and each still checks what it checked before.
