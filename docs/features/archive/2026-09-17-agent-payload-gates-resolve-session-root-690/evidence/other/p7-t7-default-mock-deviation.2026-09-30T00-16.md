# P7-T7 Default Mock Placement Deviation

Timestamp: 2026-09-30T00-16
Command: git grep -c -F -e 'Mock Resolve-EpicWorktreeGateRunTarget' -- <four EXIST-EREM suites>; sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
EXIT_CODE: 0
Output Summary:
- enforce-epic-worktree-removal-gate.Tests.ps1 has two top-level Describe blocks, each with its own hook-loading BeforeAll (line 25 and the 'manifest branch' Describe). With DT-LINE only in the first, the two manifest-branch rows ran the real resolver and failed (the final deny gained the TARGET_WORKTREE_NOT_DERIVABLE prefix).
- DT-LINE was therefore placed in both hook-loading BeforeAll blocks of that file, per P7-T7's instruction to use each suite's relevant BeforeAll.
- Resulting counts: enforce-epic-worktree-removal-gate.Tests.ps1:2 (plan acceptance literal: 1), TriggerScoping:1, CleanupWorktreeManifestGateMatrix:1, hook-command-parser.AcceptanceCases:1.
- Resulting line count: enforce-epic-worktree-removal-gate.Tests.ps1 LineCount=497 (plan acceptance literal: 496); the read-seam rows use inline literals and add no line; the file stays at or below 500.
- After the change SET-EREM passes 154 of 154, including the exact-text row.
