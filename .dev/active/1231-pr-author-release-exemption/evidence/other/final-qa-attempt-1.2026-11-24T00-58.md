# Final QA Attempt 1: Pester Gate Failure (issue #1231)

Timestamp: 2026-11-24T00-58
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run with coverage)
EXIT_CODE: 1
Output Summary:
- workers=8; wall-clock=672.37s; shard 2 exited non-zero, so no merged JUnit or coverage artifact was written.
- Shard totals: 3651, 4495 (1 failed), 4288, 3083, 3084, 3694, 3045, 3929 passed.
- Failing test: `enforce-pr-author-command-allowlist.ps1 (issue #824).AL-34 allows every command form the receipt procedure names` (tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1).
- Cause: the new `## Checkpoint-Free Release Delegation (issue #1231)` section of .agents/skills/pr-author/SKILL.md (generated to .claude/skills/pr-author/SKILL.md) named the inline code span `git push`; AL-34 requires every git/gh/sha256sum/date code span in the pr-author agent and skill to be a command the pr-author allowlist accepts, and pr-author may not run `git push`.
- Fix: the sentence was reworded to "immediately after the branch is pushed to origin" with no code span. The generated targets and bundle copies are regenerated and the final QA loop restarts from the format step. The suite is unchanged.
