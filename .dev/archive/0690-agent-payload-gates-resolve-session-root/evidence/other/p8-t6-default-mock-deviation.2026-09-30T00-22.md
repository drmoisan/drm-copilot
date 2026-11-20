# P8-T6 Default Mock Placement Deviation

Timestamp: 2026-09-30T00-22
Command: git grep -c -F "Mock Resolve-ParallelWorktreeGateRunTarget" -- <four EXIST-PREM suites>
EXIT_CODE: 0
Output Summary:
- enforce-parallel-worktree-removal-gate.Tests.ps1 has two top-level Describe blocks, each with its own hook-loading BeforeAll (line 19 and the 'manifest branch' Describe at line 406). This is the structure recorded for the EREM suite in p7-t7-default-mock-deviation.2026-09-30T00-16.md.
- DT-LINE was placed in both hook-loading BeforeAll blocks of that file, per P8-T6's instruction to use each suite's relevant BeforeAll; without it the manifest-branch rows would run the real resolver.
- Resulting counts: enforce-parallel-worktree-removal-gate.Tests.ps1:2 (plan acceptance literal: 1), EpicAuthorization:1, TriggerScoping:1, CleanupWorktreeManifestGateMatrix:1.
- The two read-seam rows now pass -Path '/synthetic-worktrees/prem-seam/artifacts/orchestration/parallel-orchestrator-state.json' and their ParameterFilters compare to the same literal; the Should assertions are unchanged.
- Resulting line count: enforce-parallel-worktree-removal-gate.Tests.ps1 LineCount=466; at or below 500.
