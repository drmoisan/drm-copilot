# Baseline bats report_records

Timestamp: 2026-10-07T21-59
Command: npx --yes bats --tap tests/shell/test_cleanup_worktrees_report_records.bats (NOT run locally) ; companion: git grep -c '^@test ' -- tests/shell/test_cleanup_worktrees_report_records.bats (equivalent of grep -c)
EXIT_CODE: NOT_RUN
EFC: TRIGGERED (operator decision Option A: not run locally; CI shell-coverage job on the pushed head is the evidence, recorded in P2-T11/P2-T12)
Output Summary: bats not run locally. Static companion count printed 10 (tests/shell/test_cleanup_worktrees_report_records.bats:10), matching the expected 10; the static count stands as the test-count baseline. Task left unchecked, CI-deferred.
CI-Resolved: run 37716284664 (job 113113368962, headSha 4f960432d0e7f3378d18091c2a02f5b8a94323e0): shell-qc check step success, shell-qc test with coverage step success, zero 'not ok' lines, new tests ok 452-459
Baseline-CI-Note: the pre-change baseline CI run is main run 37645267440 (conclusion success).
