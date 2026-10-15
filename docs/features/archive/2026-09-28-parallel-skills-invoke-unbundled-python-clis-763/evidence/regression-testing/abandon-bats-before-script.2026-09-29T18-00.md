# Abandon Bats Suite Before the Script Exists (P2-T6, expect-fail)

Timestamp: 2026-09-29T18-00
Command: npx --yes bats tests/shell/parallel_abandon.bats
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- TAP plan `1..14`
- 14 `not ok` lines, 0 `ok` lines:
  not ok 1 the abandon script exists in the repository library
  not ok 2 success closes the pull request before removing the worktree
  not ok 3 success writes nothing to stdout
  not ok 4 a detach disposition exits 2 with the reference message and no side effect
  not ok 5 a missing confirmation marker exits 2 with the reference message and no side effect
  not ok 6 a gh failure exits 1 and does not invoke git
  not ok 7 a git failure exits 1 with the reference message
  not ok 8 an absent gh executable reports exit code -1
  not ok 9 an unknown option exits 2 with no side effect
  not ok 10 an option abbreviation exits 2 with no side effect
  not ok 11 the joined option form is accepted
  not ok 12 a missing required option exits 2 with no side effect
  not ok 13 a non-integer item key exits 2 with no side effect
  not ok 14 the script declares the option tokens as named constants

Every test depends on `.claude/lib/bash/abandon-parallel-item.sh`, which does not exist yet.
