# Fail-Before: Codex Standalone Authorization Suite — Issue #670

Timestamp: 2026-09-17T08-31
Task: [P5-T2] [expect-fail]
Command: $r = Invoke-Pester -Path 'tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1' -PassThru; $r.FailedCount
EXIT_CODE: 0
ExpectedExitCode: 0

`Invoke-Pester` exits 0 without `-EnableExit`, so the failing signal is `$r.FailedCount`.

Tree state at run time: `.codex/hooks/enforce-epic-merge-gate.ps1` is unmodified (no standalone branch, no reason-code constants).

Output Summary:
- `$r.FailedCount` = 9 (strictly greater than zero, as expected)
- `$r.PassedCount` = 6; TotalCount = 15
- Failing cases include:
  1. `decision matrix.decides allow for a valid 691 record in the child checkpoint`
  2. `decision matrix.decides allow for a valid 691 record in the epic checkpoint`
  3. `decision matrix.decides deny for a record naming 777 only`
  4. `decision matrix.decides deny for no authorization key on either checkpoint`
  5. `decision matrix.decides deny for a blanket boolean block value`
  6. `decision matrix.decides deny for a session_id that differs from the payload`
  7. `decision matrix.decides deny for a payload carrying no session_id`
  8. `reason text and the throw channel.denies an explicit PR with no record using both the gate token and the absent code`
  9. `reason-code spelling parity.spells the four reason codes identically in the Claude helpers file and the Codex hook`
- Passing guards (already correct before the change): the branch-1 and branch-2 allow guards, the `--squash` out-of-scope allow, the bare-merge existing deny text, and both throw-channel cases.
