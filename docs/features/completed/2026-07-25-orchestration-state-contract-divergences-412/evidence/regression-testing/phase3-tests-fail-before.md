# Phase 3 fail-before — OrchestratorState per-step-key status vocabulary ([P3-T2], [expect-fail])

Timestamp: 2026-07-25T18-04

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/orchestrator-state -Output Detailed"` (run from the repository root)

EXIT_CODE: 0

Note on the exit code: `Invoke-Pester` invoked without `-CI` does not propagate a failing
exit status to the host process, so the pass/fail signal for this task is the Pester
result summary reproduced below, not the process exit code.

Output Summary:

- Tests Passed: 48, Failed: 5, Skipped: 0, Inconclusive: 0, NotRun: 0.
- The five failures are exactly the new [P3-T1] acceptance cases; every pre-existing case
  in `OrchestratorState.Tests.ps1` and `OrchestratorStateCompletion.Tests.ps1` passes.

Failing new tests (all in `Describe 'Get-OrchestratorStateBasePresenceError per-step-key status vocabulary'`):

1. `per-key extra statuses accepted on their owning key > accepts step9_status value passed`
   — `Expected $null or empty, but got 'Checkpoint has invalid step9_status: passed'.`
2. `per-key extra statuses accepted on their owning key > accepts step9_status value failed_remediation_required`
   — `Expected $null or empty, but got 'Checkpoint has invalid step9_status: failed_remediation_required'.`
3. `per-key extra statuses accepted on their owning key > accepts step9_status value blocked_ci_loop_limit`
   — `Expected $null or empty, but got 'Checkpoint has invalid step9_status: blocked_ci_loop_limit'.`
4. `per-key extra statuses accepted on their owning key > accepts step6_status value blocked_remediation_loop_limit`
   — `Expected $null or empty, but got 'Checkpoint has invalid step6_status: blocked_remediation_loop_limit'.`
5. `epic-merge-gate regression scenario > passes base validation for an epic_mode checkpoint recording step9_status passed`
   — `Expected $null or empty, but got 'Checkpoint has invalid step9_status: passed'.`

Passing new tests (pre-existing rejection behavior is already correct and must remain so):

- All 20 `per-key extra statuses rejected on every non-owning key` cases pass, confirming the
  per-key extra values are rejected on every non-owning `stepN_status` key both before and
  after the [P3-T3] production change.

This is the expected `[expect-fail]` outcome: only the new acceptance cases fail, demonstrating
that `.claude/lib/orchestrator-state/OrchestratorState.psm1` applies the shared
`$script:VALID_STEP_STATUS` set uniformly and has no per-step-key additive vocabulary.
