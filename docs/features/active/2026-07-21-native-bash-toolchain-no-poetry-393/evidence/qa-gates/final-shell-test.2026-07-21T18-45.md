# Final QC — Shell Tests (P5-T3) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: bash scripts/bash/shell-qc.sh test
EXIT_CODE: NOT-EXECUTED (delegated)

Note: bats is not installed on this Windows host and is not on the executor Bash allowlist.
The two bats suites (tests/shell/test_shell_qc_discovery.bats, 11 tests;
tests/shell/test_shell_qc_commands.bats, 19 tests) are written and complete, using checked-in
fixtures and stub binaries via the SHELL_QC_<TOOL>_BIN seam with no temporary files. bats
execution is deferred to the CI green run (AC8/AC9, P5-T9).
Output Summary: 30 named bats tests written; execution deferred to CI. Bats pass counts to be
recorded from the CI run.
