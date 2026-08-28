# Phase 5 — Read-Back Mutation Check, Verification Restored

Timestamp: 2026-08-28T12-47

Task: [P5-T1]

Command: `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts` (working
directory `extensions/drm-copilot`)

EXIT_CODE: 0

The recorded exit code is the exit code of the test command itself, captured directly and not
from a pipeline tail.

This run is recorded in its own artifact rather than alongside the removed-verification run
because a single evidence artifact carries exactly one `ExpectedExitCode` value, and the two runs
declare different expectations. This one declares the default of 0 by omitting the field.

## Output Summary

```
Test Suites: 1 passed, 1 total
Tests:       8 passed, 8 total
```

- Passed: **8**
- Failed: **0**

The two read-back verification calls were restored exactly as `[P2-T3]` left them. The
restoration is exact rather than merely equivalent, and this is verified rather than asserted:
`git status --porcelain extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`
reports empty output with exit code 0, so the production file is byte-identical to its committed
state at the end of Phase 2. The mutation left no residue.

The three negative tests that failed while the verification was absent all pass with it restored,
which together with the removed-verification run establishes that the verification is the cause
of the pass and not an incidental property of the test doubles.
