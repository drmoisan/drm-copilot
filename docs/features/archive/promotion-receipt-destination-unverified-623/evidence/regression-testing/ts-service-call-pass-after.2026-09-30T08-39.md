# TypeScript Service-Call Pass-After (#623)

Timestamp: 2026-09-30T08-39
Command: npm --prefix extensions/drm-copilot test -- potential-to-issue-service-call.test
EXIT_CODE: 0
Output Summary: `Tests:       12 passed, 12 total`. The passing tests include `throws when the promoted destination is absent`, `returns the enriched record when the destination exists`, and `throws with the exit code, issue URL, and missing-path line when the workflow move check fails`.

## Jest output (verbatim)

```
> drm-copilot@1.1.17 test
> node run-jest.cjs potential-to-issue-service-call.test

Test Suites: 1 passed, 1 total
Tests:       12 passed, 12 total
Snapshots:   0 total
Time:        0.254 s, estimated 1 s
Ran all test suites matching potential-to-issue-service-call.test.
```

## Named passing tests

The default Jest reporter in this environment prints only the summary block, so per-test titles were read from a supplementary run of the same selection with `--json` added (full listing in ts-promotion-suites-pass-after.2026-09-30T08-39.md). Receipt post-condition entries:

- passed :: potentialToIssueServiceCall receipt post-condition throws when the promoted destination is absent
- passed :: potentialToIssueServiceCall receipt post-condition returns the enriched record when the destination exists
- passed :: potentialToIssueServiceCall receipt post-condition throws with the exit code, issue URL, and missing-path line when the workflow move check fails

Note: an earlier run of this command carried an extra `--verbose` flag by operator error; it also reported `Tests:       12 passed, 12 total`. The run recorded above is the command as written in the plan.
