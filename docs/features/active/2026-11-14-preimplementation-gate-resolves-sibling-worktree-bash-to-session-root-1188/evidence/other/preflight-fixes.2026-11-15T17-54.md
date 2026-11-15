# Preflight Fixes — remediation cycle 1 (issue #1188)

Timestamp: 2026-11-15T17-54
Plan: docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/remediation-plan.2026-11-14T23-56.md
Command: env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: branch plan validator passed before and after the fixes below; five trivial fixes applied in task text; no task added, removed, or reordered.

## Probes (read-only, scratch scripts under the worktree's gitignored artifacts/scratch-issue-1188/)

- Both gates, current tree: every planned positive classify row returns `Test-ImplementationCommand` false and `Test-OrchestrationGateInvocationConfirmed` true for its index (2 or 3), so each row fails before the supplement and stage 2 confirms it after; `which npx --yes jest` and `npm --version && echo lint` return stage-2 false; `npm --prefix "$(pwd)" run lint` classifies true. This confirms the corrected root cause in R1 (stage 1 never matches the split word; stage 2 confirms).
- `Get-OrchestrationGateCommandTargetOperand` on the two `bash --rcfile`/`--init-file` G-rows returns two paths (the rc value and the script), so both rows fail before the P1-T5 fix.
- Codex gate is 500 lines; `Get-OrchestrationModeDenyReason` with its leading comment is 16 lines plus a blank line, so P1-T4 leaves at most 484 lines and P1-T6 adds two; the Codex epic-scope file (474) stays under 500.

## Fixes

1. [P0-T1] | validator-blind (formatter check mode) | `Invoke-PoshQCFormat` has no check mode; the step now uses a non-writing `-WriteFile` seam and records the `Formatted:` line count as the drift count. Assertion unchanged (no file rewritten).
2. [P1-T7] | validator-blind (ledgered region) | the new `## Contract Tests That Pin Mirrored Files` bullet is placed directly after the operands Parity bullet instead of last; a new last bullet falls inside the `0001` ledger hunk context and fails `PRC-LEDGER-CHAIN-HOLDS` (observed in the first cycle of this item). Assertion unchanged.
3. [P1-T7] | changed-behavior test disposition | added `cleanup-merged-worktrees.SkillText.Tests.ps1` and `docs-authoring-roles.WorkflowText.Tests.ps1`, which read the brief's `## Hook Execution Context`, to the unchanged list (their tokens are in other bullets).
4. [P1-T2] | missing test row for behavior the same task owns (trivial on the #1016 precedent) | added positive rows `npx --no jest` and `npx --quiet tsc` (two form-2 options with no row) and `npm --prefix $(dirname $(pwd)) run lint` and `npm --prefix $(pwd)/$(echo x) run lint` (the nesting and chained-opener rules of form 1). Each was probed: unclassified on both gates today, stage-2 confirmed. Same file and design section; no new task.
5. [Pre-Mortem, File size] | stale literal | Claude gate line count corrected from 491 to 490 (about 492 after P1-T6).
