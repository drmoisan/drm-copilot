# Preflight Fixes — Issue #1231 (round two)

Timestamp: 2026-11-23T23-31
Plan: .dev/active/1231-pr-author-release-exemption/plan.2026-11-23T17-58.md
Signal: PREFLIGHT: ALL CLEAR

## Fixes Applied In Place

1. [P2-T2] AC-10 decision row | unsatisfiable literal (validator-blind; meaning kept) | "zero git-seam calls" changed to "zero release-leg git calls: zero `Get-PrAuthorReleasePublishedHead` calls, and `Invoke-PrAuthorDocsOnlyGitExe` invoked exactly twice (the docs-only leg's base `rev-parse` and `diff`, with the row's mocked diff listing a path outside `docs/`)". `Get-PrAuthorDocsOnlyExemption` in `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` calls `Invoke-PrAuthorDocsOnlyGitExe` for its base `rev-parse` and its `diff` before the release leg is reached, so a decision-level count of zero could not pass. The corrected count still fails if the release leg makes any git call with the file absent.
2. [P1-T3] AC-10 traceability | clarification (no assertion change) | added a sentence stating that the AC-10 zero git-seam assertion for the preimplementation gate is the P1-T2 absent-file unit row, because `Get-OrchestrationParallelRecordsResult` (`.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1`) calls `Get-EpicScopeWorktreeHeadBranch` for a receipt-path Write before Leg 3 runs, so a gate-level zero count is not observable.

## Verification Performed

- Round-one substantive defects confirmed resolved in task text: [P1-T1] case-sensitive row; [P1-T2] step-2 and step-3 decline rows; Write-Debug caught-error rows in [P1-T2], [P2-T1], [P2-T3]; [P2-T1] HEAD_UNRESOLVED sub-condition rows, zero git-seam assertions, and exact diff-argument ParameterFilter.
- `Invoke-PrAuthorDocsOnlyGitExe` takes `-GitArgs`; the cleanup and docs-only legs use the diff argument list the P2-T1 ParameterFilter asserts.
- `Get-OrchestrationGateBookkeepingWorktreeRoot` is pure and returns `$null` for a blank checkpoint path, so the P1-T2 step-2 row is reachable.
- `Get-ModelRoutingDocsEstateDecision` returns before any git call when no docs profile exists, so the P2-T4 AC-10 zero-call row is satisfiable.
- The final deny expression of `enforce-orchestration-preimplementation-gate.ps1` still ends with `+ $parallel.DenySuffix + $release.DenySuffix)`, matching P1-T3.
- Design check: every Behavior rule, Leg 1-3 step, and AC-01 to AC-23 and US-AC-01 to US-AC-08 maps to an implementing task and a test row.
