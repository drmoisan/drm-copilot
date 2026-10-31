# Preflight Fixes (Issue #1010)

Timestamp: 2026-10-30T12-43
Plan: docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/plan.2026-10-30T08-09.md

Single-pass preflight. Every fix below edits task text or preamble only; no task was added, removed, or reordered, and no acceptance condition changed what it asserts.

## Fixes

1. [P0-T2] | stop-condition wording | The stop condition listed six triggers, but the acceptance condition also requires the injectable invoker seam and the other recorded fields. When one of those fields could not be populated, the acceptance condition could not be met and no stop trigger applied. The stop condition now also covers "any other field above cannot be populated (including an absent injectable invoker seam)". The acceptance condition is unchanged.
2. [P0-T5] | validator-blind defect (named mode that does not exist) | `Invoke-PoshQCFormat` has no check-mode switch. The task now names the existing route: the `-WriteFile` seam is replaced by a no-op, so each file logs `Formatted:` or `Already formatted:` and nothing is written. The porcelain before-and-after acceptance condition is unchanged.
3. [P2-T3] | mechanical precondition | Before the fix, the Codex gate does not load the resolver twin, so a Pester `Mock` of the twin's invoker would fail in `BeforeAll`, and the fail-before run would record a setup error instead of the pre-fix deny. The task now dot-sources the twin after the gate, which matches P2-T1's explicit import of `HookTargetWorktree.psm1`. The row set and the acceptance condition are unchanged.
4. [P5-T3] | literal no longer in the spec | "rows R1 to R15" now reads "every row of `enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1`". The spec removed the range, and AC-12 requires the whole file to pass. The suite currently defines exactly R1 to R15 plus the probe row, so the set of rows asserted does not change.
5. [## Declared File Set] | file not named explicitly | "this plan file" now reads `FEATURE/plan.2026-10-30T08-09.md`.

## Validation

- Branch-current CLI (`scripts/dev_tools/validate_orchestration_artifacts.py` `plan`, Poetry module form): passed before and after the fixes.
- Installed MCP validator (`validate_orchestration_artifacts`, `plan`): passed before and after the fixes.
