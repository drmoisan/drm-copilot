# Phase 1 — Fail-First Evidence, node:fs Boundary Path Identity

Timestamp: 2026-08-28T12-47

Task: [P1-T3] [expect-fail]

Command: `npm run test:unit -- test/extension.collect-pr-context.test.ts` (working directory
`extensions/drm-copilot`)

EXIT_CODE: 1

ExpectedExitCode: 1

The recorded exit code is the exit code of the test command itself, captured directly and not
from a pipeline tail. A failing run is the intended outcome of this task and of this task only.

## Output Summary

### The new test

`drm-copilot collectPrContext command behavior › collectPrContext passes workspace-joined paths
to the node:fs write boundary`, added to
`extensions/drm-copilot/test/extension.collect-pr-context.test.ts`.

The suite's workspace fixture is `C:/workspace`, and `writtenFiles` is populated by the `node:fs`
`writeFileSync` mock — the exact boundary `RealFileSystem` calls. The test asserts that the
recorded write arguments are exactly the two workspace-joined artifact paths, and separately
that no recorded write argument is a repository-relative path (every recorded argument begins
with the workspace prefix).

### Recorded write arguments that failed the assertion, verbatim

```
● drm-copilot collectPrContext command behavior › collectPrContext passes workspace-joined paths to the node:fs write boundary

expect(received).toEqual(expected) // deep equality

- Expected  - 2
+ Received  + 2

  Array [
-   "C:/workspace/artifacts/pr_context.appendix.txt",
-   "C:/workspace/artifacts/pr_context.summary.txt",
+   "artifacts/pr_context.appendix.txt",
+   "artifacts/pr_context.summary.txt",
  ]

  at Object.<anonymous> (test/extension.collect-pr-context.test.ts:463:28)
```

The `Received` side lists the two arguments actually handed to `node:fs` `writeFileSync`:
`artifacts/pr_context.appendix.txt` and `artifacts/pr_context.summary.txt`. Both are
repository-relative, so Node resolves them against the calling process's current working
directory rather than against the workspace root the tool was given. That is the defect the
issue reports.

### Counts

```
Test Suites: 1 failed, 1 total
Tests:       1 failed, 9 passed, 10 total
```

The one failure is the new test.
