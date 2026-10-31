# Fail-Before: Codex Operand-Option Rows (Issue #1010, remediation cycle 1, P1-T6) [expect-fail]

Timestamp: 2026-10-30T22-19
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-r1-s2.txt -NoCoverage (Invoke-PoshQCTest over tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1 before any production change, Run.Exit off; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: 46 tests, 34 passed, 12 failed. Failing: C18, B11, B12, B14, and eight B10 cases. Passing new rows: B10 `-C HEAD`, `-c HEAD`, and `-F msg.txt`, and B13. All 30 pre-existing rows pass. As on the Claude surface, B10 `-F msg.txt` passes and B12 fails, which differs from the P1-T6 prediction.

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
12. C18 admits git commit -m msg <abs file> against a ready item checkpoint, reading the item checkpoint

## Deviation From the P1-T6 Prediction

The Codex `hook-command-invocation.ps1` copy has the same `Get-CommandLineInvocationOperand` logic: option names are tested with the case-insensitive `-contains`, and the generic standalone list holds `-f`, so `-F` is read as a standalone flag and the token after it is collected as an operand. B10 `-F msg.txt` therefore passes before the fix (the relative `msg.txt` is dropped and the absolute pathspec is collected), and B12 fails before the fix (the absolute message file is collected as a pathspec). The P1-T6 acceptance condition is not met as written for these two rows; the full explanation is in `fail-before-claude-operand-options.2026-10-30T22-18.md`.
