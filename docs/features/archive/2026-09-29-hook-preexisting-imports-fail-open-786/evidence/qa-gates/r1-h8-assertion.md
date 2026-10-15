# Remediation Cycle 1 H8 Leading-Token Assertion ([P4-T1])

Timestamp: 2026-10-10T17-55
Command: sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1; sh <SCRATCHPAD>/r.sh rlines -Files tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1; sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (R-SCOPED, R-LINES, R-ISOLATION; route sh, each a fresh PowerShell 7 process)
EXIT_CODE: 0
Output Summary: R-SCOPED over the WaveBarrier suite: PassedCount 13, FailedCount 0, including `PASSED: H12 blocks the epic leg ...`; R-LINES 250; R-ISOLATION: PassedCount 315, FailedCount 0, no `FAILED:` line names the suite (its AC-4 and AC-6 rows passed).

Edit: inserted after line 247 of `tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1`, inside `It 'H12 blocks the epic leg naming OrchestratorStateEpicWaveBarrier.psm1 when its import failed'`, at eight-space indentation:

```powershell
        $result.Reason.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
```

The prefix is the `-ReasonPrefix` value that `.claude/hooks/validate-orchestrator-output.ps1:347` passes to `Get-HookDependencyFailureDecision`.

## R-SCOPED

EXIT_CODE: 0

```text
PassedCount: 13
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | result=Passed | passed=13 | failed=0
PASSED: baseline mock interception probe
PASSED: H1 surfaces one unmerged dependency as an unwrapped line followed by the halt instruction
PASSED: H2 surfaces two violated edges in depends_on order before the halt instruction
PASSED: H3 instructs the agent to report and halt without suggesting an edit to history
PASSED: H4 passes a clean epic checkpoint whose dependency merged before the dependent started
PASSED: H5 does not run the port for the parallel checkpoint type
PASSED: H6 does not run the port for the orchestrator-state checkpoint type
PASSED: H7 keeps the routing block and does not run the port when the routing dispatch fails
PASSED: H8 blocks as unevaluable for an array issue_num and reports no violation line
PASSED: H9 blocks as unevaluable for a NaN literal that ConvertFrom-Json accepts
PASSED: H10 blocks as unevaluable for a value nested in 70 arrays
PASSED: H11 blocks as unevaluable when the port fails with any other error
PASSED: H12 blocks the epic leg naming OrchestratorStateEpicWaveBarrier.psm1 when its import failed
```

## R-LINES

EXIT_CODE: 0

```text
LINES: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | 250
```

## R-ISOLATION

EXIT_CODE: 0

```text
PassedCount: 315
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | result=Passed | passed=315 | failed=0
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 calls the interception probe from inside an It
```

FAILED lines naming the suite: 0 (the run printed no `FAILED:` line).
