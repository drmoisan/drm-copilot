# P6-T9 Source Tokens (issue #927, AC-5, AC-6, AC-7, AC-11, AC-M2, AC-M10, AC-M14, AC-M17, AC-M21 source halves; loop pass 2)

Timestamp: 2026-10-16T04-49
Command: grep -c '^function ' .claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: Every grep of the acceptance conditions of [P2-T1], [P2-T9], [P3-T1] to [P3-T9], [P4-T1] to [P4-T9], [P4-T13], and [P4-T14] was rerun against the current tree, and every count and printed line equals the value its task states (63 checks, 0 mismatches). Commands whose text named the version-control executable inside a loop were refused by the worktree isolation guard and were rerun as individual grep commands with identical patterns.

## [P2-T1] / [P2-T9] helper (.claude/hooks/hook-docs-only-diff.ps1)

- '^function ' -> 8; six named functions -> 6; 'did not return NUL-terminated output' -> 1; 'EndsWith([char]0)' -> 1; "'fetch'" -> 0; 'Get-Content' -> 0; 'Import-Module' -> 0; dot-source regex -> 0; lines -> 397
- GitInvoker declaration -> 1; GhInvoker declaration -> 1; '& $GitInvoker -C $WorktreeRoot @GitArgs' -> 1; '& $GhInvoker @GhArgs' -> 1; '.PARAMETER GitInvoker' -> 1; '.PARAMETER GhInvoker' -> 1; 'GitCommand' -> 0; 'GhCommand' -> 0

## [P3-T1] to [P3-T8] (.claude/hooks/enforce-pr-author-skill.docs-only.ps1)

- `grep -A 1 -x -F -e 'param()'` -> `param()` then `. (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1')`; 'hook-docs-only-diff.ps1' -> 2
- GitInvoker declaration -> 1; '.PARAMETER GitInvoker' -> 1
- '& $GitInvoker -C $WorktreeRoot @GitArgs' -> 1; '& git -C' -> 0; '-GitInvoker' -> 0; 'GitCommand' -> 0
- "StartsWith('-B'" -> 0; "StartsWith('GH_REPO='" -> 1; "StartsWith('--repo='" -> 1
- E3 reason text -> 1; 'the -B short form is not read' -> 0
- 'Get-DocsOnlyDiffTextViolation -DiffText ([string]$diff.Output) -BaseName $base' -> 1; 'Get-PrAuthorDocsOnlyPathViolation -Path' -> 0
- 'function ConvertFrom-PrAuthorDocsOnlyNameList' -> 0; 'function Get-PrAuthorDocsOnlyPathViolation' -> 0; 'function Invoke-PrAuthorDocsOnlyGitExe' -> 1; 'Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot' -> 2; 'Invoke-DocsOnlyGitExe' -> 0; 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED' -> 0
- 'no inline GH_REPO= prefix.' -> 1; 'and non-empty output ends with NUL.' -> 1; 'Residual limit:' -> 1; 'token has B or R among its letters' -> 1; 'no -B token' -> 0; lines -> 224

## [P3-T9] (.claude/hooks/enforce-pr-author-skill.ps1)

- 'no inline GH_REPO= prefix);' -> 1; 'single-dash token whose letters include B or R' -> 1; 'repository override is present, or' -> 1; 'returns output not ending with NUL.' -> 1; 'and no -B token;' -> 0; lines -> 359

## [P4-T1] (.claude/hooks/enforce-epic-merge-gate-resolution.ps1)

- 'function Test-EpicMergeGateNoRecordingTarget' -> 1; 'Test-EpicMergeGateNoRecordingTarget, the precondition' -> 1; lines -> 278

## [P4-T2] to [P4-T4] (.claude/hooks/enforce-epic-merge-gate.ps1)

- "Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1'" -> 1
- 'Test-EpicMergeGateNoRecordingTarget -ItemTarget $itemTarget' -> 1; Get-DocsOnlyMergeExemption call -> 1; '$standalone.Message + $docsOnlySuffix)' -> 1; "' (docs-only exemption not applied: '" -> 1
- 'rather than shelling out live' -> 0; 'conditions M1-M9' -> 1; 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED' -> 1; 'The hook never fetches' -> 1; lines -> 490

## [P4-T5] to [P4-T9] (.codex/hooks/enforce-epic-merge-gate.ps1)

- 'operator decision OD-1' -> 1; 'conditions M1-M9' -> 1; 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED' -> 1
- "Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1'" -> 1
- '[AllowNull()][AllowEmptyString()][string] $RepositoryRoot' -> 1
- '-WorktreeRoot $RepositoryRoot' -> 1; '$verdict.Message + $docsOnlySuffix' -> 1; 'IsNullOrWhiteSpace($ChildCheckpointRaw) -and' -> 1
- '-RepositoryRoot $repositoryRoot' -> 1; lines -> 410

## [P4-T13] / [P4-T14] manifests

- '".claude/hooks/hook-docs-only-diff.ps1",' in the Claude core.json -> 1
- '".codex/hooks/hook-docs-only-diff.ps1",' in the Codex core.json -> 1

MISMATCHES: 0
