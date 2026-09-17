# File 1 Physical Line Count

Timestamp: 2026-09-17T08:16:43-04:00 (file write time)
Command: @(Get-Content -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1').Count
EXIT_CODE: 0
Output Summary: before count 521 (above the 480 plan ceiling and the 500 enforced cap); the sanctioned seam-help reduction and a further compaction pass were applied; final count 480, which is at the 480 plan ceiling and under 500. No third module file was created and Get-WorktreeResolutionAmbiguityReasonCode was not relocated. The File 1 suite still reports 48 passed, 0 failed after the reduction.

## Before

521 physical lines (2026-09-17T08:14:52-04:00).

## Reduction applied

1. Sanctioned pass (plan [P1-T10]): the help blocks of the three seams were reduced to a `.SYNOPSIS`
   and a `.PARAMETER` entry each (the `.DESCRIPTION` sections of `Get-WorktreeResolutionGitFileText`
   and `Get-WorktreeResolutionDirectoryChildName` were folded into their synopsis lines;
   `Get-WorktreeResolutionGitEntryKind` already had that shape). Result: approximately 516 lines, still
   above 500.
2. Additional compaction pass (recorded as a deviation, because the sanctioned pass alone could not
   reach the enforced 500-line cap): shorter help and comment text on
   `ConvertTo-WorktreeResolutionNormalizedPath`, `Test-WorktreeResolutionRootMarker`,
   `Find-WorktreeResolutionRoot`, `Get-WorktreeResolutionWorktreeRoot`,
   `ConvertTo-WorktreeResolutionRepoRelativePath`, `Get-WorktreeResolutionAmbiguityReasonCode`, and the
   private common-directory helper; merged guard clauses in the private join, parent-path, and
   segment-collapse helpers and in `Test-WorktreeResolutionRootMarker`; the private normalisation
   result factory rewritten as a single hashtable literal; blank lines between parameters removed.
   Behaviour is unchanged: the full suite re-ran with 48 passed and 0 failed.

## After

480 physical lines. The final count is at most 480 and under 500.
