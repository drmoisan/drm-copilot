# Preflight Fixes (Issue #1188)

Timestamp: 2026-11-14T20-28
Plan: docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/plan.2026-11-14T13-12.md
Command: env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: branch-current plan validator passed before and after the fixes below; four trivial fixes made in task text only; no task added, removed, or reordered.

## Fixes

1. [P1-T1] | unsatisfiable acceptance whose correction keeps its meaning (task ordering of a dot-source) | The suite dot-sourced only the gate, and the gate does not load the sibling until P2-T3, so the P2-T1 acceptance "every G-row passes" could not be met. The G-row `Context` now dot-sources the Claude sibling in its own `BeforeAll`; before P2-T1 only that container fails and the gate rows keep running.
2. [P1-T1] | validator-blind hidden pin (epic-state isolation discovery guard) | A new suite that loads the preimplementation gate is discovered by `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (AC-4 baseline form, AC-6 probe It). The task now requires the `baseline mock interception probe` It, as in `enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1`.
3. [P1-T2] | same two classes as fixes 1 and 2 on the Codex surface | The G-row `Context` dot-sources the Codex sibling in its own `BeforeAll` (the P2-T2 acceptance "Codex G-rows pass" precedes the P2-T4 wiring), and the suite carries the Codex interception probe It.
4. [P2-T2] | citation correction | "its core-manifest listing row" replaced with the exact test name `lists every shared hook module in the core pack manifest`.
5. [P3-T1] | validator-blind ledgered region | The new `## Contract Tests That Pin Mirrored Files` bullet is placed as the last bullet of the section, after the `test-cadence-wording.Tests.ps1` bullet, outside the context lines of the 0001 and 0006 stored-patch hunks that `ProcessReductionChain.Ledger.Tests.ps1` checks.
