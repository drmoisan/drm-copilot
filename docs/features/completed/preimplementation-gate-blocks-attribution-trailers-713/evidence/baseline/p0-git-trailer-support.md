# P0-T8 Git Trailer Support and Residual-Risk Record

Timestamp: 2026-09-27T03-20
Command: git version
EXIT_CODE: 0
Output Summary: `git version` printed `git version 2.53.0.windows.1` and exited 0. The version is at least 2.32.0, so `git commit --trailer` is supported. The configuration query `git config --get-regexp '^trailer\.'` printed nothing and exited 1, so no `trailer.*` key is configured. Primary command substituted per deviation X3 (`evidence/other/execution-deviations.md`) after the original `git --version` was denied by a hook (history below).

CONFIG_QUERY_EXIT_CODE: 1
GIT_VERSION: 2.53.0
TRAILER_OPTION_SUPPORTED: True
TRAILER_CONFIG: none

Raw output of the primary command:

```text
git version 2.53.0.windows.1
```

## History: first attempt (2026-09-27T03-15, previous executor run)

The plan's original primary command `git --version` was denied twice (initial call and one identical retry) by the PreToolUse hook `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, which classified the text as a `git worktree remove` invocation with an empty operand. The run stopped as BLOCKED per plan rule 10. The configuration query ran on that attempt and also exited 1.

Hook denial (verbatim, identical on both attempts):

```text
PARALLEL_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '' requires a matching parallel checkpoint items[] record with merge_status in {merged, worktree_removed}. The checkpoint was unreadable, no matching record was found, or merge_status was not yet safe for removal.
```

Analysis (read-only inspection, no workaround attempted on that run):

- Denying hook: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, function `Invoke-ParallelWorktreeRemovalGateDecision`. Its scope filter calls `Test-CommandLineInvocation -CommandText $commandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove')`. For the command text `git --version` that filter evidently returned true (the deny reason reports an empty worktree path), and the fail-closed checkpoint lookup then denied.
- The command is read-only and contains neither `worktree` nor `remove`, so this appears to be a false positive in the shared invocation matcher for a git command whose first word after `git` is a long option with no subcommand. Not verified by running the matcher.
- Resolution: orchestrator-approved deviation X3 substituted `git version`. The defect is recorded as an out-of-scope follow-up in `evidence/other/follow-ups.md`.
