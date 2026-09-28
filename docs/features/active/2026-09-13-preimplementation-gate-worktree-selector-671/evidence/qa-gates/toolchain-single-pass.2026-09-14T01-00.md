# Toolchain Single-Pass Record (issue #671)

Timestamp: 2026-09-17T08-30
Task: [P6-T7]
Command: sequence review of [P6-T1] -> [P6-T2] -> [P6-T3]
EXIT_CODE: 8
Status: INCOMPLETE — the loop did not close in a single clean pass.

Output Summary:
- Sequence executed once, in order, with no intervening file change:
  1. Format: `evidence/qa-gates/poshqc-format.2026-09-14T01-00.md`. No file changed; all seven hash pairs were equal.
  2. Analyze: `evidence/qa-gates/poshqc-analyze.2026-09-14T01-00.md`. 0 findings on all seven paths.
  3. Test: `evidence/qa-gates/poshqc-test-coverage.2026-09-14T01-00.md`. **Failed**: 8 failing nodes. 2 are baseline failures; the other 6 are the L3a, L3b, and L8 deny rows in each command-exemption suite.
- Restarts preceding this sequence: 0.
- The test step's failures cannot be fixed within the approved plan. The L3a and L3b fixtures do not match the gate trigger, and the L8 fix requires editing helpers line 221, which [P1-T3] and [P5-T4] prohibit. A restart would therefore reproduce the same result, so no restart was attempted. A plan and spec revision is required before the loop can close; the proposed delta is in the executor completion report.
