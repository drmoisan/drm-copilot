# Stub Size and Index-Write Arm Absence

Timestamp: 2026-09-07T20-48
Task: [P1-T11]
Issue: #632

## Command form actually used (execution amendment EA-1)

The plan's command block is written as bare `wsl -d Ubuntu -- bash -lc '... && wc -l ... && grep -c ...'`, naming the preparation worktree. The same two measurements were taken under Git Bash with the working directory set to this worktree root.

Command: `wc -l tests/fixtures/cleanup_worktrees/stub-bin/git; grep -c "write-tree" tests/fixtures/cleanup_worktrees/stub-bin/git`
EXIT_CODE: 1
ExpectedExitCode: 1

`grep -c` exits 1 when the count it prints is zero, so exit 1 is the passing outcome for this gate and exit 0 would mean a match was found.

## Results

```
362 tests/fixtures/cleanup_worktrees/stub-bin/git
0
```

- `wc -l` value: 362, which is at or under the 500-line cap in `.claude/rules/shell.md`.
- `grep -c "write-tree"` value: 0.

## Note on how the zero count was reached

An earlier draft of the header comment stated the deliberate omission in prose using the literal itself, which made this count 1 and failed the gate for a documentary reason rather than a behavioral one. The paragraph was rewritten to state the same constraint without the literal: it now says no arm is defined for any subcommand that writes to the index or the object database, and names the assertion in `tests/shell/test_cleanup_worktrees_dirt_clear.bats` that the omission protects. The constraint is therefore still recorded for a later reader, and the count is genuinely zero.

A non-zero count would mean an arm for an index-writing subcommand was added, which would make the report-mode non-mutation assertion in [P5-T9] unable to fail.

Output Summary: The stub is 362 lines, within the 500-line cap, and defines no arm whose name matches the index-write literal the non-mutation assertion searches for. Both values are as the gate requires.
