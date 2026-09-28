# AC Check-Off — Reason code (3 criteria; spec.md and user-story.md)

Timestamp: 2026-09-17T08:47:15-04:00 (file write time)
Command: per-criterion review against the named evidence, then '- [ ] ' -> '- [x] ' for the lines between '### Reason code' and the next heading in spec.md and user-story.md (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 3 of 3 criteria verified and checked off in both files.

| # | Criterion (abridged) | Verified by |
| --- | --- | --- |
| 1 | Get-WorktreeResolutionAmbiguityReasonCode returns exactly TARGET_WORKTREE_AMBIGUOUS, pinned by a test | worktree-resolution-suite: "returns the exact ambiguity literal from the accessor" (`Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'`); "declares the literal once as a script-scope constant" |
| 2 | The code carries no _BLOCKED suffix | worktree-resolution-suite: "returns the exact ambiguity literal from the accessor" asserts `EndsWith('_BLOCKED')` is false |
| 3 | Detail concatenates after a gate token; a test shows the concatenation carries both tokens | worktree-target-resolution-suite: "concatenates into a gate deny reason carrying both tokens" (`'PRD_FEATURE_BLOCKED: ' + ReasonCode + ' - ' + Detail`) |

Evidence files: evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md,
evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md.
