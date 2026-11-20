# AC Check-Off — Rulings A, B, and C (10 criteria; spec.md and user-story.md)

Timestamp: 2026-09-17T08:46:51-04:00 (file write time)
Command: per-criterion review against the named evidence, then '- [ ] ' -> '- [x] ' for the lines between '### Rulings A, B, and C' and the next heading in spec.md and user-story.md (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 10 of 10 criteria verified and checked off in both files.

| # | Criterion (abridged) | Verified by |
| --- | --- | --- |
| 1 | Ruling A: relative input, no WorktreeRoot -> unresolved form, never the input unchanged | worktree-resolution-suite: "refuses a relative path with no worktree root and does not echo the input (Ruling A)" |
| 2 | Ruling A complement: relative input with WorktreeRoot -> normalised root and path | worktree-resolution-suite: "normalises a relative path against an explicit worktree root (Ruling A complement)" |
| 3 | Ruling B: no function reads run state; grep for orchestrator-state and checkpoint finds no functional reference | evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md: the four comment-stripped searches return 0 in both modules (re-run after the final repair: 0) |
| 4 | Ruling B: disagreeing signals -> Ambiguous; agreeing signals dedupe and resolve normally | worktree-target-resolution-suite: "ambiguous sub-case: two signals resolving to different worktree roots"; "deduplicates two agreeing signals and reports the higher-precedence kind FeatureFolderPath / FilePath" (Status OtherWorktree, one candidate) |
| 5 | Ruling B: precedence decides only the reported kind; a test shows it never suppresses a disagreement | worktree-target-resolution-suite: the two "deduplicates ... reports the higher-precedence kind" rows; "never lets precedence suppress a disagreement between a relative file path and a branch" |
| 6 | Ruling C: candidate set derived with no git subprocess via .git directory, or .git file gitdir: plus commondir | worktree-resolution-suite: "enumerates the main checkout and its linked worktrees from the main checkout", "includes the main checkout when the session root is a linked worktree", "returns an empty array for a linked worktree whose admin directory has no commondir"; ruling-b-state-read-absence: the git-invocation and Start-Process searches return 0 |
| 7 | Ruling C: candidate set includes the main checkout; test from a linked worktree | worktree-resolution-suite: "includes the main checkout when the session root is a linked worktree" |
| 8 | Ruling C: worktrees/<name>/gitdir read as the path to the worktree's .git file; root is its parent | worktree-resolution-suite: "follows relative pointers, skips admin entries without a gitdir file, and deduplicates roots"; "resolves a linked worktree that is a sibling of the main checkout without a prefix comparison" |
| 9 | Ruling C: exactly one containing worktree for resolved states; two-or-more and zero -> Ambiguous | worktree-target-resolution-suite: "ambiguous sub-case: a relative feature-folder token present in two worktrees" (2 candidates), "... present in no worktree" (0); the resolved "required matrix row" tests assert exactly one candidate |
| 10 | Containment never by string-prefix against one root; test covers a sibling-of-main worktree | worktree-resolution-suite: "resolves a linked worktree that is a sibling of the main checkout without a prefix comparison" (C:/repo-wt/sibling shares the C:/repo text prefix and resolves to itself); containment in code is a per-candidate existence probe through Get-WorktreeResolutionWorktreeRoot -RepoRelativePath |

Evidence files: evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md,
evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md,
evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md.
