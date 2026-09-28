# Gate — AC-43, no test creates or reads a temporary file

Timestamp: 2026-09-08T11-55
Task: `[P9-T5]`
Command: grep -r -c -F -- mktemp tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats tests/fixtures/cleanup_worktrees/preserve
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: every printed count is `0`, across 137 files for each of the two literals. `grep`
exits 1 when it selects no line, so 1 is the expected and correct exit code for this gate.

RouteSubstitution:
- Plan command (denied in this worktree): the `pwsh`-wrapped WSL form of the same two `grep -r -c`
  invocations.
- Substitute actually run: the identical invocations executed locally in Git Bash, with the file
  list extended from one suite file to two because the pre-authorized suite split was taken at
  `[P5-T9]`. The plan requires every later enumeration of the suite to name both files.
- Reason: the `pwsh`-wrapped WSL form is refused unconditionally in this worktree, and a bare `wsl`
  invocation is prohibited by binding amendment EA-1.

## Counts

    mktemp             137 files scanned, every count 0, grep exit 1
    BATS_TEST_TMPDIR   137 files scanned, every count 0, grep exit 1

The two literals asserted are `mktemp` and `BATS_TEST_TMPDIR`.

## How the writing phase is exercised without a temporary file

Three character-device techniques carry the whole suite:

- `CLEANUP_WT_CONSOLIDATION_PATH=/dev` with a `target_path` of the one-segment repo-relative string
  `null` resolves the destination to `/dev/null`. `mkdir -p /dev` succeeds against the existing
  directory and the byte copy writes to the null device, so the writing phase's filesystem lines are
  covered and no file is created anywhere.
- `/dev/stdout` as the index path lets the index renderer's bytes be observed without writing to a
  checked-in index. Byte counts are taken through a pipe rather than from a captured string, because
  command substitution strips trailing line feeds.
- Every index-decision test drives the read-only phase, which performs no write at all, so the
  checked-in index fixtures are never modified. That was confirmed after a full drive of all
  twenty-three scenarios: all six checked-in index fixtures held their original byte counts and
  `/dev/MEMORY.md` did not exist.

`/dev/null` and `/dev/stdout` are character devices, not temporary files, so the rule is satisfied
in substance as well as in letter.

Verdict: PASS.
