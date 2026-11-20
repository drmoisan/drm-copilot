# Fail-Before Supplement: Hook Probe Suite Against the HEAD Hook (P1-T11 addendum)

Timestamp: 2026-10-29T14-46
Command: git archive HEAD .claude tests/scripts/claude-hooks | tar -x -C SCRATCH/headtree; copy tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1 into SCRATCH/headtree; Invoke-Pester on that file inside SCRATCH/headtree (sh SCRATCH/issue-992-ps.sh headtree)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 21 failed, 1 passed. Every probe case fails with "A parameter cannot be found that matches parameter name 'FeatureFolderGitInvoker'." against the unmodified HEAD hook; only `baseline mock interception probe` passes.

## Why this supplement exists

The P1-T11 artifact `fail-before.2026-10-29T14-38.md` records `validate-orchestrator-output.FeatureFolder.Tests.ps1` as 22 failed. Investigation after P4-T4 showed that those 22 failures came from a test-structure defect in the suite itself: an `AfterEach` block at file root, which Pester 5 rejects ("Each test Teardown is not supported in root (directly in the block container)"). That run therefore did not demonstrate the behavior gap. The `AfterEach` was moved inside the `Describe` block, and this run re-establishes the fail-before against the HEAD copy of the hook, which has no `-FeatureFolderGitInvoker` parameter and no probe.

The other new Pester suite, `OrchestratorStateFeatureFolderRecord.Tests.ps1`, failed in P1-T11 because the record module did not exist yet; that cause is behavioral and needs no supplement.

After the fix (P4-T3, P4-T4), the corrected suite passes 22 of 22 in the worktree.
