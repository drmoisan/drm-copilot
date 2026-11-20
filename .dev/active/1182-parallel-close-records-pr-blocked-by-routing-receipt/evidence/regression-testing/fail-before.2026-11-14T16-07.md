# Fail-Before: CR-2 prefilter row

Timestamp: 2026-11-14T16-07
Command: sh SCRATCH/issue-1182-phasegate.sh r1p1 (Invoke-PoshQCParallelTest stage, run before the production change)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Failing test: Claude preimplementation gate parallel records leg (issue #1182) > AC-11 unchanged behavior > (h) starts no worktree listing for an absolute non-receipt path.
- Failure message: "Expected Get-OrchestrationGateWorktreeList in module PoshQC to be called 0 times exactly, but was called 1 time" (the module wording comes from the PoshQC-hosted shard run; a direct run of the file prints the same without the module phrase).
- It is the only failing test of 25399; the change that makes it pass is [P2-T1].
