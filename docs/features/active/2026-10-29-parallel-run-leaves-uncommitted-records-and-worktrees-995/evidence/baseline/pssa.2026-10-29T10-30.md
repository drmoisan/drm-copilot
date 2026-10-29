# Baseline PSScriptAnalyzer

Timestamp: 2026-10-29T10-30
Task: [P0-T4]
Command: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 (one call per file, PowerShell 7 launched by `sh SCRATCH/issue-995-pssa-base.sh`)
EXIT_CODE: 0
Output Summary: 0 findings in each of the five existing production files; total 0.

| File | Findings |
| --- | --- |
| .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 0 |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | 0 |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 0 |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 0 |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 0 |
