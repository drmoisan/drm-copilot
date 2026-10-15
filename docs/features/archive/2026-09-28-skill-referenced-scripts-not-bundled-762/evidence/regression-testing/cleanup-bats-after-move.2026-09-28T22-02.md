# cleanup-worktrees bats Suites After the Move (P2-T13)

Timestamp: 2026-09-28T22-02
Command: sh SCRATCH/run-bats.sh tests/shell/test_cleanup_worktrees_*.bats
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: TAP plan `1..245` (19 suites run against the scripts at `.claude/skills/cleanup-merged-worktrees/scripts/`). Exactly two `not ok` lines, both members of KL-SHELL-2 (the local-WSL baseline failures recorded at shell-qc-full.2026-09-28T19-10.txt lines 4538 and 5182). No other test failed.

```text
not ok 95 dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative control)
not ok 117 dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened non-mutation assertion fail (negative control)
```
