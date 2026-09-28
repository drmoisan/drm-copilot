# Phase 1 — Fail-First Evidence, Service-Seam Path Identity

Timestamp: 2026-08-28T12-47

Task: [P1-T2] [expect-fail]

Command: `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts` (working
directory `extensions/drm-copilot`)

EXIT_CODE: 1

ExpectedExitCode: 1

The recorded exit code is the exit code of the test command itself, captured directly and not
from a pipeline tail. A failing run is the intended outcome of this task and of this task only.

## Output Summary

### The new test

`collectPrContextServiceCall › writes exactly the paths it reports in result.artifacts`, added to
`extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts`.

It invokes `collectPrContextServiceCall` with the tree-backed in-memory filesystem and the fixed
workspace root `/workspace`, then asserts a **single set equality** between the sorted array of
paths recorded by the `[P1-T1]` `writtenPaths` recorder and the sorted `artifacts` array of the
returned record, and asserts that that one value equals the sorted workspace-joined summary and
appendix pair. It is not two independent literal assertions: the first `expect` compares the two
observed arrays against each other, and the second compares that same single value against the
expected pair.

### Reported difference between the written set and the reported set, verbatim

```
● collectPrContextServiceCall › writes exactly the paths it reports in result.artifacts

expect(received).toEqual(expected) // deep equality

- Expected  - 2
+ Received  + 2

  Array [
-   "/workspace/artifacts/pr_context.appendix.txt",
-   "/workspace/artifacts/pr_context.summary.txt",
+   "artifacts/pr_context.appendix.txt",
+   "artifacts/pr_context.summary.txt",
  ]

  at Object.<anonymous> (test/lib/pr-context/pr-context-service-call.test.ts:137:27)
```

The `Expected` side is the reported `result.artifacts` array, which carries the workspace-joined
pair. The `Received` side is the written set recorded by the filesystem double, which carries the
bare repository-relative pair. The two differ by exactly the missing `/workspace` prefix, which
is the defect under repair: the service call evaluates the output location twice, by two
different expressions, and reports the one it did not write to.

### Counts

```
Test Suites: 1 failed, 1 total
Tests:       1 failed, 3 passed, 4 total
```

The one failure is the new test. The three pre-existing tests in the file still pass at this
point; `[P2-T4]` corrects the two of them that pin the defective behaviour.
