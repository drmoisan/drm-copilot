# Code Review: orchestrator-stop-hook-validates-wrong-worktree-checkpoint (issue #1145)

- Branch: `bug/orchestrator-stop-hook-target-worktree`
- Head reviewed: `ee88894af970ed6c6455aac6df826fed2872a553`
- Base: `70e66be7566f4c7259acce97449c769f7ff3854a` (merge base of `origin/main` and `HEAD`)
- Timestamp: 2026-11-08T23-06

## Executive Summary

The change is a small, well-separated edit. All new resolution logic lives in `.claude/hooks/validate-orchestrator-output-target.ps1`, which wraps the existing `Resolve-SubagentStopTargetWorktree` seam rather than re-implementing worktree resolution. The main hook adds two guarded dot-sources, two optional seam parameters forwarded only when bound (the established `RoutingInvoker` pattern), one resolver call, and the fallback note; the resolution sibling adds one optional parameter and a two-line branch for the item kind. The epic and parallel paths are untouched.

Gate intent: the reviewer traced every outcome of `Resolve-HookTargetWorktree` for a `DelegationIdentity` source. Each path returns either a worktree root with a null reason code or a null root with `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS`, so no identity-bearing prompt reaches the session-worktree fallback except through a resolver exception, which the spec explicitly routes to the session worktree with a failure note. NoTarget and Ambiguous block before any read (non-repairable, so the unchanged #903 re-entry policy allows the re-entered stop once). The `-CheckpointPath` leaf-shape check still runs first. No stop that should block was found to pass beyond the spec-sanctioned behavior.

Tests are discriminating: with the item-target call site disabled, 14 of the 17 rows of the hook-level suite fail; all pass on the unmodified copy. No blocking finding. The findings below are informational or low severity and do not require remediation before merge.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low | `.claude/hooks/validate-orchestrator-output-target.ps1` | `Resolve-OrchestratorOutputItemTarget`, `$failureNote` assignment | Resolver-failure detection is a string prefix match on `target worktree resolution failed`, the literal produced by the catch block of `Resolve-SubagentStopTargetWorktree`. A rewording of that message would silently drop the failure detail from the fallback note (the gate decision is unaffected). | Optional follow-up inside a later change: expose a failure flag or source value from the resolver instead of matching message text. | Message-text coupling across files is fragile; the impact is limited to diagnostic text. | `subagentstop-target-worktree.ps1` line 239; H8 pins the current text. |
| Low | `.claude/hooks/validate-orchestrator-output-target.ps1` | `Get-OrchestratorOutputFallbackNote` | In the resolver-exception case a prompt identity may have been present, yet the fixed note text states that no `branch:` label or canonical issue line is identifiable. The appended `Detail:` clause carries the real cause. | Optional: word the exception variant as "target worktree resolution failed" rather than "no identity". | The note can mislead an operator reading only the first sentence; the spec permits the fallback itself. | Spec Proposed Fix, resolution order item 3; H8. |
| Info | `.claude/hooks/validate-orchestrator-output-target.ps1` | `Resolve-OrchestratorOutputItemOperandTarget` | The mapping function mutates its input (`$ItemTarget.FallbackApplied = $true`) so the later note lookup can see that the fallback was taken. This is a side effect in a function documented as a mapping. | Acceptable as written; a return-tuple alternative would widen the resolution-sibling edit, which the spec deliberately kept minimal. | Hidden mutation reduces readability slightly; it is documented in the function help. | Function `.DESCRIPTION` states it sets `FallbackApplied`. |
| Info | `.claude/hooks/validate-orchestrator-output.ps1` | `Invoke-OrchestratorOutputValidation`, `StopHookActive` early return | On a re-entered non-repairable stop the allow result is returned without the `Note` key, so no fallback note is written on that path. | None required; the block that preceded the re-entry already carried the note. | Behavior matches the pre-existing re-entry return shape. | H9. |
| Info | `tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1` | H1, H2 | The recorded fail-before failure of H1 and H2 is a parameter-binding exception (the unmodified hook has no `-ReadTranscriptHead`), not a behavioral assertion failure. | None required; the reviewer mutant probe shows H1 and H2 fail on the behavior itself when the call site is disabled. | Fail-before evidence alone does not prove behavioral discrimination; the probe closes the gap. | `evidence/regression-testing/fail-before.2026-11-08T22-05.md`; reviewer probe 14 of 17 failing under the mutant. |
| Info | `.claude/hooks/validate-orchestrator-output.ps1` | top-level script body | The allow-note writer is a separate testable function with an injectable `TextWriter`, and the entry tail adds one call. | None. | Keeps host I/O at the edge and testable (H13). | Lines 426-430. |

No file in the branch diff is at or above 700 logical lines (largest: `.claude/hooks/validate-orchestrator-output.ps1`, 430), so no file-size Warning row applies.

## Design and Reuse Assessment

- Reuse: `Resolve-SubagentStopTargetWorktree` (transcript read, identity reduction, issue-reader handling) and `Resolve-WorktreeOperandTarget` (session fallback) are called, not copied.
- Separation: pure decision functions in the sibling; I/O stays behind the existing seams (`Read-TranscriptHead`, worktree list invoker, `Get-CheckpointFileContent`).
- Minimal main-file edit: 27 changed lines in `validate-orchestrator-output.ps1`, including four lines of help text, which keeps the merge with concurrent edits to that file small.
- Mirror and manifest parity: the three hooks and two skills are byte-identical with the bundle copies; `core.json` lists the new sibling; six brief copies share one hash.
- No absolute paths: tests use `/synthetic-worktrees/...` roots and an explicit `-SessionRoot`.

## Verdict

PASS. No blocking finding.
