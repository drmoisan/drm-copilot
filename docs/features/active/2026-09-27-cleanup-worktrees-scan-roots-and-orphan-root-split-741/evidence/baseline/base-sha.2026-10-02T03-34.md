# P0-T3 BASE_SHA and clean pre-edit state

Timestamp: 2026-10-02T03-34
Command: git fetch origin main; git rev-parse HEAD; git merge-base origin/main HEAD; git diff --name-only origin/main...HEAD -- .claude/skills/cleanup-merged-worktrees extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees tests/shell tests/fixtures/cleanup_worktrees; git status --porcelain -- .claude/skills/cleanup-merged-worktrees extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees tests/shell tests/fixtures/cleanup_worktrees
EXIT_CODE: 0
Output Summary:
- git fetch origin main: exit=0.
- git rev-parse HEAD: exit=0; df5eb303129a30289a7d81775fdadaa40631be63. BASE_SHA = df5eb303129a30289a7d81775fdadaa40631be63.
- git merge-base origin/main HEAD: exit=0; 71f8dcb49d8ce5d1402ff441855a64be15b37f29 (equal to origin/main at fetch time).
- three-dot diff (scripts, mirrors, tests/shell, fixtures): exit=0; no output.
- status --porcelain (same pathspec): exit=0; no output.
- Result: PASS. The branch carries no script, test, or fixture change relative to its merge base, and the tree is clean for every path the plan edits.

Deviation DEV-1 (merge / BASE_SHA): origin/main 71f8dcb4 was merged into BRANCH before execution (merge commit df5eb303129a30289a7d81775fdadaa40631be63, already pushed). The plan's planning-time merge base was 72d7ebbf. Verification command for the merge's effect on the plan's paths:
- git diff --stat 72d7ebbf 71f8dcb4 -- .claude/skills/cleanup-merged-worktrees extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees tests/shell tests/fixtures/cleanup_worktrees: exit=0; two files changed, `tests/shell/parallel_lane_assertion.bats` (+37) and `tests/shell/test_shell_qc_commands.bats` (+34). Neither is in the plan write list or in TARGETED-SET.
- git diff --stat 72d7ebbf 71f8dcb4 -- scripts/bash: `scripts/bash/kcov_trace_env.sh` (+9, new) and `scripts/bash/shell_qc_lib.sh` (+19 -2). run_test now runs bats under BASH_ENV=scripts/bash/kcov_trace_env.sh (kcov-equivalent PS4 xtrace). Consequence: a child shell that sources a nounset-enabling library at its top level fails under shell-qc and in CI kcov. NEW-SUITE keeps every source of the scan helper inside a function (plan D6).
