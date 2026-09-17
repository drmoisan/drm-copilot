# F1 Binding Table — Issue #673 [P2-T4] and [P2-T5]

Timestamp: 2026-09-17T11-41

Command: `sed -n '27p;31p;32p;33p;34p;227p;277p;300p;335p;340p' .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`
and `sed -n '55p;417p;459p;468p;471p;479p;480p' .claude/lib/worktree-resolution/WorktreeResolution.psm1`

EXIT_CODE: 0

Output Summary: All six binding-table rows are bound against F1 as merged. Every row carries a
concrete identifier and the F1 `file:line` it was read from, and every cited line is quoted verbatim
below. No row reads `_unbound_`. The `Accessor Verification:` section records
`ACCESSOR_PRESENT: YES`. One gap is reported rather than resolved: F1 ships a **closed four-state**
result set, and F5's three-outcome design maps three of the four states; the `NoTarget` state is
unmapped.

## Filled binding table, copied from `spec.md`

| role | concrete identifier (fill in from F1 as merged) | source file:line in F1 |
| --- | --- | --- |
| module path | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` carries the derivation role; its sibling `.claude/lib/worktree-resolution/WorktreeResolution.psm1` carries the normalisation and reason-code roles | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:335` and `.claude/lib/worktree-resolution/WorktreeResolution.psm1:471` |
| module import statement | `Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeTargetResolution.psm1') -Force` **and** `Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeResolution.psm1') -Force`; both are required because F1's own sibling import is module-scoped and re-exports nothing, verified by observation | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27` |
| `<TARGET_DERIVATION>` function name | `Resolve-WorktreeCallTarget` | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:227`, exported at `:340` |
| `<PATH_NORMALISATION>` function name | `ConvertTo-WorktreeResolutionRepoRelativePath` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:417`, exported at `:479` |
| `<AMBIGUITY_REASON_CODE>` accessor function name | `Get-WorktreeResolutionAmbiguityReasonCode` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:459`, exported at `:480` |
| `<AMBIGUITY_REASON_CODE>` literal value returned by that accessor | `TARGET_WORKTREE_AMBIGUOUS` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:55`, returned at `:468` |

## Verbatim F1 source lines, one per table row

Row 1 — module path. Each module is established as a module by its own `Export-ModuleMember`:

