# Fail-Before Regression Evidence (issue #413)

Timestamp: 2026-07-25T17-14

State of the tree at capture: the three Phase 2 regression tests are in place in
`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`; the production hook
`.claude/hooks/validate-orchestrator-output.ps1` is **still unfixed** (line 224 still reads
`$hasErrors = ($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace($outputText))`).
Phase 3 has not yet run.

Command: `pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 -Output Detailed"` (run at repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`)

EXIT_CODE: 0 (process exit code) — **with 2 test failures reported in the run summary**

Exit-code note (measured, not assumed): the plan anticipated a non-zero process exit code for
this run. `Invoke-Pester` invoked without `-CI` and without an explicit
`exit $result.FailedCount` does not propagate the failed-test count to the host process exit
code, so the `pwsh` process returned 0 despite 2 failing tests. This was measured directly by
re-running the same `Invoke-Pester` invocation and echoing the shell's `$?`, which printed
`PWSH_EXIT_CODE=0`. The authoritative fail-before signal for this artifact is therefore the
run summary line `Tests Passed: 25, Failed: 2`, not the process exit code. No test outcome is
affected by this; it is a property of the Pester invocation form specified in the plan.

Output Summary:

- Discovery: 27 tests in 1 file.
- Result: **Tests Passed: 25, Failed: 2, Skipped: 0, Inconclusive: 0, NotRun: 0** (1.19s).

### The two issue-413 ALLOW tests FAILED, as required (fail-before proof)

1. `Context 'routing-contract validation (Gap 1)'` ->
   **`allows DONE when the validator exits 0 and prints its success line (issue #413)`** — FAILED

   ```text
   at $result.Ok | Should -BeTrue, tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1:230
   Expected $true, but got $false.
   ```

   This is the end-to-end defect: `Invoke-OrchestratorOutputValidation` blocked a DONE claim
   even though the injected validator seam reported exit 0 with its own success line.

2. `Context 'Invoke-RoutingContractValidation'` ->
   **`reports no errors when the seam returns exit 0 with the validator success line (issue #413)`** — FAILED

   ```text
   at $result.HasErrors | Should -BeFalse, tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1:312
   Expected $false, but got $true.
   ```

   This is the unit-level defect: the second disjunct of the two-disjunct rule fired on the
   validator's success text.

Both failures are assertion failures on the expected post-fix behavior, which confirms the
tests genuinely detect the defect rather than failing for an unrelated reason.

### The [P2-T3] exit-2 fail-closed test PASSED (as designed, both before and after the fix)

- `Context 'Invoke-RoutingContractValidation'` ->
  `reports HasErrors when the seam returns exit code 2 (argparse misuse / crash path stays fail-closed)` — **PASSED**

This test is deliberately not tagged `[expect-fail]`; it passes under the defective rule
(non-zero exit satisfies the first disjunct) and must continue to pass under the fixed
exit-code-only rule. It supplies the AC4 exit-2/crash evidence.

### No other failures

All 24 remaining pre-existing tests in the file passed, including both fail-closed BLOCK
tests that must not be weakened:

- `reports HasErrors when the seam returns a non-zero exit code` — PASSED
- `blocks DONE with ROUTING_CONTRACT_BLOCKED when the validator reports errors` — PASSED

Other passing pre-existing tests: all 4 payload-validation tests, both checkpoint-presence
tests, all 4 checkpoint-structure tests, `allows DONE when the routing validator returns a
clean result`, `is mockable without invoking Python`, `blocks a fabricated-route checkpoint`,
`reports no errors when the seam returns exit 0 and empty output`, both ArtifactType
defaulting/threading tests, both `-CheckpointPath`/`-ArtifactType` parameterization tests,
both `Get-CheckpointFileContent` tests, and both capability-detection tests.

Verdict: fail-before established. Exactly the two issue-413 ALLOW tests fail against the
unfixed hook; the exit-2 fail-closed test passes; there are no incidental failures.
