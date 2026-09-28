# Gate — the 500-line cap holds for the preserve library and its suite

Timestamp: 2026-09-08T10-30
Task: `[P5-T9]`
Command: wc -l scripts/bash/cleanup_worktrees_preserve_lib.sh scripts/bash/cleanup_worktrees_preserve_eol_lib.sh tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: every per-file count is 500 or fewer. Post-split counts: preserve library 443,
line-ending library 64, preserve suite 399, line-ending suite 80, total 986.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && wc -l scripts/bash/cleanup_worktrees_preserve_lib.sh tests/shell/test_cleanup_worktrees_preserve.bats'"`
- Substitute actually run: the identical `wc -l` invocation executed locally in Git Bash from the
  worktree root. The file list is extended from two names to four because both pre-authorized
  splits were taken in this task; the plan requires every later enumeration of the library and the
  suite to name both files of each pair, in that order.
- Reason: the `pwsh`-wrapped WSL form is refused unconditionally in this worktree, and a bare `wsl`
  invocation is prohibited by binding amendment EA-1.

## Measurement before the split, which is what triggered it

    443 + 46  scripts/bash/cleanup_worktrees_preserve_lib.sh   -> 489 before the split
    427       tests/shell/test_cleanup_worktrees_preserve.bats

The library stood at **489**, above this task's 460 trigger and eleven lines below the hard cap,
with the host-token pattern set and its pre-pass still to be added in Phase 7. The suite stood at
**427**, below the 460 trigger.

## Measurement after the split

    443 scripts/bash/cleanup_worktrees_preserve_lib.sh
     64 scripts/bash/cleanup_worktrees_preserve_eol_lib.sh
    399 tests/shell/test_cleanup_worktrees_preserve.bats
     80 tests/shell/test_cleanup_worktrees_preserve_eol.bats
    986 total

Every per-file count is at or below 500. The exit code of the `wc -l` invocation is 0.

Verdict: PASS.
