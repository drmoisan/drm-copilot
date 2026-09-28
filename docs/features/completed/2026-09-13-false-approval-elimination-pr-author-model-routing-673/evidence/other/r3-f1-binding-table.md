# F1 Binding Table, Refreshed Against the Current Tree (issue #673)

Timestamp: 2026-09-19T17-37

Command: `sed -n '<n>p' <file>` for each of the sixteen cited lines, run against the working tree at `F5_BASE_SHA..HEAD` tip `c50f82c2c45865f3de57ed49ec622b4c301d46b9`.

EXIT_CODE: 0

The eight-row table written into `spec.md` `##### BINDING TABLE` by `[P1-T1]` is archived below together with the source line each citation was read from. The table now has eight rows; it previously had six. No row contains `_unbound_`.

## Row 1 — module path

Value: `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` carries the derivation role; its sibling `.claude/lib/worktree-resolution/WorktreeResolution.psm1` carries the normalisation and reason-code roles.

This row's citation was re-derived rather than supplied by the plan, because `[P1-T3]` verifies the same two registrations independently. The two module paths are tracked at the spellings above and are registered in the pack manifest at the adjacent lines quoted here, which is also the pair RS-9 cites and after which `[P2-T4]` inserts the new module.

```
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:169|    ".claude/lib/worktree-resolution/WorktreeResolution.psm1",
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:170|    ".claude/lib/worktree-resolution/WorktreeTargetResolution.psm1",
```

## Row 2 — module import statement

Value: both `Import-Module` statements are required, because F1's own sibling import is module-scoped and re-exports nothing.

```
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27|Import-Module (Join-Path $PSScriptRoot 'WorktreeResolution.psm1') -ErrorAction Stop
.claude/hooks/enforce-pr-author-skill-helpers.ps1:39|Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeTargetResolution.psm1') -Force -ErrorAction Stop
```

The first line is F1's sibling import, the fact the row's claim rests on. The second is the consumer form the row prescribes, taken from the file that already carries the two-statement form; it is the precedent DD-4 cites for keeping both imports in the prd-feature gate.

## Row 3 — `<TARGET_DERIVATION>` function name: `Resolve-WorktreeCallTarget`

```
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:233|function Resolve-WorktreeCallTarget {
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:346|    Resolve-WorktreeCallTarget, `
```

## Row 4 — `<PATH_NORMALISATION>` function name: `ConvertTo-WorktreeResolutionRepoRelativePath`

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:421|function ConvertTo-WorktreeResolutionRepoRelativePath {
.claude/lib/worktree-resolution/WorktreeResolution.psm1:498|    ConvertTo-WorktreeResolutionRepoRelativePath, `
```

## Row 5 — `<AMBIGUITY_REASON_CODE>` accessor: `Get-WorktreeResolutionAmbiguityReasonCode`

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:463|function Get-WorktreeResolutionAmbiguityReasonCode {
.claude/lib/worktree-resolution/WorktreeResolution.psm1:499|    Get-WorktreeResolutionAmbiguityReasonCode, `
```

## Row 6 — `<AMBIGUITY_REASON_CODE>` literal: `TARGET_WORKTREE_AMBIGUOUS`

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:55|$script:AmbiguityReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'
.claude/lib/worktree-resolution/WorktreeResolution.psm1:472|    return $script:AmbiguityReasonCode
```

## Row 7 — `<NO_TARGET_REASON_CODE>` accessor: `Get-WorktreeResolutionNoTargetReasonCode` (new in this revision)

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:475|function Get-WorktreeResolutionNoTargetReasonCode {
.claude/lib/worktree-resolution/WorktreeResolution.psm1:500|    Get-WorktreeResolutionNoTargetReasonCode
```

## Row 8 — `<NO_TARGET_REASON_CODE>` literal: `TARGET_WORKTREE_NOT_DERIVABLE` (new in this revision)

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:59|$script:NoTargetReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'
.claude/lib/worktree-resolution/WorktreeResolution.psm1:487|    return $script:NoTargetReasonCode
```

## Identifier-containment check

Sixteen lines are quoted, one per citation across eight rows. Each contains the identifier its row names, with one reading stated explicitly rather than left implicit: for rows 6 and 8, the second citation is a `return` of the script variable that holds the literal (`$script:AmbiguityReasonCode` and `$script:NoTargetReasonCode`), not a second occurrence of the literal itself. That is the correct citation for those rows, because the accessor returns the variable and the literal is assigned to it exactly once, at the first citation of the same row. The plan fixed both citations for both rows, and both are recorded as fixed.

## Stale citations corrected

Five of the six pre-existing rows carried citations that #687 invalidated by moving lines. The corrections, all verified above:

| Row | Was | Now |
| --- | --- | --- |
| module path | two module-source line numbers, one of which pointed at a `return $root` statement and the other at a blank line | the two pack-manifest registrations |
| derivation | `:227`, exported `:340` | `:233`, exported `:346` |
| normalisation | `:417`, exported `:479` | `:421`, exported `:498` |
| ambiguity accessor | `:459`, exported `:480` | `:463`, exported `:499` |
| ambiguity literal | `:55`, returned `:468` | `:55`, returned `:472` |

The sibling-import citation `WorktreeTargetResolution.psm1:27` was already correct and is unchanged.

Output Summary: The spec's binding table now carries eight rows, none containing `_unbound_`, and every citation resolves against the current tree. Sixteen source lines are quoted, one per citation, each containing the identifier its row names. Five of the six pre-existing rows had citations that #687 had invalidated; all five are corrected and the corrections are tabulated. Two rows are new in this revision and bind the no-target reason code that #687 added, which the pre-#687 spec had no row for. A ninth row is appended by `[P2-T7]` once `Resolve-WorktreeItemTarget` exists.

---

## Row 9 — `<TARGET_DERIVATION>` identity form (Revision 0.5): `Resolve-WorktreeItemTarget`

Appended by `[P2-T7]` once the function existed. Timestamp: 2026-09-19T18-10. Command: `sed -n '337p;392p' .claude/lib/worktree-resolution/WorktreeItemResolution.psm1`. EXIT_CODE: 0.

```
.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:337|function Resolve-WorktreeItemTarget {
.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:392|    Resolve-WorktreeItemTarget
```

Both quoted lines contain `Resolve-WorktreeItemTarget`, the identifier this row names: the first is its definition and the second its entry in the module's single `Export-ModuleMember -Function` statement. The spec's binding table now carries nine rows.

This row does not replace row 3. Row 3 binds `Resolve-WorktreeCallTarget`, F1's path-signal derivation, which remains in the tree unmodified and, after Phase 9, is called by none of the four gates this plan touches, though its own suite still exercises it; row 9 binds the identity form this feature adds beside it. Recording both is what makes AC-24's claim checkable, that no hook file defines any derivation of its own.
