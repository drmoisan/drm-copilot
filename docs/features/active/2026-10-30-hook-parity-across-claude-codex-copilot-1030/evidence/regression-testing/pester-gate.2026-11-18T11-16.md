# Pester Final Gate — [P3-T2]

Timestamp: 2026-11-18T11-01
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (one `Invoke-PoshQCParallelTest` run with coverage, 8 shards, integration and golden lanes excluded), run through `env -u VIRTUAL_ENV sh SCRATCH/issue-1030-final-gates.sh`; counts read with `sh SCRATCH/issue-1030-pester-summary.sh final`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Queue: launcher attempts 1 to 4 (2026-11-18T10-55 to 11-01) exited 75 (`TEST_EXECUTION_QUEUE_TIMEOUT:`); recorded as queue timeouts. Attempt 5 ran the gate (wall-clock 711.75 s).
- Shard 6 exited 1; the other seven exited 0. No merged `artifacts/pester/pester-junit.xml` was written because a shard failed, so the counts are read from `artifacts/pester/parallel/shard-<i>/pester-junit.xml`.
- Tests 29212; passed 29193; failed 1; errors 0; skipped 18.
- The only failing test is the baseline-listed `Harness generation repository gate.reports no drift for any generated target in the working tree` (`pester-baseline.2026-11-18T08-34.md`); no new failing test.
- `PreToolUse dispatcher registration shape (issue #1159).sets the Codex dispatcher timeout to the registry timeout sum` passed.
- Compared with the baseline: tests 29032 to 29212 (+180, the new suites); failing tests 1 to 1 (the same test).
