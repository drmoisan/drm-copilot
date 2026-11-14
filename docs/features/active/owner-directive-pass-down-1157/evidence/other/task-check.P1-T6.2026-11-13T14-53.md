# Task check P1-T6 (issue #1157, cycle 1)

Timestamp: 2026-11-13T14-53
Command: sh SCRATCH/issue-1157-static.sh -File tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1; sh SCRATCH/issue-1157-taskcheck.sh -Path tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Changed files: tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1 (Invoke-Case returns CheckpointRead; H1, H3 allowed case, H7, H8, H11 assert CheckpointRead with unchanged expected arrays; H2, H5, H6 keep Read; row H14 added).
- Selection rule: the changed test file itself.
- Format: drift 0. Lint: 0 findings. Type check: not applicable.
- Pester: 18 tests, 17 passed, 1 failed (H14, the [expect-fail] row of this task); EXIT_CODE 1, as expected. Fail-before evidence: evidence/regression-testing/fail-before.F1.2026-11-13T14-53.md.
