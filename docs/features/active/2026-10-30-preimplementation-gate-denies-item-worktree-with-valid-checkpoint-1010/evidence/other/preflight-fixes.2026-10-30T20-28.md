# Preflight Fixes (Round 2)

Timestamp: 2026-10-30T20-28
Plan: docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/plan.2026-10-30T08-09.md

## Fixes

1. [P3-T1] | citation correction (existing-behavior test attribution) | The task named `treats a checkpoint missing lifecycle readiness as not ready` as a Claude-side existing-behavior test. That row exists only in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` and asserts the Codex `Test-OrchestrationReady`, which P3-T1 does not change. The disposition now names only the Claude-runtime `AC-17 readiness <Name> <Runtime>` rows for JSON `true` and `false`, and states that the Codex-side rows are dispositioned in P3-T4. No assertion changed.

2. [P3-T4] | missing existing-behavior disposition (citation completion) | P3-T4 applies the strict `lifecycle_ready` check to the Codex `Test-OrchestrationReady` but did not name the existing tests that assert that function. Added: the Codex-runtime `AC-17 readiness <Name> <Runtime>` rows for JSON `true` and `false`, and the `legacy-codex-hook-contracts.Tests.ps1` rows `treats a checkpoint missing lifecycle readiness as not ready` and `treats a complete checkpoint as ready`, each unchanged because they use JSON booleans or omit the property. No assertion changed.

3. [P4-T3] | missing existing-behavior disposition (citation completion) | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1` requests the `Get-CheckpointContent` baseline through `Register-EpicStateBaselineMock -Seam $ExtraSeam` on both runtimes, so the helper change in P4-T3 applies to it. It was absent from the P4-T3 disposition list. Added `.AttributionTrailer` to the claude-hooks list; its disposition (unchanged, because it injects `-CheckpointRaw` and mocks `Resolve-OrchestrationGateTarget` on the Claude runtime) is the list's stated reason. No assertion changed.

## Validation

- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` passed before the fixes; re-run after the fixes is recorded in the preflight return.
- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`) returned `ok: true` before the fixes.
