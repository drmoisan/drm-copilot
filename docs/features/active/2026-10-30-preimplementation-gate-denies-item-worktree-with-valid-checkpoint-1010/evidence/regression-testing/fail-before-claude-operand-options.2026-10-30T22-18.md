# Fail-Before: Claude Operand-Option Rows (Issue #1010, remediation cycle 1, P1-T4) [expect-fail]

Timestamp: 2026-10-30T22-18
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-r1-s1.txt -NoCoverage (Invoke-PoshQCTest over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1 before any production change, Run.Exit off; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: 42 tests, 30 passed, 12 failed. Failing: T15, B11, B12, B14, and eight B10 cases. Passing new rows: B10 `-C HEAD`, `-c HEAD`, and `-F msg.txt`, and B13. All 26 pre-existing rows pass. Two outcomes differ from the P1-T4 prediction (B10 `-F msg.txt` passes, B12 fails); the cause is recorded below.

## Failing Rows (JUnit)

1. B10 collects an absolute pathspec after the value-taking commit option -m msg
2. B10 collects an absolute pathspec after the value-taking commit option --message msg
3. B10 collects an absolute pathspec after the value-taking commit option --message=msg
4. B10 collects an absolute pathspec after the value-taking commit option -mmsg
5. B10 collects an absolute pathspec after the value-taking commit option --file msg.txt
6. B10 collects an absolute pathspec after the value-taking commit option --author Sample
7. B10 collects an absolute pathspec after the value-taking commit option --author=Sample
8. B10 collects an absolute pathspec after the value-taking commit option --date now
9. B11 collects an absolute pathspec after git add --pathspec-from-file <value>
10. B12 does not collect the absolute value of a value-taking option
11. B14 collects an absolute pathspec after a standalone flag and after --
12. T15 admits git commit -m msg <abs file> against a ready item checkpoint, reading the item checkpoint

## Passing New Rows

- B10 `-C HEAD` and B10 `-c HEAD`: expected passes, as predicted. The git global option table returned by `Get-CommandLineGlobalOption` lists `-C` and `-c` as value options, and `Get-CommandLineInvocationOperand` applies that table after the subcommand.
- B13 does not collect a path after an unmodeled option: expected pass, as predicted.
- B10 `-F msg.txt`: passes, which differs from the prediction.

## Deviation From the P1-T4 Prediction

`Get-CommandLineInvocationOperand` (in `hook-command-invocation.ps1`) tests option names with the case-insensitive `-contains` operator. The generic standalone-flag list `$script:CommandLineStandaloneFlagNames` holds `-f` (`--force`), so the current collector treats `git commit -F <value>` as the standalone flag `-f` and collects the following token as an operand:

- `git commit -F msg.txt <abs file>`: `msg.txt` is relative and dropped, `<abs file>` is collected, so B10 `-F msg.txt` passes before the fix.
- `git commit -F <abs>/msg.txt`: the message file is collected as a pathspec, so B12 fails before the fix. This is a pre-existing collection error of the same class F2 addresses (an option value read as a pathspec).

The P1-T4 acceptance condition, which lists every B10 case except `-C HEAD` and `-c HEAD` as failing and B12 as passing, is therefore not met as written. The fail-before evidence for F2 stands: T15, B11, B14, and eight of the eleven B10 cases fail on the unmodified tree, and B12 additionally fails on a pre-existing defect that the fix must also correct.

## Row Name Correction

The first run of this task rendered the B11 row name as `... --pathspec-from-file ` because Pester expands `<value>` as a template variable. The row name now escapes the angle brackets (the form the existing rows use for `<wt>`), and the run recorded above shows the plan's name `B11 collects an absolute pathspec after git add --pathspec-from-file <value>`.
