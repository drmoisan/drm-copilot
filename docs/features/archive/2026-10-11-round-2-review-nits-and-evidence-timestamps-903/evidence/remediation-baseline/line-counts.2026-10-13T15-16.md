# Line-count baseline (remediation cycle 1, P0-T4)

Timestamp: 2026-10-13T15-16
Command: wc -l <worktree>/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 <worktree>/tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 <worktree>/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 <worktree>/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
EXIT_CODE: 0
Output Summary: Counts match the plan (386, 456, 424, 210); no LINE-COUNT-DRIFT.

| File | Lines | Expected |
|---|---|---|
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | 386 | 386 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | 456 | 456 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 424 | 424 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 210 | 210 |
