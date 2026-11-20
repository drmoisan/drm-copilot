# Coverage Comparison

Timestamp: 2026-10-29T11-41
Task: [P6-T4]
Command: read per-file line coverage from artifacts/pester/powershell-coverage.xml written by the [P6-T3] run (`SCRATCH/issue-995-read-results.ps1`), compared with pester-coverage.2026-10-29T10-45.md ([P0-T5]); missed line numbers mapped to their enclosing functions with awk over the current files
EXIT_CODE: 0
Output Summary: every file is at or above 85% line coverage (lowest 92.52%); no file regresses on changed lines. Every missed line lies in code this change did not edit.

| File | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1 (new) | N/A | 100.00% (33/33) | N/A |
| .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 100.00% (149/149) | 100.00% (146/146) | 0.00 |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | 92.59% (100/108) | 92.52% (99/107) | -0.07 |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 92.73% (102/110) | 93.10% (108/116) | +0.37 |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 95.65% (110/115) | 95.61% (109/114) | -0.04 |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 98.04% (50/51) | 98.18% (54/55) | +0.14 |

The two small negative deltas come from removed covered lines (the inline normalizers), not from new uncovered lines: CleanupWorktreeManifest.psm1 keeps the same 8 missed lines and enforce-epic-worktree-removal-gate.ps1 keeps the same 5 missed lines, now with fewer covered lines in the denominator.

## Changed-line coverage per edited function

| Function | File | Changed lines covered |
| --- | --- | --- |
| Test-WorktreeRunPathEqual, Test-WorktreeRunRecordedPathMatchesTarget, Test-WorktreeRunRelativeRecordSafe, Get-WorktreeRunMainCheckoutRoot | WorktreeRunRecordPath.psm1 | all (0 missed lines in file) |
| Test-WorktreeRunCheckpointRecord, Resolve-WorktreeRunTargetByRecord | WorktreeRunResolution.psm1 | all (0 missed lines in file) |
| Test-CleanupManifestCheckpointCoversPath | CleanupWorktreeManifest.psm1 | all (missed lines are in Get-CleanupWorktreeManifestContent, Get-CleanupWorktreeManifestUtcNow, ConvertTo-CleanupWorktreeManifestNormalizedPath, Find-CleanupWorktreeManifestRemovalRecord, Test-CleanupWorktreeManifestAuthorizesRemoval; none edited) |
| Find-ParallelWorktreeItemRecord, Get-ParallelWorktreeGateBaseRoot, Get-ParallelWorktreeRemovalTargetDenial | enforce-parallel-worktree-removal-gate.ps1 | all (missed lines are in Get-ParallelWorktreeRemovalGateEpicCheckpointContent and the entry-point tail; none edited) |
| Find-EpicWorktreeFeatureRecord, Test-ParallelCheckpointAllowsWorktreeRemoval, Get-EpicWorktreeRemovalTargetDenial | enforce-epic-worktree-removal-gate.ps1 | all (missed lines are in the entry point and its tail; none edited) |
| Get-EpicWorktreeGateBaseRoot, Find-EpicWorktreeGateParallelItemRecord, Get-EpicWorktreeGateDenyDiagnostics | enforce-epic-worktree-removal-gate-resolution.ps1 | all changed lines; the one missed line is the pre-existing `return $null` guard of Find-EpicWorktreeGateParallelItemRecord, which was the baseline's missed line and moved down when the helper was inserted above it |

PowerShell branch coverage is not measured (Pester), so no branch figure is reported.
