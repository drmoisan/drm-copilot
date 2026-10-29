# PSScriptAnalyzer (final)

Timestamp: 2026-10-29T11-04
Task: [P6-T2]
Command: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -ErrorAction Stop, once per file, an analyzer exception retried once and then counted as an error (PowerShell 7 launched by `sh SCRATCH/issue-995-pssa-final.sh`)
EXIT_CODE: 0
Output Summary: 0 findings and 0 analyzer errors across the six production files and 19 new or changed test files (loop pass 2). Pass 1 reported 5 findings, which were fixed before the loop restarted at [P6-T1].

| File | Findings |
| --- | --- |
| .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1 | 0 |
| .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 0 |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | 0 |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 0 |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 0 |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 0 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1 | 0 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1 | 0 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | 0 |
| tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | 0 |
| tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1 | 0 |

## Pass 1 findings (fixed)

- enforce-parallel-worktree-removal-gate.ps1: PSUseOutputTypeCorrectly on Get-ParallelWorktreeGateBaseRoot.
- enforce-epic-worktree-removal-gate-resolution.ps1: PSUseOutputTypeCorrectly on Get-EpicWorktreeGateBaseRoot.
- WorktreeRunResolution.RelativeRecord.Tests.ps1, enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1, enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1: PSUseShouldProcessForStateChangingFunctions on the New-* fixture helpers (renamed to Get-*).
- Pass 1 also raised one analyzer exception ("Object reference not set to an instance of an object") during one file's analysis; the runner was changed to retry once and count a repeated exception as an error. Pass 2 raised none.
