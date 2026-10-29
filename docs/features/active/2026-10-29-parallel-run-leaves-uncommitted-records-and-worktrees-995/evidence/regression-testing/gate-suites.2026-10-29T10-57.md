# Gate Suites After Default Main-Root Mocks

Timestamp: 2026-10-29T10-57
Task: [P3-T4]
Command: Invoke-PoshQCTest -Root <repo root> -ScanFolders <the twelve tests/scripts/claude-hooks suites below plus the three tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-*.Tests.ps1 suites> (PowerShell 7 launched by `sh SCRATCH/issue-995-pester-files.sh`)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml reports 383 test cases: 383 passed, 0 failed, 0 skipped, in one Pester run.

Suites edited (setup only; one comment line and two default mocks, `Mock Get-WorktreeRunMainCheckoutRoot { $null }` in script scope and `Mock Get-WorktreeRunMainCheckoutRoot -ModuleName WorktreeRunResolution { $null }`, inserted after each suite-setup anchor; no existing assertion line changed):

- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 (two Describe setups)
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
- tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 (two Describe setups)

Codex suites run unchanged: enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1, enforce-epic-worktree-removal-gate-issue824.Tests.ps1, enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1.

Counts (from artifacts/pester/pester-junit.xml): passed 383, failed 0, skipped 0.