```
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:335
Export-ModuleMember -Function `
```

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:471
Export-ModuleMember -Function `
```

Row 2 — module import statement. The idiom is read from F1's own sibling import:

```
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27
Import-Module (Join-Path $PSScriptRoot 'WorktreeResolution.psm1') -ErrorAction Stop
```

Row 3 — `<TARGET_DERIVATION>` function name:

```
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:227
function Resolve-WorktreeCallTarget {
```

```
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:340
    Resolve-WorktreeCallTarget, `
```

Row 4 — `<PATH_NORMALISATION>` function name:

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:417
function ConvertTo-WorktreeResolutionRepoRelativePath {
```

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:479
    ConvertTo-WorktreeResolutionRepoRelativePath, `
```

Row 5 — `<AMBIGUITY_REASON_CODE>` accessor function name:

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:459
function Get-WorktreeResolutionAmbiguityReasonCode {
```

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:480
    Get-WorktreeResolutionAmbiguityReasonCode
```

Row 6 — `<AMBIGUITY_REASON_CODE>` literal value:

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:55
$script:AmbiguityReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'
```

```
.claude/lib/worktree-resolution/WorktreeResolution.psm1:468
    return $script:AmbiguityReasonCode
```

## Role selection notes

- `<PATH_NORMALISATION>` binds to `ConvertTo-WorktreeResolutionRepoRelativePath` rather than to
  `ConvertTo-WorktreeResolutionNormalizedPath` (`WorktreeResolution.psm1:114`). The spec defines the
  role as "given a path in relative or absolute form, returns its repo-relative form by locating the
  containing worktree. Segment-count truncation is prohibited". `ConvertTo-WorktreeResolutionRepoRelativePath`
  is the function whose documented behaviour matches: `WorktreeResolution.psm1:420-425` states it
  converts a path to its repo-relative form by locating its containing worktree and that "no segment
  is dropped". `ConvertTo-WorktreeResolutionNormalizedPath` performs separator and trailing-slash
  normalisation only and locates no worktree.
- The module-path and import-statement rows name two files rather than one because the three roles
  are split across the pair: the derivation function is exported by `WorktreeTargetResolution.psm1`
  (`:335-341`), and the normalisation function and the reason-code accessor are exported by
  `WorktreeResolution.psm1` (`:471-480`).

### Observed: F1's sibling import is module-scoped and re-exports nothing

`WorktreeTargetResolution.psm1:27` imports its sibling inside the module's own session state, so a
caller that imports only the target module does not obtain the accessor. This was executed, not
inferred (route a-prime, `.../scratchpad/f673-exec/p2t5.sh`):

```
STEP1_ACCESSOR_VISIBLE_AFTER_TARGET_MODULE_ONLY: False
STEP1_TARGET_MODULE_EXPORTS: Find-WorktreeResolutionBranchSignal, Find-WorktreeResolutionFeatureFolderSignal, Find-WorktreeResolutionFilePathSignal, Join-WorktreeResolutionPath, New-WorktreeResolutionTargetResult, Resolve-WorktreeCallTarget
STEP2_ACCESSOR_VISIBLE_AFTER_BOTH_MODULES: True
STEP2_ACCESSOR_SOURCE_MODULE: WorktreeResolution
```

Consequence for F5: each modified hook must import **both** modules at script scope with the
`Join-Path $PSScriptRoot` idiom required by AC-25. Importing only `WorktreeTargetResolution.psm1`
would leave `Get-WorktreeResolutionAmbiguityReasonCode` unresolved and, under the hooks'
`Set-StrictMode -Version Latest`, would fail at first call rather than at import.

## Accessor Verification:

ACCESSOR_PRESENT: YES

- Accessor function name: `Get-WorktreeResolutionAmbiguityReasonCode`
- Definition: `.claude/lib/worktree-resolution/WorktreeResolution.psm1:459`
- Export evidence: `Export-ModuleMember -Function` at `.claude/lib/worktree-resolution/WorktreeResolution.psm1:471`,
  with `Get-WorktreeResolutionAmbiguityReasonCode` as the final entry of that list at `:480`. Confirmed
  at runtime: the observed export list of the imported module is
  `ConvertTo-WorktreeResolutionNormalizedPath, ConvertTo-WorktreeResolutionRepoRelativePath,
  Find-WorktreeResolutionRoot, Get-WorktreeResolutionAmbiguityReasonCode,
  Get-WorktreeResolutionDirectoryChildName, Get-WorktreeResolutionGitEntryKind,
  Get-WorktreeResolutionGitFileText, Get-WorktreeResolutionWorktreeRoot,
  Test-WorktreeResolutionRootMarker`.
- Value returned by the accessor, observed by calling it: `TARGET_WORKTREE_AMBIGUOUS`
  (`System.String`).
- The code is **not** shipped as a bare exported constant. `$script:AmbiguityReasonCode`
  (`WorktreeResolution.psm1:55`) is module-scoped and appears in no `Export-ModuleMember` list; the
  accessor at `:459-469` is the only exported route to the value.
- Cross-check through the derivation function: `Resolve-WorktreeCallTarget` populates `ReasonCode` by
  calling the same accessor (`WorktreeTargetResolution.psm1:126`), and an executed `Ambiguous` result
  carried `ReasonCode` = `TARGET_WORKTREE_AMBIGUOUS`.

Verbatim probe output:

```
STEP2_ACCESSOR_RETURN_VALUE: TARGET_WORKTREE_AMBIGUOUS
STEP2_ACCESSOR_RETURN_TYPE: System.String
STEP3_AMBIGUOUS_STATUS: Ambiguous
STEP3_AMBIGUOUS_REASONCODE: TARGET_WORKTREE_AMBIGUOUS
```

## F1's complete state set and its mapping onto F5's design — one state is unmapped

F1 returns a **closed four-value** `Status` set. The values are declared at
`.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:31-34` and are enforced as a closed
set by the `[ValidateSet('SessionRoot', 'OtherWorktree', 'NoTarget', 'Ambiguous')]` attribute on the
single constructor at `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:95`. The
declaration comment at `:29-30` states the set is closed so that "a caller writes exactly one branch
per state; a fifth value would silently fall through every caller".

Verbatim:

```
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:31
$script:StatusSessionRoot = 'SessionRoot'
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:32
$script:StatusOtherWorktree = 'OtherWorktree'
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:33
$script:StatusNoTarget = 'NoTarget'
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:34
$script:StatusAmbiguous = 'Ambiguous'
```

F5's design, as stated in `spec.md` `## Proposed Fix` and restated in
`plan.2026-09-13T20-48.md:33-44`, defines exactly three outcomes and states that "There is no fourth
outcome and no `else { use cwd }` branch".

| F1 state | file:line | action F5's design assigns | mapped? |
| --- | --- | --- | --- |
| `SessionRoot` | `WorktreeTargetResolution.psm1:31`, produced at `:300` | Design outcome 1 — target resolved, proceed with the absolute checkpoint path under the resolved root; falling to design outcome 2 (existing deny reason) if the checkpoint is absent or unreadable there | yes |
| `OtherWorktree` | `WorktreeTargetResolution.psm1:32`, produced at `:300` | Design outcome 1 — identical handling to `SessionRoot`; the resolved root differs but the branch is the same | yes |
| `Ambiguous` | `WorktreeTargetResolution.psm1:34`, produced at `:286` and `:297` | Design outcome 3 — deny with F1's ambiguity reason code `TARGET_WORKTREE_AMBIGUOUS`, which the result already carries on its `ReasonCode` field | yes |
| `NoTarget` | `WorktreeTargetResolution.psm1:33`, produced at `:277` | **none — the three-outcome design assigns no action to this state** | **no** |

### The unmapped state, stated without inventing a mapping

`NoTarget` is documented at `WorktreeTargetResolution.psm1:277` as meaning:

```
        return (New-WorktreeResolutionTargetResult -Status $script:StatusNoTarget -SessionRoot $session -Detail "the call names no feature folder, file path, or branch, so it has no target and the session root '$session' applies")
```

That is not the same condition as design outcome 3. Outcome 3 is "target **not identifiable**", which
is F1's `Ambiguous`: a signal was present and failed to place. `NoTarget` is the distinct condition
that **no signal was present at all**, and F1's own detail text prescribes that the session root
applies.

Neither of the remaining two outcomes accepts it as written:

- Routing `NoTarget` to design outcome 1 requires the caller to substitute the session root, because
  the `NoTarget` result object carries `WorktreeRoot` = `$null` (`WorktreeTargetResolution.psm1:121`,
  which populates `WorktreeRoot` only for the two resolved states per the `$isResolved` test at
  `:111`). Substituting the session root is the `else { use cwd }` branch that
  `plan.2026-09-13T20-48.md:42` forbids by name, because the session root is derived from
  `(Get-Location).ProviderPath` when no `-SessionRoot` is supplied
  (`WorktreeTargetResolution.psm1:261`).
- Routing `NoTarget` to design outcome 3 has no reason code to emit: the result object carries
  `ReasonCode` = `$null` for every state except `Ambiguous`
  (`WorktreeTargetResolution.psm1:126`). It would also deny every gated call that carries no target
  signal.

This artifact reports the gap and stops there. No mapping is invented for `NoTarget`, and no prose in
`spec.md`'s design section is edited. `[P3-T2]` and `[P3-T3]` measure how many real payload shapes
land in this unmapped state.
