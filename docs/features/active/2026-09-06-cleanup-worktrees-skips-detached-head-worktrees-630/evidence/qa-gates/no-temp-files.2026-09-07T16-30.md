# Temporary-File Audit of the Changed Test Files (AC19)

Timestamp: 2026-09-07T16-30
Task: [P6-T9]

Command: `git grep -n -E "mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|git init" -- tests/shell/test_cleanup_worktrees_detached.bats tests/shell/test_cleanup_worktrees_cli.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

## Observation

The command printed nothing on stdout. `git grep` exits 1 with empty stdout when the pattern matches
nothing, so exit code 1 is the expected and required outcome for this audit and is declared as such
above.

## Scope and patterns

SearchScope: `tests/shell/test_cleanup_worktrees_detached.bats`,
`tests/shell/test_cleanup_worktrees_cli.bats` — the two test files this remediation cycle modified.

SearchPatterns: the alternation `mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|git init`, covering the four
routes by which a bats case could create scratch state on disk: an explicit `mktemp` call, either of
the two bats-supplied temporary directory variables, and the creation of a scratch git repository.

SearchResult: none.

## Interpretation

No match was found in either file. Neither file creates a temporary file, uses a bats temporary
directory variable, nor initialises a scratch git repository. This is AC19, and it matches the
plan's Do-Not-Do list item 5: all new coverage routes through the `CLEANUP_WT_GIT_BIN` and
`CLEANUP_WT_STUB_SCENARIO` seams against checked-in fixture directories under
`tests/fixtures/cleanup_worktrees/scenarios/`, which are tracked repository content rather than
scratch state.

The policy basis is `.claude/rules/general-unit-test.md`, which prohibits creation and use of
temporary files in tests, and `.claude/rules/general-code-change.md`, which repeats the prohibition
at the I/O boundary.

Output Summary: the command printed nothing and exited 1, which is the declared expected exit code.
No match for `mktemp`, `BATS_TMPDIR`, `BATS_TEST_TMPDIR`, or `git init` was found in either
`tests/shell/test_cleanup_worktrees_detached.bats` or `tests/shell/test_cleanup_worktrees_cli.bats`.
AC19 holds.
