# Preflight Fixes (issue #1136)

Timestamp: 2026-11-08T16-35
Plan: docs/features/active/2026-11-08-preimpl-gate-blocks-post-fanin-integration-writes-1136/plan.2026-11-08T11-00.md

## Fixes

1. [P1-T1] | validator-blind satisfiability (literal formatting, assertion unchanged) | Added that each row's `permissionDecision` assertion carries `permissionDecisionReason` in its `-Because` text. Without it, an `allow` assertion fails with only the expected and actual decision values, so the deny reason containing `merge-in-progress` that [P1-T2] and AC-1 require cannot be read from the shard JUnit. The rows still assert `allow`.
2. [P2-T2] | missing compliance note for an existing discovery guard (assertion unchanged) | Added that the new suite complies with the read-seam forms required by `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, which discovers every suite under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` by directory enumeration. The gate-level suites ([P1-T1], [P3-T3]) already name `Register-EpicStateBaselineMock` through their fixture patterns.

## Substantive defects returned (not fixed here)

- [P3-T1] / Design Summary: the Codex `Get-OrchestrationEpicScopeDecision` has no `$epicScopeText`; an `apply_patch` leg arrives with the patch body in `$Command`, an empty `$FilePath`, and its marker paths in `$legPaths`.
- [P3-T3]: AC-4 positive rows are missing on the Codex surface.
- [P2-T2] / [P3-T2]: spec command-leg and path-leg boundaries with no test that fails when they are broken.
