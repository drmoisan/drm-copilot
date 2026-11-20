# [expect-fail] new rows before production changes (P1-T1, P2-T1, P4-T1)

Timestamp: 2026-10-29T12-26
Command: Invoke-PoshQCTest (PoshQC module, sh-launched from SCRATCH) over tests/scripts/claude-lib/worktree-resolution, tests/scripts/claude-lib/cleanup-manifest, tests/scripts/claude-hooks, tests/scripts/claude-runtime, with the added test rows present and no production or customization file edited
EXIT_CODE: 15
ExpectedExitCode: 15
Output Summary: 6379 tests, 6364 passed, 15 failed (artifacts/pester/pester-junit.xml). The 15 failures are exactly the rows the plan expects to fail before the production change:
- P1-T1: CM-case1 (POSIX record, case variant), CM-case2 (relative record, case variant). CM-case3 (names differ by more than case) passes before and after, as planned.
- P2-T1: B1, B2, B3 (two rows), B3b (three rows), B4, and X1 (export list expects four functions).
- P4-T1: RC5 (repository copy, bundle copy) and RA5 (repository copy, bundle copy).
P3-T1 RE2b (three rows) passed against unchanged production code, as the plan predicts; no fail-before artifact applies to it.
