# Fail-Before — Matching Workspace Root ([P1-T4]) [expect-fail]

Timestamp: 2026-08-25T09-33

Command: npm --prefix extensions/drm-copilot run test -- potential-to-issue/potential-to-issue-service-call --testNamePattern "matches the process working directory"

ExpectedExitCode: 1

EXIT_CODE: 1

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`
Branch: `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
Test file extended by this task: `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts`
Test name: `resolves the target repository when the workspace root matches the process working directory`

## Output Summary

The test failed on its first assertion,
`expect(recordedWorkspaces).toEqual([PROCESS_ROOT])` at test file line 268. **The injected
`repoSlugResolver` seam was never invoked**, so the recording sink is the empty array where the
process working directory was expected.

Counts reported by the run:

- Test Suites: 1 failed, 1 total
- Tests: 1 failed, 9 skipped, 10 total

The nine other tests in the file (the eight pre-existing tests plus the [P1-T3] test) were skipped by
the `--testNamePattern` filter, so the result isolates the one assertion this task added.

### Failing assertion (test file line 268)

```
● potentialToIssueServiceCall — target repository resolution › resolves the target repository when the workspace root matches the process working directory

    expect(received).toEqual(expected) // deep equality

    - Expected  - 3
    + Received  + 1

    - Array [
    -   "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a38eff9588c69b6ec/extensions/drm-copilot",
    - ]
    + Array []

      at Object.<anonymous> (test/lib/potential-to-issue/potential-to-issue-service-call.test.ts:268:32)
```

The expected element is the Jest process working directory with separators normalized to forward
slashes, which is the value the test supplied as `workspaceRoot`. The received value is `Array []`,
because `potentialToIssueServiceCall` does not yet read a `repoSlugResolver` from its input and
therefore never called it.

### Assertions not reached

The first assertion threw, so the remaining four in the test did not execute:

1. `expect(result.targetRepository).toBe(RESOLVED_SLUG)` — the field is absent by construction;
   `PotentialToIssueServiceCallResult` declares no `targetRepository` property and the returned
   object literal never writes that key. It is added by [P3-T4].
2. `expect(result.summary).toBe(...)` — the pre-existing summary assertion, expected value unchanged
   in form.
3. `expect(result.destinationPath).toBe(...)` — the pre-existing destination assertion, expected
   value unchanged in form.
4. `expect(result.artifacts).toEqual(["https://example.com/issues/123"])` — the pre-existing
   artifacts assertion, expected value unchanged.

Assertions 2 through 4 exist to pin requirement R3 (the same-repository case must be unchanged).
They are expressed against the same workspace-derived constant used for the call, so no expected
value asserted by any pre-existing test was modified to accommodate them.

## Why This Fail-Before Is Value-Level, Not a Compile Error

Per Settled Design Decision 6, `"isolatedModules": true` in
`extensions/drm-copilot/tsconfig.jest.json` means ts-jest transpiles without type diagnostics. The
unknown `repoSlugResolver` input property and the unknown `result.targetRepository` read produce no
compile error; the test **ran to completion** and failed on a comparison between two values, which
`Tests: 1 failed` (rather than a suite that failed to run) confirms.

## Hermetic Isolation

No `RealGhClient` was constructed and no real `gh` process was spawned:

- A `FakeGhClient` was injected on the `gh` input, so the `input.gh ?? new RealGhClient(...)`
  expression short-circuits and the `RealGhClient` constructor — the only `gh` path lookup on this
  path — is never evaluated.
- The `runner` input received the in-memory `makeRunner([])` stub, which records argument vectors and
  returns `{ stdout: "", stderr: "", code: 0 }` without spawning a child process.
- The filesystem is the in-memory `FakePotentialFileSystem`, so no file was created and no temporary
  file was used, per `.claude/rules/general-unit-test.md`.

Reading `process.cwd()` is part of the scenario under test, not an external dependency: the test
asserts behaviour for the case where the supplied workspace root equals the process working
directory. Every expected value in the test is derived from that single constant, so the assertions
are self-consistent on any host.

## Exit-Code Capture Method

The command's stdout and stderr were redirected to a file and the exit code was echoed in the same
shell invocation immediately afterwards. The command was not piped into another process, so the
recorded status is the status of the test command itself and not of a downstream process.
