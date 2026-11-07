# Preflight Fixes — Issue 1105, Remediation Cycle 1

Timestamp: 2026-11-07T16-00
Plan: docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/remediation-plan.2026-11-07T15-37.md
Signal: PREFLIGHT: ALL CLEAR

## Fixes

1. [P1-T3] | validator-blind defect (acceptance check narrower than the guard it targets) | The census derivation called only `Get-EpicStateSuiteCompliance`, which implements the AC-4 row of `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`. The AC-6 row calls `Get-EpicStateProbeFinding`, so a second scan with zero AC-4 findings could not show the AC-6 row passing. The derivation now calls both functions. The task's assertion is unchanged: zero findings, and the AC-4 and AC-6 rows pass in the [P3-T2] gate.

## Checks performed without a fix

- Plan validator: MCP `validate_orchestration_artifacts` (plan) ok; branch-current CLI `scripts.dev_tools.validate_orchestration_artifacts plan` passed.
- Cited symbols exist: `Find-WorktreeResolutionBranchSignal`, `Find-WorktreeItemIssueSignal`, `Get-WorktreeItemCheckpointIssue`, `Get-WorktreeItemCheckpointText`, `Get-WorktreeItemLiveRoot`, `Resolve-HookTargetWorktree` (with `CheckpointIssueReader`), `Get-EpicStateSuiteCompliance`, `Register-EpicStateBaselineMock`, `Invoke-EpicStateInterceptionProbe`, `Get-PlanFileContent`, `Test-IsPreflightRun`, `Get-ExecutorOutputBlockDecision`, `Get-PreflightRunBlockDecision`, `Invoke-FeatureReviewCoverageValidation`, `Invoke-CoverageCase`.
- The eight existing tests named in [P1-T1] as updated are the full set of two-`branch:` prompts in the helper and `*.TargetWorktree.Tests.ps1` suites; no pre-existing hook suite supplies an issue-line-only prompt.
- Nine `Resolve-SubagentStopArtifactLocation` consumer sites in the six hooks match [P2-T2].
- Both modules imported in [P1-T1] are in `core.json`; the brief's #1105 bullet stays accurate after the change.
