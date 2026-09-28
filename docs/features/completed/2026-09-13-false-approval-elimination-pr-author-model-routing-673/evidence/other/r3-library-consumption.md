# Library Consumption: AC-24 and AC-25 (issue #673)

Timestamp: 2026-09-19T19-10

Command: `grep -n '^Import-Module'` over each file to list column-0 load-time imports; `grep -noE` over the worktree-resolution function names to list every library call with its line; `grep -c 'SilentlyContinue'` over each file.

EXIT_CODE: 0

## Imports and library calls, per file

### `.claude/hooks/enforce-pr-author-skill.ps1`

Imports: `HookPayload.psm1` (`:47`), `OrchestratorState.psm1` (`:53`). Worktree-resolution library calls: none. `SilentlyContinue`: 0.

This file calls no library function, so it needs no worktree-resolution import. It dot-sources its helpers, which carry them.

### `.claude/hooks/enforce-pr-author-skill-helpers.ps1`

Imports, all at column 0 with `-Force -ErrorAction Stop`, which is this file's existing convention:

- `WorktreeResolution.psm1` (`:41`)
- `WorktreeTargetResolution.psm1` (`:42`)
- `WorktreeItemResolution.psm1` (`:46`)

Library calls: `Resolve-WorktreeItemTarget` (`:60`), `Get-WorktreeResolutionNoTargetReasonCode` (`:81`), `Get-WorktreeResolutionAmbiguityReasonCode` (`:87`), `Get-WorktreeItemCheckpointPath` (`:111`). `SilentlyContinue`: 0.

**Why both F1 imports are retained here, and the reason differs from the prd gate's.** After Phase 5 neither F1 import serves a call in this file: the two accessor calls at `:81` and `:87` are inside doc-comment prose naming the accessors, not invocations, and no F1 function is invoked. What depends on the imports is the suites that dot-source this file. `enforce-pr-author-skill.TargetResolution.Tests.ps1` calls both accessors and imports nothing itself; `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` and `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` call `New-WorktreeResolutionTargetResult`. An `Import-Module` inside a dot-sourced file lands in the caller's session state, so removing either import would break those suites while leaving this file working.

### `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`

Imports: none at column 0. Library calls: none. `SilentlyContinue`: 0.

This file receives the checkpoint path as a parameter and calls no library function, so it gains no import, as RS-12 states.

### `.claude/hooks/enforce-model-routing-receipt.ps1`

Imports: `HookPayload.psm1` (`:50`), `WorktreeItemResolution.psm1` (`:53`, column 0, `-Force -ErrorAction Stop`). Library calls: `Resolve-WorktreeItemTarget` (`:149`), `Get-WorktreeItemCheckpointPath` (`:189`). `SilentlyContinue`: 0.

One import suffices: this file calls no F1 function. It reads `ReasonCode` and `Detail` as properties of the result object rather than calling an accessor.

### `.claude/hooks/enforce-prd-feature-before-planner.ps1`

Imports: `HookPayload.psm1` (`:103`), `WorktreeTargetResolution.psm1` (`:111`), `WorktreeItemResolution.psm1` (`:112`). Both worktree-resolution imports are at column 0 with the bare `-Force` form this file already used, which the file's own justification comment records as the fail-closed choice. Library calls: `Resolve-WorktreeItemTarget` (`:243`), `Get-WorktreeResolutionNoTargetReasonCode` (`:352`), `Get-WorktreeItemCheckpointPath` (`:364`), `Get-WorktreeResolutionAmbiguityReasonCode` (`:372`), `Join-WorktreeResolutionPath` (`:400`). `SilentlyContinue`: 0.

**Why this file keeps two worktree-resolution imports.** The call at `:400` composes the document probe path, and `Join-WorktreeResolutionPath` is exported only by `WorktreeTargetResolution.psm1`. Importing the identity module alone would leave that call unresolvable on every `OtherWorktree` result, which is precisely the coordinator case this feature exists to fix. The reason is distinct from the pr-author helpers': there the retained imports serve dot-sourcing consumers, here one of them serves a call in the file itself.

### `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`

Imports: `WorktreeResolution.psm1` (`:27`, column 0, bare `-Force`). Library calls: `ConvertTo-WorktreeResolutionRepoRelativePath` (`:105`), plus the file's own `ConvertTo-PrdFeatureFolderToken` (`:98`). `SilentlyContinue`: 0.

