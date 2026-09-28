# Follow-ups for Issue #709

Timestamp: 2026-09-27T10-14

1. D8 - Other epic-reading hooks. Verify and, if needed, isolate the relative-path epic-checkpoint reads in the suites for `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`. These hooks read `artifacts/orchestration/epic-orchestrator-state.json` through their own relative-path seam rather than `EpicScopeResolution`; whether every row in their suites mocks that seam was not verified under #709.

2. D9 - Explicit path list in the structural guard. The structural guard in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` iterates an explicit list of seven suite paths, so it does not guard a future suite for gates 1, 3, or 4 that reaches `Resolve-EpicScopeCheckpoint`. Extend the list when such a suite is added.
