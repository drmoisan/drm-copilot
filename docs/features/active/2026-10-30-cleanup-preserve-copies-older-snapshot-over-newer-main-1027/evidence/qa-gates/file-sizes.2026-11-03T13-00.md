# QA Gate: Final File Sizes

Timestamp: 2026-11-03T13-00
Task: [P7-T6]
Command: wc -l of every changed or new `.sh` file under `.claude/skills/cleanup-merged-worktrees/scripts/`, every changed or new `.bats` file under `tests/shell/`, and `tests/fixtures/cleanup_worktrees/stub-bin/git`
EXIT_CODE: 0
Output Summary: no file is at 801 lines or more; the stub is below 500; every production file is at most 500, so no `file-size-justification` artifact is needed.

| File | Baseline | Final | Tier |
|---|---|---|---|
| .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh | new | 234 | below 500 |
| .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh | 492 | 500 | at most 500 |
| .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh | 243 | 256 | below 500 |
| tests/shell/test_cleanup_worktrees_preserve.bats | 471 | 478 | below 500 |
| tests/shell/test_cleanup_worktrees_preserve_eol.bats | 175 | 177 | below 500 |
| tests/shell/test_cleanup_worktrees_preserve_failures.bats | 264 | 311 | below 500 |
| tests/shell/test_cleanup_worktrees_preserve_merge.bats | new | 261 | below 500 |
| tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats | new | 137 | below 500 |
| tests/fixtures/cleanup_worktrees/stub-bin/git | 416 | 451 | below 500 |
