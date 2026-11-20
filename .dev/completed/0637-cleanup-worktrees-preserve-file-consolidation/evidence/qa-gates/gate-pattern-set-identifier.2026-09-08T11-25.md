# Gate — the pattern-set identifier is present in the implementation

Timestamp: 2026-09-08T11-25
Task: `[P7-T13]`
Command: grep -c -F -- cleanup-wt-host-tokens-v1 scripts/bash/cleanup_worktrees_preserve_lib.sh
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: printed count `2`, which is at least 1, and the command exited 0.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -c -F -- cleanup-wt-host-tokens-v1 /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5/scripts/bash/cleanup_worktrees_preserve_lib.sh'"`
- Substitute actually run: the identical `grep -c -F --` invocation executed locally in Git Bash
  against the same file by absolute path. Only the hosting shell differs.
- Reason: the `pwsh`-wrapped WSL form is refused unconditionally in this worktree, and a bare `wsl`
  invocation is prohibited by binding amendment EA-1.

## The two occurrences

1. The header of `preserve_scan_host_tokens`, which states that this library owns the identifier.
2. The advisory comparison in `preserve_plan_one`, which reports
   `ACTION|preserve-scan|<target-path>|PATTERN-SET-MISMATCH` for any other value.

The literal asserted is `cleanup-wt-host-tokens-v1`, a single-line non-interpolated token this work
creates. It supersedes the placeholder `child-f-host-tokens-v1` that the upstream issue carried as
a non-normative example; ownership of the identifier was assigned to this child. The superseded
value is exercised as a mismatch input by the `pattern-set-id/` fixtures, so both the owned value
and a foreign value are covered.

The count was `0` before this work, so the assertion discriminates.

Verdict: PASS.
