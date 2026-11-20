# Fail-Before: Claude Standalone Authorization Suites — Issue #670

Timestamp: 2026-09-17T08-08
Task: [P2-T3] [expect-fail]
Command: $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1','tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1' -PassThru; $r.FailedCount
EXIT_CODE: 0
ExpectedExitCode: 0

`Invoke-Pester` without `-EnableExit` exits 0 whatever the outcome, so the expected process exit code is 0 and the failing signal is `$r.FailedCount`.

Tree state at run time: branch 4 is not wired into `Invoke-EpicMergeGateDecision`, and `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` contains only the two moved envelope factories (no predicates, no reason codes).

Output Summary:
- `$r.FailedCount` = 49 (strictly greater than zero, as expected)
- `$r.PassedCount` = 3; TotalCount = 52
- Failing cases include:
  1. `decision matrix.decides allow for a valid 691 record in the per-feature checkpoint` (expected `allow`, was `deny`) — valid-record-allows case.
  2. `decision matrix.decides allow for a valid 691 record in the epic checkpoint` (expected `allow`, was `deny`).
  3. `decision matrix.decides allow for a valid 691 record in the parallel checkpoint` (expected `allow`, was `deny`).
  4. `decision matrix.decides deny for the discriminator merging unauthorized 777 after a cd into 501` (reason lacked `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH`) — four-property discriminator case.
  5. `decision matrix.decides allow for the paired positive merging authorized 501 after a cd into 501` (expected `allow`, was `deny`).
  6. `reason text and branch order.denies an explicit PR with no record using both the gate token and the absent code` (reason lacked `STANDALONE_MERGE_AUTHORIZATION_ABSENT`).
  7. All 13 `blocks that are not PR specific` cases, all 9 `field shape failures on the matched record` cases, and the remaining predicate cases (`Test-StandaloneCheckpointAllowsMerge`, `Test-StandaloneMergeAuthorizationRecord`, `Get-StandaloneMergeAuthorizationRecord` not recognized).
- Passing cases (behaviour already correct before the change, retained as guards): the `--squash` out-of-scope allow, the bare-merge line-433 text, and the six-spelling `Get-EpicMergeGateCommandPrNumber` case.
