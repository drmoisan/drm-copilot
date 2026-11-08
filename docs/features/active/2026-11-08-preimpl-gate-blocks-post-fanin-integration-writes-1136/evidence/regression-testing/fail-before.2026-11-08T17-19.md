# Fail-Before Regression Run ([P1-T2], expect-fail)

Timestamp: 2026-11-08T17-19
Command: sh SCRATCH/issue-1136-pester.sh failbefore (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>), then shard JUnit read from artifacts/pester/parallel/shard-<i>/pester-junit.xml
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run before any production change (only the [P1-T1] test file was added). Invoke-PoshQCParallelTest returned ExitCode 1; shard 4 exited 2, the other seven shards exited 0.
- Shard JUnit totals: tests=19861, failed=2, skipped=10.
- Failed: `preimplementation gate post-fan-in allowance (issue #1136).fail-before.allows a Write of artifacts/pr_body_7.receipt.json in epic scope with fan-in complete` - expected 'allow', was 'deny'; decision reason: "PREIMPLEMENTATION_GATE_BLOCKED: this epic-scope operation was evaluated against /synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json, and the failed readiness predicate is 'merge-in-progress'. ..."
- Failed: `preimplementation gate post-fan-in allowance (issue #1136).fail-before.allows a pathless git commit -m when the staged index is exactly the status doc` - expected 'allow', was 'deny'; same decision reason naming 'merge-in-progress'.
- No other test failed. The [P0-T3] baseline (pester-baseline.2026-11-08T17-02.md) recorded zero failures, so no failure is new apart from the two [P1-T1] rows.
