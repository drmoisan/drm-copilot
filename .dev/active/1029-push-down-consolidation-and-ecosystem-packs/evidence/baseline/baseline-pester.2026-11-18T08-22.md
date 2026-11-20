# Baseline: Pester (tests/scripts, one parallel run)

Timestamp: 2026-11-18T08-22
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (Invoke-PoshQCParallelTest -Root . through the launcher; integration and golden lanes excluded)
EXIT_CODE: 1
Output Summary: Returned `ExitCode` 1 (workers=8, wall-clock 758.09 s). Shard 1 exited 1; shards 2 to 8 exited 0, so no merged `artifacts/pester/pester-junit.xml` or merged coverage file was written. Counts from the eight per-shard `artifacts/pester/parallel/shard-<i>/pester-junit.xml` files: 29032 tests, 1 failure, 0 errors, 22 disabled. Repo-wide line coverage: not recorded, because the run was not green and no merged coverage file exists. In-scope PowerShell files: none.

The first launcher attempt (2026-11-18T08-05) exited 75 with `TEST_EXECUTION_QUEUE_TIMEOUT:` because another worktree's pytest suite held the machine test-suite lock; it is a queue timeout, not a failure, and this run is the re-run.

## Failing test (pre-existing)

- `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` :: `Harness generation repository gate.reports no drift for any generated target in the working tree`
  - Message: drifted `.claude/rules/orchestrator-state.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.
  - Neither file is changed by this item (`git status --porcelain` over both paths is empty; the last commits on the rule are upstream merges #1201 and #1156). See `evidence/other/execution-decision.pester-baseline-drift.2026-11-18T08-22.md`.
