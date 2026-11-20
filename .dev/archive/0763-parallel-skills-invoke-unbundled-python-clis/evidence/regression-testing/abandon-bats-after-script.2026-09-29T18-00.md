# Abandon Bats Suite After the Script Exists (P2-T8)

Timestamp: 2026-09-29T18-00
Command: npx --yes bats tests/shell/parallel_abandon.bats
EXIT_CODE: 0
Output Summary:
- TAP plan `1..14`; 14 `ok` lines; no `not ok` line.
  ok 1 the abandon script exists in the repository library
  ok 2 success closes the pull request before removing the worktree
  ok 3 success writes nothing to stdout
  ok 4 a detach disposition exits 2 with the reference message and no side effect
  ok 5 a missing confirmation marker exits 2 with the reference message and no side effect
  ok 6 a gh failure exits 1 and does not invoke git
  ok 7 a git failure exits 1 with the reference message
  ok 8 an absent gh executable reports exit code -1
  ok 9 an unknown option exits 2 with no side effect
  ok 10 an option abbreviation exits 2 with no side effect
  ok 11 the joined option form is accepted
  ok 12 a missing required option exits 2 with no side effect
  ok 13 a non-integer item key exits 2 with no side effect
  ok 14 the script declares the option tokens as named constants
- `.claude/lib/bash/abandon-parallel-item.sh` LineCount=176 (P2-T7, at most 500).
