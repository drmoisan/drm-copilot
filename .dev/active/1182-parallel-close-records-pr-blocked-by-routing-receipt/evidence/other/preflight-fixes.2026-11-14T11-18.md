# Preflight Fixes (issue #1182)

Timestamp: 2026-11-14T11-18
Plan: docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182/plan.2026-11-14T05-32.md
Validators after the fixes: branch-current Python CLI `plan` subcommand exit 0; installed MCP `validate_orchestration_artifacts` ok.

## Fix 1 - [P1-T1] - validator-blind class (epic-state isolation discovery guard)

The task now names the `baseline mock interception probe` It row (`Invoke-EpicStateInterceptionProbe`). `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (row `AC-6 <Path> calls the interception probe from inside an It`) requires that row of every hook suite that complies through the `Register-EpicStateBaselineMock` helper form. The assertions of the task are unchanged.

## Fix 2 - [P1-T1] - validator-blind class (mock scope)

The task now states that the `Get-WorktreeRunCheckpointText` and `Get-EpicScopeWorktreeHeadBranch` mocks are hook-scope mocks without `-ModuleName`. `Register-EpicStateBaselineMock` mocks `Get-WorktreeRunCheckpointText` in the `WorktreeRunResolution` module scope only, which does not intercept a call made from a dot-sourced hook sibling. The assertions of the task are unchanged.

## Fix 3 - [P2-T3] - validator-blind class (string-literal guard)

The task now notes that the literal `orchestrator-state.json` also occurs inside `parallel-orchestrator-state.json`, so no detail or remedy string of the new sibling names that file. `It 'the in-scope hook files carry the checkpoint path literal in no string expression'` in `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` matches the substring. The assertion is unchanged.

## Fix 4 - [P2-T3] - citation correction (existing-test dispositions)

`hook-import-failure-exemptions.FailClosed.Tests.ps1` and `PreToolUseSchema.Contract.Tests.ps1` load only the preimplementation gate, not the model-routing hook, so they were removed from the model-routing disposition list and named in the [P2-T4] list instead. `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, which dot-sources the model-routing hook to read `Get-ModelRoutingGatedAgent`, was missing and is added with disposition unchanged.

## Fix 5 - [P2-T4] - validator-blind class (mock scope) and citation correction

"where not already mocked" is replaced by explicit hook-scope mocks (without `-ModuleName`) of `Get-EpicScopeWorktreeHeadBranch` and `Get-WorktreeRunCheckpointText` in the five updated suites, with the reason that their existing module-scoped mocks (`Register-EpicStateBaselineMock`, and the `-ModuleName` mocks in the EpicFanIn suite) do not intercept the leg's hook-scope calls. The unchanged list now names `hook-import-failure-exemptions.FailClosed.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` (its function inventory reads only the gate file, which gains no function), and `tests/scripts/claude-runtime/owner-directive-pass-down.Registration.Tests.ps1`. Dispositions and assertions are unchanged.

## Fix 6 - [P3-T1] - validator-blind class (epic-state isolation discovery guard)

The task now names the epic-state baseline mocks and the `baseline mock interception probe` It row, which `docs-estate-workflow.EndToEnd.Tests.ps1`, the suite it is modeled on, already carries. The assertions of the task are unchanged.
