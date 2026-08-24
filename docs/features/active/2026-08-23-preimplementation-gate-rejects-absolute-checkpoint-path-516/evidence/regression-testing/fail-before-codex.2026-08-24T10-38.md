# Fail-Before: Codex Facet Suite — Issue #516

Timestamp: 2026-08-24T10-38

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1 -CI"`

EXIT_CODE: 12

ExpectedExitCode: 12

Output Summary:

- `Tests Passed: 0, Failed: 12, Skipped: 0, Inconclusive: 0, NotRun: 0`
- All 12 named `It` blocks fail against the unfixed Codex hook, for the same two reasons recorded in the Claude fail-before artifact:
  1. The 10 decision cases fail with `ParameterBindingException: A parameter cannot be found that matches parameter name 'WorkspaceRoot'.` — the Codex decision function carries no `-WorkspaceRoot` seam yet.
  2. The 2 helper unit cases fail with `CommandNotFoundException: The term 'ConvertTo-WorkspaceRelativePath' is not recognized as a name of a cmdlet, function, script file, or executable program.` — the helper does not exist in the Codex copy yet.
- This is the expected outcome for a `[expect-fail]` task. The pass-after counterpart is recorded by P5-T7.
