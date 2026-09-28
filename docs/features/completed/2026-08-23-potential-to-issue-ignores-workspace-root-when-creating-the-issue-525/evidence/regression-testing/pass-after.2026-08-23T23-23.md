# Pass-After Evidence ([P6-T7])

Timestamp: 2026-08-25T10-14
Command: npm --prefix extensions/drm-copilot run test -- potential-to-issue
EXIT_CODE: 0

Counterpart to the fail-before evidence in
`evidence/regression-testing/fail-before-summary.2026-08-23T23-23.md` ([P1-T5]) and the four
per-task artifacts it cross-references.

## Output Summary

**130 tests passed** across **9 test suites**, with 0 failures and 0 skips.

```
Test Suites: 9 passed, 9 total
Tests:       130 passed, 130 total
Snapshots:   0 total
Time:        1.692 s, estimated 2 s
Ran all test suites matching potential-to-issue.
```

The nine matched suites:

```
test\extension.potential-to-issue.test.ts
test\lib\potential-to-issue\potential-to-issue-service-call.test.ts
test\lib\potential-to-issue\gh-client.test.ts
test\lib\potential-to-issue\repo-slug.test.ts
test\lib\potential-to-issue\promotion.test.ts
test\lib\potential-to-issue\promotion.matrix.test.ts
test\lib\potential-to-issue\promotion.missing-label.test.ts
test\lib\potential-to-issue\content.test.ts
test\mcp-tools.potential-to-issue-target-repository.test.ts
```

The four suites carrying the regression tests are included, and so are the four pre-existing
promotion and content suites plus the extension-level suite, none of which regressed.

## Confirmation That Each Named Test Passed

All **17** tests named across [P1-T1] through [P1-T4], [P2-T2], [P2-T3], [P3-T8], [P4-T1], and
[P4-T2] passed.

The `run-jest.cjs` wrapper suppresses per-test reporter output, so `--verbose` on the command above
returns only the aggregate counts and cannot itself name the tests. Confirmation was therefore taken
by three targeted counting runs, each of which reports its own exit code and pass count. This is the
same technique the plan's own Phase 1 through Phase 4 per-task acceptances used.

| Task | Named test(s) | Count | Verifying run | EXIT_CODE | Result |
| --- | --- | --- | --- | --- | --- |
| [P1-T1] | `returns the nameWithOwner slug and runs with cwd set to the workspace root` | 1 | run A | 0 | passed |
| [P2-T2] | `throws when the checkout has no origin remote`; `throws when the resolution command exits non-zero`; `throws when the command produces empty output`; `throws when the output is not valid JSON`; `throws when the payload is parseable but is not an object`; `throws when the owner and name field is missing`; `throws when the owner and name field is not a string` | 7 | run A | 0 | all passed |
| [P2-T3] | `names the workspace root in the thrown message` | 1 | run A | 0 | passed |
| [P1-T2] | `binds the repo selector into the issue create vector`; `binds the repo selector into the label create vector`; `binds the repo selector into the issue view vector` | 3 | run B | 0 | all passed |
| [P4-T1] | `carries the same repo selector on the missing-label recovery retry` | 1 | run B | 0 | passed |
| [P4-T2] | `leaves the three vectors unchanged when no repo is supplied` | 1 | run B | 0 | passed |
| [P1-T3] | `resolves the target repository from a workspace root that differs from the process working directory` | 1 | run C | 0 | passed |
| [P1-T4] | `resolves the target repository when the workspace root matches the process working directory` | 1 | run C | 0 | passed |
| [P3-T8] | `fails closed without creating an issue or moving the record when the slug cannot be resolved` | 1 | run C | 0 | passed |

**Run A** — `npm --prefix extensions/drm-copilot run test -- potential-to-issue/repo-slug`
EXIT_CODE 0; `Test Suites: 1 passed, 1 total` / `Tests: 9 passed, 9 total`. The resolver suite holds
exactly nine tests: the one from [P1-T1], the seven from [P2-T2], and the one from [P2-T3]. The whole
file passing at a count of 9 accounts for all nine with no residue.

**Run B** — `npm --prefix extensions/drm-copilot run test -- potential-to-issue/gh-client
--testNamePattern "binds the repo selector into|missing-label recovery retry|unchanged when no repo
is supplied"`
EXIT_CODE 0; `Tests: 12 skipped, 5 passed, 17 total`. Five selected, five passed: the three from
[P1-T2], the one from [P4-T1], and the one from [P4-T2].

**Run C** — `npm --prefix extensions/drm-copilot run test --
potential-to-issue/potential-to-issue-service-call --testNamePattern "process working
directory|fails closed without creating an issue"`
EXIT_CODE 0; `Tests: 8 skipped, 3 passed, 11 total`. Three selected, three passed: the one from
[P1-T3], the one from [P1-T4], and the one from [P3-T8].

9 + 5 + 3 = 17, matching the count named across the nine tasks exactly.

## Fail-Before to Pass-After Transition

Each of the four Phase 1 artifacts recorded `ExpectedExitCode: 1` and a non-zero observed
`EXIT_CODE:` against unmodified source. The same commands now exit 0. [P1-T1]'s fail-before was
existence-level — the resolver module could not be resolved — and [P1-T2] through [P1-T4] were
value-level, failing on an exact-vector comparison or on an absent resolved field. The transition is
therefore from a failing assertion against unmodified source to a passing assertion against the
delivered fix, for both required cases: a workspace root that differs from the process working
directory, and one that matches it.
