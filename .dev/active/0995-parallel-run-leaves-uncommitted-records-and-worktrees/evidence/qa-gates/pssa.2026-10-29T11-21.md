# PSScriptAnalyzer (loop pass 3)

Timestamp: 2026-10-29T11-21
Task: [P6-T2]
Command: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -ErrorAction Stop, once per file, an analyzer exception retried once and then counted as an error (PowerShell 7 launched by `sh SCRATCH/issue-995-pssa-final.sh`)
EXIT_CODE: 0
Output Summary: 0 findings and 0 analyzer errors across the 26 files (the six production files and 20 new or changed test files).

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
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | 0 |
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
