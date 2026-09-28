# Gate — AC-43, the no-temporary-file rule, re-run across all three suite files

Timestamp: 2026-09-08T12-10
Task: `[P9-T5]` (re-run)
Command: grep -r -c -F -- mktemp tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats tests/shell/test_cleanup_worktrees_preserve_failures.bats tests/fixtures/cleanup_worktrees/preserve
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: **Every printed count is `0`** for both literals across all three suite files and the
whole fixture tree. `grep` exits 1 when it selects no line, so the expected exit code for each scan
is 1, which is what both scans returned. A filter for counts other than `0` selected nothing.

## Why this task was re-run and how its file list changed

The gate of record was `evidence/qa-gates/gate-ac43-no-temp-files.2026-09-08T11-55.md`. Its command
named only `tests/shell/test_cleanup_worktrees_preserve.bats` and the fixture tree, which was the
plan's literal text and which by then already omitted `tests/shell/test_cleanup_worktrees_preserve_eol.bats`
created at `[P5-T9]`. The coverage-remediation pass added a third suite file. This re-run names all
three, closing both gaps. It supersedes the 11-55 artifact.

## The two scans

    grep -r -c -F -- mktemp \
      tests/shell/test_cleanup_worktrees_preserve.bats \
      tests/shell/test_cleanup_worktrees_preserve_eol.bats \
      tests/shell/test_cleanup_worktrees_preserve_failures.bats \
      tests/fixtures/cleanup_worktrees/preserve
    MKTEMP_EXIT=1

    grep -r -c -F -- BATS_TEST_TMPDIR \
      tests/shell/test_cleanup_worktrees_preserve.bats \
      tests/shell/test_cleanup_worktrees_preserve_eol.bats \
      tests/shell/test_cleanup_worktrees_preserve_failures.bats \
      tests/fixtures/cleanup_worktrees/preserve
    TMPDIR_EXIT=1

The two literals asserted are `mktemp` and `BATS_TEST_TMPDIR`.

## Counts for the three suite files, verbatim

    tests/shell/test_cleanup_worktrees_preserve.bats:0
    tests/shell/test_cleanup_worktrees_preserve_eol.bats:0
    tests/shell/test_cleanup_worktrees_preserve_failures.bats:0

for `mktemp`, and the identical three lines for `BATS_TEST_TMPDIR`.

Every fixture-tree entry likewise printed `:0`, including the nine files the coverage-remediation
pass added. A discriminating filter for any count other than `0` was run over both scans and selected
nothing:

    grep -r -c -F -- mktemp <the four operands> | grep -v ':0$'            -> (no output)
    grep -r -c -F -- BATS_TEST_TMPDIR <the four operands> | grep -v ':0$'  -> (no output)

That filter is what makes this gate able to fail: a listing in which every line ends `:0` is what a
clean tree prints, and a single non-zero count would have been the only line the filter selected.

## How the new tests satisfy the rule in substance

The eleven tests added by the coverage-remediation pass write to `/dev/null` and to paths beneath it.
`/dev/null` is a character device, not a temporary file, and a path beneath it such as
`/dev/null/nested/lesson.md` is not creatable at all, which is precisely why it is a deterministic
way to make `mkdir -p` and an append fail without anything being created anywhere. No scratch
directory, no scratch git repository, and no temporary file is used by any of them.

Satisfies **AC-43**.
