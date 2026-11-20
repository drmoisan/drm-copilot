# Phase 5 — Read-Back Mutation Check, Verification Removed

Timestamp: 2026-08-28T12-47

Task: [P5-T1]

Command: `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts` (working
directory `extensions/drm-copilot`)

EXIT_CODE: 1

ExpectedExitCode: 1

The recorded exit code is the exit code of the test command itself, captured directly and not
from a pipeline tail.

## What was mutated

The two read-back verification calls added by `[P2-T3]` were temporarily removed from
`extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`, leaving the rendered-text
return value unused. Nothing else was changed. The purpose of this run is to prove that the
verification is what makes the negative tests pass — that is, that it is a genuine read-back
comparison and not an existence check that a stale file would satisfy.

## Output Summary

### Tests that failed while the verification was absent

```
● collectPrContextServiceCall › raises when the write is accepted and the content is discarded
● collectPrContextServiceCall › raises when a stale file is present and the write is discarded
● collectPrContextServiceCall › raises naming the appendix when the summary write succeeds and the appendix write fails
```

All **three** negative tests added by `[P5-T1]` failed with the verification removed. The plan
requires the first two to fail; the third failed as well, which is a stronger result than the
requirement.

The second of the three is the decisive one. In that scenario both target paths already hold a
prior invocation's content, so an existence-only check passes: the test asserts `isFile` is true
for both paths before invoking the call. With the verification removed the call returns
successfully against those stale files, which is precisely the defect the issue reports. With the
verification in place the call raises.

### Counts

```
Test Suites: 1 failed, 1 total
Tests:       3 failed, 5 passed, 8 total
```

The five that still passed are the positive-path tests, which do not depend on the verification
raising.
