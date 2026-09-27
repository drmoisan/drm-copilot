# Binding Removal: AC-7 and AC-8 (issue #673)

Timestamp: 2026-09-19T19-08

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-p10t1.ps1` (route `a`). The script parses each of the five in-scope hook files with `[System.Management.Automation.Language.Parser]::ParseFile`, classifies every occurrence of the checkpoint filename as a string expression (code) or not (comment), and enumerates every call to a path-composing function across those five files and the identity module.

EXIT_CODE: 0

## Checkpoint-filename occurrences

| Classification | Count |
| --- | --- |
| Code (a string expression a reader could use) | **0** |
| Comment (prose naming the file) | **0** |

Zero code matches, which is the acceptance condition. There are also zero comment matches, so no file among the five names the checkpoint by filename at all; the list of comment matches this artifact would otherwise carry is empty. Classification is by parse tree rather than by line shape: a comment is not a string expression, so prose could have been distinguished from a usable value, but none of either kind remains.

The five files scanned are the four of the plan's §2.6 plus the prd-feature gate:

- `.claude/hooks/enforce-pr-author-skill.ps1`
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
- `.claude/hooks/enforce-model-routing-receipt.ps1`
- `.claude/hooks/enforce-prd-feature-before-planner.ps1`

## Every branch that can yield a checkpoint path

| Function | Branch | Outcome |
| --- | --- | --- |
| `Get-PrAuthorTargetCheckpointResolution` | `SessionRoot` or `OtherWorktree` (one merged branch) | returns `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot`, at `enforce-pr-author-skill-helpers.ps1:111` |
| `Get-PrAuthorTargetCheckpointResolution` | default (`NoTarget`, `Ambiguous`) | returns a null path and a deny reason carrying `$target.ReasonCode`; no path is composed |
| `Get-ModelRoutingTargetCheckpointResolution` | `SessionRoot` or `OtherWorktree` (one merged branch) | returns `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot`, at `enforce-model-routing-receipt.ps1:189` |
| `Get-ModelRoutingTargetCheckpointResolution` | default (`NoTarget`, `Ambiguous`) | returns a null path and a deny reason carrying `$target.ReasonCode`; no path is composed |
| `Invoke-PrdFeatureBeforePlannerDecision` | the DD-7 candidate-count branch | passes `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot` to the checkpoint reader, at `enforce-prd-feature-before-planner.ps1:364`. The branch runs only when the cited-candidate count is not exactly one, so a single cited folder reaches no checkpoint read at all |
| `Resolve-WorktreeItemTarget` | every return | builds a result through the sibling constructor and composes no checkpoint path; the module's only composition is inside `Get-WorktreeItemCheckpointPath` itself |

Every branch that yields a checkpoint path yields it through `Get-WorktreeItemCheckpointPath` applied to a resolved `WorktreeRoot`, and no branch yields one any other way.

## Every path-composing call site

| Location | Function | Call text |
| --- | --- | --- |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1:111` | `Get-WorktreeItemCheckpointPath` | `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot` |
| `.claude/hooks/enforce-model-routing-receipt.ps1:189` | `Get-WorktreeItemCheckpointPath` | `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot` |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1:364` | `Get-WorktreeItemCheckpointPath` | `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot` |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1:400` | `Join-WorktreeResolutionPath` | `Join-WorktreeResolutionPath -WorktreeRoot $target.WorktreeRoot -RepoRelativePath $folderNormalized` |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:75` | `Join-WorktreeResolutionPath` | `Join-WorktreeResolutionPath -WorktreeRoot $WorktreeRoot -RepoRelativePath (Get-WorktreeItemCheckpointRelativePath)` |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:168` | `Get-WorktreeItemCheckpointPath` | `Get-WorktreeItemCheckpointPath -WorktreeRoot $WorktreeRoot` |

Six call sites, and every one composes beneath a `WorktreeRoot`. Four take it from `$target.WorktreeRoot`, which only a resolved result carries; the other two are inside the identity module and take it from their own parameter. The fourth row composes a **feature-folder** probe path rather than a checkpoint path, and is the DD-8 probe anchoring that `[P10-T3]` records as the reason the prd gate keeps both library imports.

Output Summary: Zero code matches of the checkpoint filename across all five in-scope hook files, and zero comment matches as well, so the list of comment occurrences is empty rather than merely short. Every branch of the three resolution mappings and of the identity resolver is enumerated with its outcome, and no branch yields a checkpoint path other than through `Get-WorktreeItemCheckpointPath` of a resolved `WorktreeRoot`. All six path-composing call sites in the change set are listed, each composing beneath a worktree root.
