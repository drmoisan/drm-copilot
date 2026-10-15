# Preconditions (P0-T2)

Timestamp: 2026-10-09T06-51
Output Summary: branch name matches; AC count 13; absence test exit 0; new-row token count 0; @test count 31; BASE_SHA recorded (40 chars). All preconditions met.

(a) Command: git rev-parse --abbrev-ref HEAD
EXIT_CODE: 0
Output: bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794

(b) Command: grep -c -F -e "- [ ] AC-" docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/spec.md
EXIT_CODE: 0
Output: 13

(c) Command: sh -c 'test ! -e docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/user-story.md'
EXIT_CODE: 0
Output: (empty)

(d) Command: sh -c 'grep -c -F "separator-parity:" tests/shell/parallel_cohorts.bats || true'
EXIT_CODE: 0
Output: 0

(e) Command: grep -c "^@test" tests/shell/parallel_cohorts.bats
EXIT_CODE: 0
Output: 31

(f) Command: git fetch origin main ; git merge-base HEAD origin/main
EXIT_CODE: 0
BASE_SHA: e7d3779b398604af919678c16c877c8539a86cc0
