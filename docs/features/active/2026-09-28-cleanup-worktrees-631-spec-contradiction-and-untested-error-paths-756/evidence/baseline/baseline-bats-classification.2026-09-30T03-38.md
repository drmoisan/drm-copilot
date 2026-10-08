# Baseline bats classification

Timestamp: 2026-10-07T21-59
Command: npx --yes bats --tap tests/shell/test_cleanup_worktrees_classification.bats (NOT run locally) ; companion: git grep -c '^@test ' -- tests/shell/test_cleanup_worktrees_classification.bats (equivalent of grep -c)
EXIT_CODE: NOT_RUN
EFC: TRIGGERED (operator decision Option A: not run locally; CI shell-coverage job on the pushed head is the evidence, recorded in P2-T11/P2-T12)
Output Summary: bats not run locally. Static companion count printed 21 (tests/shell/test_cleanup_worktrees_classification.bats:21), matching the expected 21; the static count stands as the test-count baseline. Task left unchecked, CI-deferred.
