# TypeScript Service-Call Fail-Before (#623)

Timestamp: 2026-09-30T08-35
Command: npm --prefix extensions/drm-copilot test -- potential-to-issue-service-call.test
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Jest exit 1 with `Tests:       2 failed, 10 passed, 12 total` against the unchanged promotion.ts. The two failing titles are exactly `throws when the promoted destination is absent` and `throws with the exit code, issue URL, and missing-path line when the workflow move check fails`.

## Jest output (verbatim, ANSI colour codes removed)

```
> drm-copilot@1.1.17 test
> node run-jest.cjs potential-to-issue-service-call.test

FAIL test/lib/potential-to-issue/potential-to-issue-service-call.test.ts
  ● potentialToIssueServiceCall receipt post-condition › throws when the promoted destination is absent

    expect(received).toThrow(expected)

    Expected substring: "potential_to_issue"

    Received function did not throw

      at Object.<anonymous> (test/lib/potential-to-issue/potential-to-issue-service-call.test.ts:361:7)

  ● potentialToIssueServiceCall receipt post-condition › throws with the exit code, issue URL, and missing-path line when the workflow move check fails

    expect(received).toContain(expected) // indexOf

    Expected substring: "Command exited with code 1."
    Received string:    "potential_to_issue reported a path that does not exist: /workspace/docs/features/potential/promoted/sample.md"

      at Object.<anonymous> (test/lib/potential-to-issue/potential-to-issue-service-call.test.ts:430:21)

Test Suites: 1 failed, 1 total
Tests:       2 failed, 10 passed, 12 total
Snapshots:   0 total
Time:        0.416 s, estimated 2 s
Ran all test suites matching potential-to-issue-service-call.test.
```
