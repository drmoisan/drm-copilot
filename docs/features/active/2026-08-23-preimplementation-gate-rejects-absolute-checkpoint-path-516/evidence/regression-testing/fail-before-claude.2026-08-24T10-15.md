# Fail-Before: Claude Facet Suite — Issue #516

Timestamp: 2026-08-24T10-15

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1 -CI"`

EXIT_CODE: 28

ExpectedExitCode: 28

Output Summary:

- `Tests Passed: 0, Failed: 28, Skipped: 0, Inconclusive: 0, NotRun: 0`
- Every one of the 28 named `It` blocks fails against the unfixed hook. Two distinct failure reasons, both proving the fix is absent:
  1. The 21 end-to-end decision cases fail with `ParameterBindingException: A parameter cannot be found that matches parameter name 'WorkspaceRoot'.` — `Invoke-OrchestrationPreimplementationGateDecision` carries no `-WorkspaceRoot` seam yet.
  2. The 7 helper unit cases fail with `CommandNotFoundException: The term 'ConvertTo-WorkspaceRelativePath' is not recognized as a name of a cmdlet, function, script file, or executable program.` — the pure normalization helper does not exist yet.
- This is the expected outcome for a `[expect-fail]` task. The pass-after counterpart is recorded by P5-T7.
