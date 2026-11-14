# QA File Sizes (Issue #1010, remediation cycle 1, P3-T8)

Timestamp: 2026-10-30T22-28
Command: wc -l over the seven files below; sha256sum over the four production files (source and bundle pairs)
EXIT_CODE: 0
Output Summary: Both Codex `-epic-scope` copies are 447 lines (pin 500); every file is at or below 800 lines; each source hash equals its bundle copy hash (Claude pair 1fc62475..., Codex pair 0dbb3153...).

| File | P0-T2 lines | P3-T8 lines | SHA-256 (prefix) |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 348 | 387 | 1fc624751f50 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 348 | 387 | 1fc624751f50 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 408 | 447 | 0dbb3153e0e4 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 408 | 447 | 0dbb3153e0e4 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` (suite 1) | 350 | 422 | n/a |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` (suite 2) | 388 | 460 | n/a |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` (suite 3) | absent | 102 | n/a |
