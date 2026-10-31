# QA Gate: File Sizes (Issue #1010, P5-T7)

Timestamp: 2026-10-30T21-09
Command: wc -l <file> for every production file in the Declared File Set and its bundle copy (and the two new test files, for information)
EXIT_CODE: 0
Output Summary: Codex gate pair 491 (at or below 500, not above its P0-T4 count of 500); Codex -epic-scope pair 408 (at or below 500); every file at or below 800. The pinned row `keeps <File> at or under 500 lines in the repository and the bundle` passed in P5-T3 (Codex -epic-scope suite, 54 of 54).

| File | P0-T4 lines | P5-T7 lines |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 470 | 470 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 470 | 470 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 267 | 348 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 267 | 348 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | 491 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | 491 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 210 | 408 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 210 | 408 |

New test files (information only; not in the production size rule): `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` 350 lines; `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` 388 lines. Both are below the 500-line guidance tier.
