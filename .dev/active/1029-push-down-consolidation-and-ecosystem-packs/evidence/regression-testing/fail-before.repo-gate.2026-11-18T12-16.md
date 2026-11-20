# Fail-before: harness generation repository gate test

Timestamp: 2026-11-18T12-16
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1 (run through SCRATCH/issue-1029-retry.sh, which re-runs only on launcher exit 75)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Attempt 1 (2026-11-18T12-12) exited 75 with `TEST_EXECUTION_QUEUE_TIMEOUT:` because another worktree's Pester suite held the machine test-suite lock. That is a queue timeout, not a failure. Attempt 2 (2026-11-18T12-15) ran `Invoke-PoshQCParallelTest` with workers=1, wall-clock 95.59 s, exit code 1. From `artifacts/pester/parallel/shard-1/pester-junit.xml`: Tests Passed: 2, Failed: 1, Skipped: 0.
  - FAILED `Harness generation repository gate.reports no drift for any generated target in the working tree`. Message: "Expected 0, because a generated target was edited by hand or its source changed without a generation run; drifted: DRIFT .claude/rules/orchestrator-state.md; DRIFT extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md, but got 2." The message names `GEN` and `GENB`.
  - PASSED `records a source path and a generator for every selected entry whose source exists`.
  - PASSED `names the drifted path when a target differs from its source`.
This run is fail-before evidence for a selection. It is not a gate.
