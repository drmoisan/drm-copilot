# Fail-before exception: #732 CR-3 shared epic-target outcome

Timestamp: 2026-10-13T12-29
Scope: issue #903, #732 CR-3 (`Resolve-OrchestrationEpicTargetOutcome` in `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` and its three copies; the epic-scope tails of `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and their bundle mirrors).

WhyFailingRunImpossible: CR-3 extracts duplicated decision logic from the two epic-scope gates into one shared function without changing behavior, so no existing assertion can fail before the change. The new `U25` rows exercise `Resolve-OrchestrationEpicTargetOutcome`, a function that does not exist before the change, so a pre-change run would fail on a missing command rather than on the behavior under test.

## Alternative proof

- The unchanged suites `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`, and the Codex `-epic-scope.Tests.ps1` and `-epic-scope-targets.Tests.ps1` suites must pass in P12-T23 against the refactored gates, which shows the deny and allow decisions and their reason text are unchanged.
- The `U25` rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` (both surfaces through the existing `-ForEach`) pin the five outcomes, including the exact session-root reason string asserted with `Should -BeExactly`.
- Behavior-preservation notes: the session-root reason string is built by `+` concatenation of literals whose joined text is identical to the removed single literal; the `target-not-ready` and verdict-deny reasons still come from `Get-OrchestrationEpicTargetDenyReason` with the same arguments; the readiness predicate is still `Get-EpicCommandLegReadinessFailure -Checkpoint $Scope.Checkpoint -MergeInProgress $Scope.MergeInProgress`, now supplied by each gate as a script block.

## Revert unit

CR3_COMMIT: c2fd0b62f4eb765dd805a44e5cb67584072355dd

`git show --name-only --format= c2fd0b62f` lists exactly the nine CR-3 paths (the two targets copies and two epic-scope gates under `.claude/hooks` and `.codex/hooks`, their four bundle mirrors, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`). `git revert c2fd0b62f` restores the pre-CR-3 state of all nine as one unit.
