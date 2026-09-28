# AC Check-Off — Path normalisation and composition (6 criteria; spec.md and user-story.md)

Timestamp: 2026-09-17T08:47:07-04:00 (file write time)
Command: per-criterion review against the named evidence, then '- [ ] ' -> '- [x] ' for the lines between '### Path normalisation and composition' and the next heading in spec.md and user-story.md (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 6 of 6 criteria verified and checked off in both files.

| # | Criterion (abridged) | Verified by |
| --- | --- | --- |
| 1 | ConvertTo-WorktreeResolutionRepoRelativePath returns the five-field object; ReasonCode set exactly when not normalised | worktree-resolution-suite: the five "repo-relative normalisation" tests assert the fields for normalised results (ReasonCode null) and for the three unnormalised forms (ReasonCode = TARGET_WORKTREE_AMBIGUOUS) |
| 2 | Absolute path in a locatable worktree -> full remainder, prefix recovered into WorktreeRoot | worktree-resolution-suite: "keeps a remainder deeper than four segments intact and recovers the absolute prefix" (WorktreeRoot C:/repo-wt/session, remainder docs/features/active/item-700/v1/spec.md) |
| 3 | No fixed segment-count truncation anywhere; a test keeps a remainder deeper than four segments | the same test (six-segment remainder); module source contains no segment slicing (the remainder is `Substring($root.Length)` of the located root; `Get-WorktreeResolutionParentPath` is the ascent step only); worktree-target-resolution-suite: "join composes an absolute path from a remainder deeper than four segments" |
| 4 | Forward slashes, no trailing slash, no leading ./ | worktree-resolution-suite: the seven "normalises ..." rows and "normalises a relative path against an explicit worktree root (Ruling A complement)" |
| 5 | Find-WorktreeResolutionFeatureFolderSignal preserves an absolute prefix | worktree-target-resolution-suite: "preserves the absolute prefix of a Windows-style feature-folder path" |
| 6 | Join-WorktreeResolutionPath returns an absolute forward-slash path | worktree-target-resolution-suite: four "join composes an absolute path from ..." rows and "refuses a relative worktree root" |

Evidence files: evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md,
evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md,
evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md.
