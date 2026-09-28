# B-2 regression guard — full push-down suite after the D-2 edit

Timestamp: 2026-08-30T01-25

Task: [P3-T5] of
`docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command: `cd extensions/drm-copilot && npx jest test/lib/push-down/`

Command as executed (absolute-path prefix applied; the plan's command text above is
worktree-relative):
`cd "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/extensions/drm-copilot" && npx jest test/lib/push-down/`

EXIT_CODE: 0

Output Summary: All 17 push-down suites passed. Jest reported
`Tests:       235 passed, 235 total`. The [P0-T15] baseline for this identical command was
`Tests:       234 passed, 234 total`, so both the passed count and the total count rose by
exactly one, the increment being the single test added by [P3-T1]. No pre-existing test
changed state, which is the regression evidence that the D-2 edit did not alter the
well-formed merge path, the append path, the delivery path, or the surrounding push-down
suites.

## Asserted result line, verbatim

```
Tests:       235 passed, 235 total
```

## Complete console output, verbatim

```
Test Suites: 17 passed, 17 total
Tests:       235 passed, 235 total
Snapshots:   0 total
Time:        1.063 s
Ran all test suites matching test/lib/push-down/.
```

## Count comparison against the [P0-T15] baseline

| Source | Suites | Passed | Total |
| --- | --- | --- | --- |
| [P0-T15] baseline, same command, recorded in `evidence/remediation-baseline/typescript-pushdown-suite.2026-08-29T23-07.md` | 17 | 234 | 234 |
| This run | 17 | 235 | 235 |
| Delta | 0 | +1 | +1 |

The baseline value is recorded here beside the observed value so the comparison is auditable
rather than assumed. The plan's predicted line `235 passed, 235 total` matches the observed
line exactly.

Failed count is 0: Jest omits the `failed` segment from the `Tests:` line when the failure
count is zero, and `235 passed, 235 total` with no `failed` segment together with
`EXIT_CODE: 0` establishes it.

The suite count is unchanged at 17, which confirms [P3-T1] added a test to an existing suite
file rather than creating a new suite. The prohibited flags `--passWithNoTests`,
`--onlyChanged`, and `--lastCommit` were not used.
