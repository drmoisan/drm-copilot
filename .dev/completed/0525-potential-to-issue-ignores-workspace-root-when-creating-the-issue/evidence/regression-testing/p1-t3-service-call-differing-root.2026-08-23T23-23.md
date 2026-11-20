# Fail-Before — Differing Workspace Root ([P1-T3]) [expect-fail]

Timestamp: 2026-08-25T09-33

Command: npm --prefix extensions/drm-copilot run test -- potential-to-issue/potential-to-issue-service-call --testNamePattern "differs from the process working directory"

ExpectedExitCode: 1

EXIT_CODE: 1

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`
Branch: `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
Test file extended by this task: `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts`
Test name: `resolves the target repository from a workspace root that differs from the process working directory`

## Output Summary

The test failed on its first assertion. **The resolver recorded nothing and the echoed field is
absent.** The injected `repoSlugResolver` seam was never invoked, so the recording sink is the empty
array where the supplied workspace root was expected.

Counts reported by the run:

- Test Suites: 1 failed, 1 total
- Tests: 1 failed, 8 skipped, 9 total

The eight pre-existing tests in the file were skipped by the `--testNamePattern` filter, so the
result isolates the one assertion this task added.

### Failing assertion (test file line 227)

```
● potentialToIssueServiceCall — target repository resolution › resolves the target repository from a workspace root that differs from the process working directory

    expect(received).toEqual(expected) // deep equality

    - Expected  - 3
    + Received  + 1

    - Array [
    -   "/other-checkout",
    - ]
    + Array []

      at Object.<anonymous> (test/lib/potential-to-issue/potential-to-issue-service-call.test.ts:227:32)
```

`expect(recordedWorkspaces).toEqual([DIFFERING_WORKSPACE])` received `Array []`: the resolver
recorded no workspace value at all, because `potentialToIssueServiceCall` does not yet read a
`repoSlugResolver` from its input and therefore never called it.

### The echoed field is absent

The second assertion, `expect(result.targetRepository).toBe(RESOLVED_SLUG)`, was not reached because
the first assertion threw. The field is nonetheless absent by construction:
`PotentialToIssueServiceCallResult` in
`extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` declares only
`tool`, `workspaceRoot`, `summary`, `artifacts`, and `destinationPath`, and the returned object
literal populates only those keys. No `targetRepository` key is written on any path. That property is
added by [P3-T4].

## Why This Fail-Before Is Value-Level, Not a Compile Error

Per Settled Design Decision 6, `"isolatedModules": true` in
`extensions/drm-copilot/tsconfig.jest.json` means ts-jest transpiles without type diagnostics. The
unknown `repoSlugResolver` input property and the unknown `result.targetRepository` read produce no
compile error; the test **ran to completion** and failed on a comparison between two values, which
`Tests: 1 failed` (rather than a suite that failed to run) confirms.

This is the finer-grained of the two fail-before signals described in the spec's "Fail-before
demonstrability" section: it observes the propagation break at the service call itself.

## Hermetic Isolation

No `RealGhClient` was constructed and no real `gh` process was spawned:

- A `FakeGhClient` was injected on the `gh` input, so the `input.gh ?? new RealGhClient(...)`
  expression short-circuits and the `RealGhClient` constructor is never evaluated. That constructor
  is the only site that performs a `gh` path lookup on this path.
- The `runner` input received the in-memory `makeRunner([])` stub, which records argument vectors and
  returns `{ stdout: "", stderr: "", code: 0 }` without spawning a child process.
- The filesystem is the in-memory `FakePotentialFileSystem`, so no file was created and no temporary
  file was used, per `.claude/rules/general-unit-test.md`.

## Exit-Code Capture Method

The command's stdout and stderr were redirected to a file and the exit code was echoed in the same
shell invocation immediately afterwards. The command was not piped into another process, so the
recorded status is the status of the test command itself and not of a downstream process.
