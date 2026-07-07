# Acceptance Criteria Verification (P6-T10)

Timestamp: 2026-07-07T12-48
Issue: #328
AC sources (full-feature mode): spec.md and user-story.md — all 9 criteria checked off in both.

| AC | Criterion (abbreviated) | Implemented by | Verified by (tests) | Evidence | Status |
|---|---|---|---|---|---|
| AC1 | New worktrees at `<parent>/<repoName>-wt/<yyyy-MM-ddTHH-mm>` | PS Build-WorktreePath + Get-WorktreeGroupDirectory (script+template); TS buildWorktreePath + buildWorktreeGroupDirectory | Pester "full path matches expected nested format"; Jest "composes the nested repoName-wt/timestamp path" + extension setLocation regex `C:/workspace-wt/\d{4}-\d{2}-\d{2}T\d{2}-\d{2}` | phase1-poshqc-loop, phase3-ts-loop, final-ts-test-coverage | PASS |
| AC2 | Grouping dir created when missing, before `git worktree add`, idempotent | PS New-WorktreeParentDirectory (seam, ShouldProcess) invoked before Invoke-GitWorktreeAdd; TS ensureParentDirectory field sent before commands.git in both handlers | Pester New-WorktreeParentDirectory seam/idempotence/-WhatIf + ordering test; Jest ensureParentDirectory command + ordering (ensureParent before git) in claude/codex/extension tests | phase1-poshqc-loop, phase3-ts-loop | PASS |
| AC3 | Timestamp `yyyy-MM-ddTHH-mm` in both formatters, cross-toolchain fixed fixture | PS Get-WorktreeTimestamp format string; TS formatWorktreeTimestamp T separator | Pester timestamp test (2026-04-20T09-59); Jest formatter tests + cross-toolchain parity test naming the Pester counterpart | phase1-poshqc-loop, phase3-ts-loop | PASS |
| AC4 | Branch remains flat `<repoName>-wt-<timestamp>` (no slash) | Build-BranchName / buildBranchName unchanged in structure | Pester flat-branch + no-slash test; Jest buildBranchName flat + no-slash; extension `-b 'workspace-wt-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}'` and terminal-name regexes | phase1-poshqc-loop, phase3-ts-loop | PASS |
| AC5 | Remove Secondary Worktrees discovers/removes nested-scheme worktrees | No discovery-logic change | Jest runner test "discovers and removes nested-scheme secondary worktrees unchanged" (nested porcelain fixtures) | phase4-ts-loop | PASS |
| AC6 | Emptied `-wt` parent removed and reported; non-empty never removed; primary never removed | remove-worktrees.ts pure classifier + summary; remove-worktrees-runner.ts seam + cleanup | Jest classifier positive/negatives (non-empty, non-`-wt`, primary path, primary parent); runner seam tests (removed+reported, non-empty preserved, seam not invoked when nothing removed); summary message tests | phase4-ts-loop | PASS |
| AC7 | workspace-encoding matcher resolves new scheme, no logic change; additive tests; old-scheme retained | Doc-comment-only change (logic byte-identical) | Jest 3 additive new-scheme tests (sibling, worktree-of-worktree, exact-equality leaf); existing old-scheme tests unmodified | phase5-ts-loop | PASS |
| AC8 | Script and bundled template produce scheme identically (lockstep parity) | Identical edits applied to both files | Pester template-parity test; git diff --no-index exit 0 | phase1-poshqc-loop, other/template-parity | PASS |
| AC9 | All affected tests updated; new behavior covered; line >=85% / branch >=75% | All test tasks P1-P5 | Full suites: Pester 1071 pass; Jest 1555 pass | coverage-delta (TS lines 96.58%, branches 88.5%; changed files all above thresholds; PS line 93.67%) | PASS |

## Notes / Findings (follow-up, not remediated in this cycle)
- PowerShell branch coverage is not emitted by the repo Pester config (CoverageGutters format), and the changed file scripts/dev-tools/new-claude-worktree-session.ps1 is outside the config's explicit CodeCoverage.Path allow-list, so it is not in the measured PowerShell coverage denominator. Behavior is fully covered by the Pester suite (8 new passing tests). This is a pre-existing repo configuration, unchanged by this plan.

All 9 acceptance criteria are checked off in spec.md and user-story.md.
