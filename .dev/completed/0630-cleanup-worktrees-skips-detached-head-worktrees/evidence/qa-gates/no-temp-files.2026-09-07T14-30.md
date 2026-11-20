# QA Gate — Temporary-File Audit of the New Suite (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P7-T7]

Command: `grep -nE "mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|git init" tests/shell/test_cleanup_worktrees_detached.bats | wc -l`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P7-T7] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && grep -nE "mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|git init" tests/shell/test_cleanup_worktrees_detached.bats | wc -l'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`; the real
   worktree is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard. The `grep`/`wc` pipeline was run natively from the worktree
   root with the same flags, the same alternation pattern, and the same target file.

## Raw Output

```
0
```

## What the Zero Means

The alternation covers the four ways a bats suite would reach for scratch state: `mktemp`
for a temporary file or directory, `BATS_TMPDIR` and `BATS_TEST_TMPDIR` for the framework's
own temporary directories, and repository initialization for a scratch repository. A count
of **0** means the new suite `tests/shell/test_cleanup_worktrees_detached.bats` uses none of
them.

This is what `.claude/rules/general-unit-test.md` requires: creation and use of temporary
files in tests is prohibited, and unit tests must not depend on external processes. The new
suite meets that requirement by driving the checked-in git stub through the
`CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` seams against checked-in fixture
scenario directories, so every case reads static committed data and creates nothing.

Output Summary: The command printed **`0`** and exited **0**. The new detached suite
contains **no** occurrence of `mktemp`, `BATS_TMPDIR`, `BATS_TEST_TMPDIR`, or repository
initialization, so it creates no temporary file and no scratch repository. This is the
evidence for AC19.
