# Fail-Before — Argument-Boundary Selector Tests ([P1-T2]) [expect-fail]

Timestamp: 2026-08-25T09-33

Command: npm --prefix extensions/drm-copilot run test -- potential-to-issue/gh-client

ExpectedExitCode: 1

EXIT_CODE: 1

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`
Branch: `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
Test file extended by this task: `extensions/drm-copilot/test/lib/potential-to-issue/gh-client.test.ts`
Tests added: `binds the repo selector into the issue create vector`,
`binds the repo selector into the label create vector`,
`binds the repo selector into the issue view vector`

## Output Summary

All three new tests failed on the **exact-vector comparison** (`expect(calls[0]?.args).toEqual(...)`).
In each case the recorded vector **carries no repository selector**: the received array is the
pre-change vector, and the two elements `"--repo"` and `"drmoisan/drm-copilot"` are missing from it.
Jest reports the same diff shape for all three: `- Expected - 2` / `+ Received + 0`.

Counts reported by the run:

- Test Suites: 1 failed, 1 total
- Tests: 3 failed, 12 passed, 15 total

The 12 pre-existing tests in the file passed unchanged, so the failure is confined to the three
assertions this task added.

### Failing assertion 1 — issue create vector (test file line 207)

```
● RealGhClient — repository selector binding › binds the repo selector into the issue create vector

    expect(received).toEqual(expected) // deep equality

      Array [
        "issue",
        "create",
    -   "--repo",
    -   "drmoisan/drm-copilot",
        "--title",
        "My Title",
        "--body-file",
        "-",
        "--label",
```

### Failing assertion 2 — label create vector (test file line 234)

```
● RealGhClient — repository selector binding › binds the repo selector into the label create vector

      Array [
        "label",
        "create",
    -   "--repo",
    -   "drmoisan/drm-copilot",
        "feature",
        "--color",
        "0e8a16",
        "--description",
        "Feature work",
```

### Failing assertion 3 — issue view vector (test file line 260)

```
● RealGhClient — repository selector binding › binds the repo selector into the issue view vector

      Array [
        "issue",
        "view",
    -   "--repo",
    -   "drmoisan/drm-copilot",
        "123",
        "--json",
        "number,title,url,author,updatedAt",
      ]
```

## Why This Fail-Before Is Value-Level, Not a Compile Error

Per Settled Design Decision 6, `extensions/drm-copilot/tsconfig.jest.json` sets
`"isolatedModules": true`, so ts-jest transpiles each test module without emitting type diagnostics.
The `repo` option passed to the `RealGhClient` constructor is not yet declared on its options type,
but that produces no diagnostic under this configuration: the property is simply ignored at runtime.
Each test therefore **ran to completion** and failed on the value comparison, which is confirmed by
`Tests: 3 failed, 12 passed, 15 total` — a compile failure would have reported a suite that failed
to run with `0 total` tests, as [P1-T1] did.

This is the coarser of the two fail-before signals described in the spec's "Fail-before
demonstrability" section: it observes the omitted selector at the exact argument boundary where the
defect lives.

## Exit-Code Capture Method

The command's stdout and stderr were redirected to a file and the exit code was echoed in the same
shell invocation immediately afterwards. The command was not piped into another process, so the
recorded status is the status of the test command itself and not of a downstream process.
