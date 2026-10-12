# Registration Fail-Before ([P1-T14], expect-fail)

Timestamp: 2026-10-12T00-50
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: TotalCount=10, PassedCount=2, FailedCount=8, FailedContainersCount=0. Passing rows: REG-1 and REG-2. Every FAILED line names a REG-3 or REG-4 row.

Note: the first run of this suite reported REG-2 failing because the helper Get-E2Registration returned its array wrapped in a one-element array, so the loop saw every registration as one item. The helper return was corrected (test-only change) and this task was re-run; the counts below are from the re-run.

Passed rows:
  [+] REG-1 discovers exactly nine SubagentStop registrations of E2 hooks
  [+] REG-2 every argument name passed by a registration exists in the target script param block

Report:
TotalCount=10
PassedCount=2
FailedCount=8
FailedContainersCount=0
FAILED: E2 SubagentStop registrations and seams.REG-3 Invoke-OrchestratorOutputValidation declares the InputText seam and calls Read-SubagentStopEnvelope
FAILED: E2 SubagentStop registrations and seams.REG-3 Invoke-ExecutorOutputValidation declares the InputText seam and calls Read-SubagentStopEnvelope
FAILED: E2 SubagentStop registrations and seams.REG-3 Invoke-PlannerOutputValidation declares the InputText seam and calls Read-SubagentStopEnvelope
FAILED: E2 SubagentStop registrations and seams.REG-3 Invoke-RequiredArtifactOutputValidation declares the InputText seam and calls Read-SubagentStopEnvelope
FAILED: E2 SubagentStop registrations and seams.REG-4 validate-orchestrator-output.ps1 calls Exit-SubagentStopBlock once at script scope after the inline S1 tail
FAILED: E2 SubagentStop registrations and seams.REG-4 validate-executor-output.ps1 calls Exit-SubagentStopBlock once at script scope after the inline S1 tail
FAILED: E2 SubagentStop registrations and seams.REG-4 validate-planner-output.ps1 calls Exit-SubagentStopBlock once at script scope after the inline S1 tail
FAILED: E2 SubagentStop registrations and seams.REG-4 validate-required-artifact-output.ps1 calls Exit-SubagentStopBlock once at script scope after the inline S1 tail
