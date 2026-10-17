# Resolver Exports and Hashes (P0-T15)

Timestamp: 2026-10-08T22-36

Command: sh SCRATCH/run-ps.sh SCRATCH/module-exports.ps1
EXIT_CODE: 0
Output Summary:
WRR_EXPORTS=Find-WorktreeRunIdentitySignal,Get-WorktreeRunCheckpointPath,Get-WorktreeRunCheckpointText,Resolve-WorktreeEpicTarget,Resolve-WorktreeOperandTarget,Resolve-WorktreeParallelTarget,Resolve-WorktreeRunTargetByRecord
WIR_EXPORTS=ConvertTo-WorktreeItemIssueNumber,ConvertTo-WorktreeItemResolvedResult,Find-WorktreeItemIssueSignal,Get-WorktreeItemCheckpointIssue,Get-WorktreeItemCheckpointPath,Get-WorktreeItemCheckpointRelativePath,Get-WorktreeItemCheckpointText,Get-WorktreeItemLiveRoot,Resolve-WorktreeItemTarget
MISSING_CONSUMED=0

Command: sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 .claude/lib/worktree-resolution/WorktreeItemResolution.psm1
EXIT_CODE: 0
Output Summary:
.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 Hash=86D30DDE3DA82EA55BAC5D2DFF490692A645496FE6FFCD4A5C0FED10B83D9096
.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 Hash=638E660B51E89019C1C499D616988AA66AE313B708B50A0F99DC3A22AB82FD23

WRR_HASH: 86D30DDE3DA82EA55BAC5D2DFF490692A645496FE6FFCD4A5C0FED10B83D9096

Result: PASS (MISSING_CONSUMED=0; both hashes recorded).
