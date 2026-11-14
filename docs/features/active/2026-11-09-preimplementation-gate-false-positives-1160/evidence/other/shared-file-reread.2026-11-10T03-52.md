# Shared-File Re-read and Disposition Search (P1-T1)

Timestamp: 2026-11-10T03-52
Command: Read and Grep tools over the item worktree at the branch head (after the merge of origin/main); disposition search with Grep over `tests/scripts` for `git commit` rows, `commit (-F|--file)` rows, `agent-memory` rows, and the issue #671 LACS selector rows in the gate suites.
EXIT_CODE: 0
Output Summary: D9 choice is `suffix-strip`. The disposition search found existing decision-level rows on both surfaces whose expected deny the D5 widening flips to allow. Per the task text, the run stops here and the finding is reported to the orchestrator. No production or test file was edited.

## Symbol locations (current tree)

- `Read-OrchestrationGateCheckpoint`: `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`. Both return `Resolved`, `Raw`, `Path`, and `DenyReason`; neither returns a resolved worktree root.
- `Resolve-OrchestrationGateTarget`: same two files (unchanged location; #1163 has not moved it).
- `Get-EpicFanInAllowance`, `Test-EpicMergedFeaturePath`, `Get-EpicFanInShapeDetail`, `Test-EpicFanInStagedIndex`: `.claude/hooks/hook-epic-fan-in.ps1` (and its `.codex/hooks` twin).
- `Get-OrchestrationGateStagedIndex`: `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` (and its `.codex/hooks` twin).
- `$script:OrchestrationBookkeepingTrees`: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`.

## D9 choice

`suffix-strip`: the read result exposes `Path` only, so the leg would derive the root by stripping `/artifacts/orchestration/orchestrator-state.json`.

## Rows a D5 widening flips (stop condition)

Mechanism: the leg delegates to `Get-EpicFanInAllowance`, whose `Get-EpicFanInShapeDetail` admits `-F <value>` and accepts any `-C` value that matches `^(/|[A-Za-z]:/)`. With the leg predicate equal to the union of the five #539 trees and the declared roots, every command below reaches the single-feature final deny (not ready, cleanup leg not applied), is shape-admitted, has all operands under `docs/features/active/`, needs no staged-index read, and is therefore allowed by the leg. Each row currently asserts `deny`.

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1`, Context `outside epic scope`, test `returns the unchanged single-feature deny for the follow-up commit when HEAD is not the integration_branch`. Command `git commit -F /scratch/msg.txt -- docs/features/active/2026-09-25-child-a-901/evidence/other/x.md`; asserts `deny` and `-BeExactly` the generic single-feature text. Flipped by the D5 widening `git commit -F <file> -- <#539-tree paths>`.
2. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-merged-follow-up.Tests.ps1`, Context `denies`, test `returns the unchanged single-feature deny for the follow-up commit when HEAD is not the integration_branch`. Same command and assertion on the Codex gate.
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, Context `issue #671 worktree selector deny cases`, test `denies <Label>` rows `issue #671 LACS L4b - UNC selector`, `issue #671 LACS L5a - parent-directory segment in the selector`, `issue #671 LACS L5b - current-directory segment in the selector`, `issue #671 LACS L6 - wildcard in the selector`, `issue #671 LACS L7 - stray colon in the selector`. Each is `git -C <non-LACS absolute value> add -- docs/features/active/x/spec.md`, driven through `Invoke-OrchestrationPreimplementationGateDecision` with a not-ready checkpoint, asserting `deny`. The #539 exemption rejects the selector; the leg's shape rule accepts it.
4. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1`, Context `issue #671 worktree selector deny cases`, the same five rows on the Codex gate.

These suites are named as unchanged in the plan's `## Existing Tests Asserting Changed Behavior` and in spec AC-9 and AC-17, which require them to pass without modification. The conflict is between the D5 widening (spec D5 and AC-7) and AC-9/AC-17.

## Rows confirmed to still deny (no flip)

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` pathless `git commit -m "test"`: injected `-CheckpointRaw`, so the leg has no root and denies.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` and the Codex trigger-scoping suite: injected `-CheckpointRaw`; `git -C ../other-worktree add .` (relative `-C`), `git add .` (`.` segment), `$(git add .)` (unresolvable text) deny in the leg.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1` deny rows (`-F`, `--file=`): asserted at predicate level only (`Test-ExemptOrchestrationStagingCommand` false, `Test-ImplementationCommand` true); structural staging keeps classification true.
- MergedFollowUp and EpicFanIn deny rows inside epic scope (Contexts `denies with unchanged text` and `denies`): the epic-scope decision returns before the single-feature branch, so the leg is not reached.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` and the Codex cleanup suite rows naming `docs/research/y.md`: `docs/research/` is outside the effective roots, so the leg denies.
- LACS rows L1a, L1b, L2, L3a, L3b, L4a, the backslash selector, L8, and the non-exempt, `-A`, absolute-operand, redirection, and `cd` rows: rejected by the leg's shape, path, or unresolvable-text rules.