This import is load-bearing twice over: it supplies the normalisation `ConvertTo-PrdFeatureFolderToken` calls, and, because the parent dot-sources this file, it is also how the parent's two accessor calls resolve.

## Resolution-category record

Every worktree-resolution function called in these six files, classified as (i) exported by a module the same file imports, (ii) exported by a module imported by a file dot-sourced into the same session state, or (iii) reached only through a sibling module whose exports are pinned by an explicit `Export-ModuleMember` list.

| Call | File and line | Category |
| --- | --- | --- |
| `Resolve-WorktreeItemTarget` | `enforce-pr-author-skill-helpers.ps1:60` | (i) — `WorktreeItemResolution.psm1`, imported at `:46` |
| `Get-WorktreeItemCheckpointPath` | `enforce-pr-author-skill-helpers.ps1:111` | (i) — same module, same import |
| `Resolve-WorktreeItemTarget` | `enforce-model-routing-receipt.ps1:149` | (i) — `WorktreeItemResolution.psm1`, imported at `:53` |
| `Get-WorktreeItemCheckpointPath` | `enforce-model-routing-receipt.ps1:189` | (i) — same module, same import |
| `Resolve-WorktreeItemTarget` | `enforce-prd-feature-before-planner.ps1:243` | (i) — `WorktreeItemResolution.psm1`, imported at `:112` |
| `Get-WorktreeItemCheckpointPath` | `enforce-prd-feature-before-planner.ps1:364` | (i) — same module, same import |
| `Join-WorktreeResolutionPath` | `enforce-prd-feature-before-planner.ps1:400` | (i) — `WorktreeTargetResolution.psm1`, imported at `:111` |
| `Get-WorktreeResolutionNoTargetReasonCode` | `enforce-prd-feature-before-planner.ps1:352` | (ii) — `WorktreeResolution.psm1`, imported by `enforce-prd-feature-before-planner-helpers.ps1:27`, which the parent dot-sources at file scope |
| `Get-WorktreeResolutionAmbiguityReasonCode` | `enforce-prd-feature-before-planner.ps1:372` | (ii) — same route, same import line |
| `ConvertTo-WorktreeResolutionRepoRelativePath` | `enforce-prd-feature-before-planner-helpers.ps1:105` | (i) — `WorktreeResolution.psm1`, imported at `:27` |

**No call falls in category (iii).** That is the condition this record exists to test: module nesting does not re-export, so a call relying on a sibling module's exports reaching it through an importer would not resolve at run time. The two category (ii) calls are sound for the opposite reason — an `Import-Module` inside a dot-sourced file executes in the caller's session state, so the command is present in the parent without the parent importing it.

## AC-24 and AC-25 conditions

| Condition | Result |
| --- | --- |
| `enforce-model-routing-receipt.ps1`, `enforce-pr-author-skill-helpers.ps1`, and `enforce-prd-feature-before-planner.ps1` each import `WorktreeItemResolution.psm1` at column 0, in their own file's existing convention | yes — `-Force -ErrorAction Stop` for the first two, bare `-Force` for the third, all unguarded and none wrapped in `try` or softened with `SilentlyContinue` |
| `enforce-prd-feature-before-planner.ps1` additionally imports `WorktreeTargetResolution.psm1` because it calls `Join-WorktreeResolutionPath` | yes — imported at `:111`, called at `:400` |
| `enforce-pr-author-skill-helpers.ps1` retains both F1 imports for a different and explicitly different reason | yes — recorded above: no call in that file depends on them; its dot-sourcing suites do |
| `enforce-prd-feature-before-planner-helpers.ps1` still imports `WorktreeResolution.psm1` | yes — `:27`, unchanged from the merge base |
| Zero `SilentlyContinue` across all six files | yes — every file returns 0 |
| No function defined in a hook file derives a target, normalises a path, or returns a reason code | yes — every such use is a call into `.claude/lib/worktree-resolution/` or a read of the result's `ReasonCode` property |

Output Summary: All six conditions hold. Every worktree-resolution call in the six files is categorised, and none falls in the unresolvable module-nesting category. The three gates that call the identity resolver each import its module at column 0 unguarded; the prd gate additionally keeps the F1 target-resolution import because it calls the path join that module alone exports; the pr-author helpers keep both F1 imports for their dot-sourcing consumers rather than for any call of their own. Zero `SilentlyContinue` occurrences, and no hook file defines a derivation, a normalisation, or a reason code.
