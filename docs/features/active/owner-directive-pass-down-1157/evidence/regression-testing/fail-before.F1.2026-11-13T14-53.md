# Fail-before evidence, finding F1 (issue #1157, cycle 1, P1-T6)

Timestamp: 2026-11-13T14-53
Command: sh SCRATCH/issue-1157-taskcheck.sh -Path tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1 (pwsh 7, New-PesterConfiguration with Run.Path set to the suite and Run.PassThru; the launcher exits 1 when any test, block, or container fails); run before the P1-T7 change, while the sibling still reads through Read-OrchestratorOutputOwnerPassDownText
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- 18 tests: 17 passed, 1 failed, 0 skipped.
- Failing case: "validate-orchestrator-output orchestrator-state target worktree (issue #1145).H14 reads the owner-directive ledger beneath the item root through Get-CheckpointFileContent"; the recorded Get-CheckpointFileContent paths hold only the item checkpoint path, not the item ledger path, because the ledger read still goes through the sibling's own read function.
- H1, H3, H7, H8, and H11, now asserting CheckpointRead, pass; no other case failed.
