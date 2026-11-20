# Non-Blocking Deviation: Root Jest Baseline Comparison [P2-T7] — remediation cycle 1

Timestamp: 2026-11-20T20-14
Decision: accept_nonblocking_deviation, under OD-1: "you are in autonomous mode. Do not ask permissions. Do not stop. Continue until you have completed this epic in its entirety. You are capable of doing this. You do not need human intervention."

Observation: [P2-T7] compares the root Jest totals with `review-coverage-check.2026-11-20T18-28.md`. The reviewer measured those figures with a direct `node run-jest.cjs --coverage` run at the root: 419 suites, 6717 tests, lines 98.52% (81621/82839), branches 94.61% (12729/13454). The executor's gate runs the launcher `jest` suite, which excludes the integration lane (`config/test-execution-policy.json`, `lanes.integration`), as the `test-execution-policy` skill requires for local gates; direct runner commands are denied by the test-execution hook. The launcher run covers 415 suites.

Final figures (pass 2): 415 suites, 6724 tests; lines 98.44% (81575/82866), branches 94.63% (12706/13426). Branches are not below the reviewer figure. Lines are 0.08 points below it: the 46 fewer covered lines are lines that only the four integration-lane suites execute, which the launcher does not run locally.

Like-for-like comparison: the [P1-T8] launcher run at head 5cc3abfc8 measured lines 98.44% (81575/82866) and branches 94.62% (12705/13426); pass 2 equals it on lines and exceeds it on branches. The line denominator rises by 27 against the reviewer run (82839 to 82866), which matches the 25 added `layout-map.ts` lines and the 2 added `migration-plan.ts` lines.

Options: (a) halt for an owner ruling; (b) run the integration lane locally, which the launcher refuses and policy excludes; (c) record the comparison as not like-for-like, compare with the launcher run of the same suite, and leave the integration lane to CI. Selected (c), the recommended option. The integration lane runs in CI (`root-typescript-tests` jobs and `CI Required Gate`).
