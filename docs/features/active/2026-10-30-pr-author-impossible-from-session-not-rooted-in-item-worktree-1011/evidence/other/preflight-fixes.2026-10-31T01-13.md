# Preflight Fixes (issue #1011, second preflight after revision 0.3)

Timestamp: 2026-10-31T01-13
Plan: docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/plan.2026-10-30T08-09.md

All fixes are in task text only. No task was added, removed, or reordered, and no checkbox was changed.

## Fix 1 - [P5-T2] brief replacement text understated the branch signals the gate resolves

- Defect class: validator-blind factual wording defect whose correction keeps the assertion's meaning (trivial).
- Finding: P3-T3 calls `Resolve-HookTargetWorktree` whenever `Find-WorktreeResolutionBranchSignal` returns a branch. That function's pattern (`$script:BranchPattern` in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`) matches `--head`, `--branch`, and a `branch:` label, so a `gh pr edit` command carrying the `# branch: <branch>` comment also reaches the shared resolver. The brief sentence that P5-T2 writes stated that the gate resolves only "the `--head` branch of `gh pr create`" through the resolver and keeps portable-identity resolution otherwise, which would record an inaccurate fact in all six brief copies.
- Change: the sentence now reads "The PR authoring gate (#1011) resolves the branch that a `gh pr create` or `gh pr edit` command names (`--head`, `--branch`, or a `branch:` label) through the same resolver and otherwise keeps its portable-identity and current-branch resolution." The asserted tokens are unchanged: `The PR authoring gate (#1011)` still appears once per copy, `until #1010` is still absent, and the edit still replaces one physical line per copy.
