# Phase 1 Suite Run Record — WorktreeResolution.Tests.ps1

Timestamp: 2026-09-17T08:16:56-04:00
Command: $r = Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1' -PassThru; $r.PassedCount; $r.FailedCount; $r.SkippedCount; $r.Passed.ExpandedPath
EXIT_CODE: 0
Output Summary: PassedCount=48, FailedCount=0, SkippedCount=0. The passed set contains one name with the phrase "sibling of the main checkout" ([P1-T8]), one with "deeper than four segments" ([P1-T9]), and one with "MaximumDepth guard" ([P1-T7]).

## Counts

- PassedCount: 48
- FailedCount: 0
- SkippedCount: 0

## Passed tests (full names, verbatim)

```text
WorktreeResolution seam default bodies.classifies an existing directory, an existing file, and an absent path
WorktreeResolution seam default bodies.reads the raw text of a tracked file and returns null for an absent file
WorktreeResolution seam default bodies.lists child directory names as an array, empty for an absent directory
WorktreeResolution.path normalisation.normalises a backslash path to C:/repo/docs/features
WorktreeResolution.path normalisation.normalises a forward-slash path to C:/repo/docs/features
WorktreeResolution.path normalisation.normalises mixed and repeated separators to C:/repo/docs/features
WorktreeResolution.path normalisation.normalises a trailing slash to C:/repo/docs
WorktreeResolution.path normalisation.normalises a leading ./ segment to docs/features
WorktreeResolution.path normalisation.normalises the filesystem root to /
WorktreeResolution.path normalisation.normalises a UNC share to //server/share/repo
WorktreeResolution.path normalisation.returns null for a null input
WorktreeResolution.path normalisation.returns null for an empty input
WorktreeResolution.path normalisation.returns null for a whitespace input
WorktreeResolution.path normalisation.returns null for a bare ./ input
WorktreeResolution.root marker.treats a .git directory as a root marker
WorktreeResolution.root marker.treats a .git file with a well-formed gitdir line as a root marker
WorktreeResolution.root marker.rejects a .git file whose text is malformed
WorktreeResolution.root marker.rejects a .git file whose text is empty
WorktreeResolution.root marker.rejects a .git file whose text is unreadable
WorktreeResolution.root marker.rejects a level with no .git entry and an empty level
WorktreeResolution.upward ascent.returns the input itself when it is a root (depth 0)
WorktreeResolution.upward ascent.ascends several levels to the nearest root (depth greater than 0)
WorktreeResolution.upward ascent.returns null after probing the drive root when no marker exists
WorktreeResolution.upward ascent.returns null after probing the filesystem root for a slash-rooted path
WorktreeResolution.upward ascent.stops at the MaximumDepth guard before reaching a distant root
WorktreeResolution.upward ascent.refuses a relative input without probing the filesystem
WorktreeResolution.worktree enumeration.enumerates the main checkout and its linked worktrees from the main checkout
WorktreeResolution.worktree enumeration.includes the main checkout when the session root is a linked worktree
WorktreeResolution.worktree enumeration.resolves a linked worktree that is a sibling of the main checkout without a prefix comparison
WorktreeResolution.worktree enumeration.returns a single-element array when the admin directory holds no linked worktree
WorktreeResolution.worktree enumeration.returns an empty array for a session root with no .git entry
WorktreeResolution.worktree enumeration.returns an empty array for an empty session root
WorktreeResolution.worktree enumeration.returns an empty array for a linked worktree whose admin directory has no commondir
WorktreeResolution.worktree enumeration.returns an empty array for a .git file with no gitdir line
WorktreeResolution.worktree enumeration.follows relative pointers, skips admin entries without a gitdir file, and deduplicates roots
WorktreeResolution.worktree enumeration.omits the main checkout when the common directory is not a .git directory
WorktreeResolution.worktree enumeration.filters candidates by branch feature/item-700
WorktreeResolution.worktree enumeration.filters candidates by branch main
WorktreeResolution.worktree enumeration.filters candidates by branch feature/absent
WorktreeResolution.worktree enumeration.filters candidates to those containing a repo-relative path
WorktreeResolution.repo-relative normalisation.keeps a remainder deeper than four segments intact and recovers the absolute prefix
WorktreeResolution.repo-relative normalisation.normalises a relative path against an explicit worktree root (Ruling A complement)
WorktreeResolution.repo-relative normalisation.refuses a relative path with no worktree root and does not echo the input (Ruling A)
WorktreeResolution.repo-relative normalisation.marks an absolute path with no .git entry on the ascent as not normalised with the ambiguity reason code
WorktreeResolution.repo-relative normalisation.marks an empty path as not normalised with the ambiguity reason code
WorktreeResolution.repo-relative normalisation.returns an empty remainder for the worktree root itself
WorktreeResolution.reason code.returns the exact ambiguity literal from the accessor
WorktreeResolution.reason code.declares the literal once as a script-scope constant
```
