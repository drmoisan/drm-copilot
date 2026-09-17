# F1 Identifier Binding (issue #669, merged as PR #683)

Timestamp: 2026-09-17T10-41

Source: `.claude/lib/worktree-resolution/` on `feature/2026-09-13-prd-feature-gate-target-resolution-672`, whose HEAD `d039e89b2b2569151e9170e1bbefb9f974419f87` is F1's merge commit on `epic/worktree-scoped-state-resolution-integration`.

## MODULE-PATH

`.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (341 lines), which imports its sibling `.claude/lib/worktree-resolution/WorktreeResolution.psm1` (480 lines) at its line 27 with `Import-Module (Join-Path $PSScriptRoot 'WorktreeResolution.psm1') -ErrorAction Stop`. Importing the target module therefore makes both modules' exports available; the hook imports `WorktreeTargetResolution.psm1` and additionally imports `WorktreeResolution.psm1` explicitly where it needs a name exported only there.

## TARGET-DERIVATION-FUNCTION

`Resolve-WorktreeCallTarget` — declared at `WorktreeTargetResolution.psm1` line 227, listed in that module's `Export-ModuleMember -Function` block at line 340.

Signature: `-Text`, `-Branch`, `-FilePath`, `-SessionRoot` (all optional). Returns a `pscustomobject` with the members `Status`, `WorktreeRoot`, `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode`, `Detail` (constructed by `New-WorktreeResolutionTargetResult`, lines 119-128).

## PATH-NORMALISATION-FUNCTION

`ConvertTo-WorktreeResolutionRepoRelativePath` — declared at `WorktreeResolution.psm1` line 417, listed in that module's `Export-ModuleMember -Function` block at line 479. It returns `{ IsNormalized, RepoRelativePath, WorktreeRoot, ReasonCode, Detail }`; an absolute path is placed by the upward walk and keeps its full remainder below the located root, with no segment dropped (lines 444-450).

Composition companion, used where a repo-relative path must be re-composed against a resolved root: `Join-WorktreeResolutionPath` — declared at `WorktreeTargetResolution.psm1` line 305 and exported at line 341.

## AMBIGUITY-REASON-CODE

`TARGET_WORKTREE_AMBIGUOUS` — the literal assigned to `$script:AmbiguityReasonCode` at `WorktreeResolution.psm1` line 55 and returned by the exported accessor `Get-WorktreeResolutionAmbiguityReasonCode` (declared line 459, exported line 480). It is also carried on a target result's `ReasonCode` member exactly when `Status` is `Ambiguous` (`WorktreeTargetResolution.psm1` line 126). The hook reads the code through the accessor rather than restating the literal.

## F1-DISTINGUISHES: YES

`Resolve-WorktreeCallTarget` returns a closed four-value `Status` (`WorktreeTargetResolution.psm1` lines 31-34) that distinguishes the two states directly:

- Preamble ruling 8 state B ("no input to derive from") is returned as `Status = 'NoTarget'`, produced at line 277 when no feature-folder, file-path, or branch signal is present in the payload (`$present.Count -eq 0`). `ReasonCode` is `$null` in this state.
- Preamble ruling 8 state C ("explicit no-target") is returned as `Status = 'Ambiguous'`, produced at line 286 when a present signal places in zero or several worktrees, and at line 297 when two present signals place in different worktrees. `ReasonCode` is `TARGET_WORKTREE_AMBIGUOUS` in this state.

The two additional resolved states are `SessionRoot` (the one agreed root equals the session root) and `OtherWorktree` (it does not), both produced at lines 299-302; these are ruling 8 state A.

Because the discriminator is `YES`, `[P0-T8]`'s second halt arm does not fire and the hook does not need the envelope-field mechanism to separate state B from state C. `[P0-T9]` still runs and records its determination.

## Halt gate

Not triggered. The module is present under `.claude/lib/`, and all three required capabilities are exported: target derivation (`Resolve-WorktreeCallTarget`), path normalisation (`ConvertTo-WorktreeResolutionRepoRelativePath`), and a distinct ambiguity reason code (`Get-WorktreeResolutionAmbiguityReasonCode` returning `TARGET_WORKTREE_AMBIGUOUS`). No capability is re-implemented locally.
