# Baseline File Sizes (Issue #1010, remediation cycle 1, P0-T2)

Timestamp: 2026-10-30T22-13
Command: wc -l over the six files below; sha256sum over the four production files (source and bundle pairs)
EXIT_CODE: 0
Output Summary: six physical line counts recorded; each source file hash equals its bundle copy hash (Claude pair b8bbee0b..., Codex pair c8383aa4...). The Codex `-epic-scope` file is 408 lines against its 500-line pin.

| File | Physical lines | SHA-256 (prefix) |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 348 | b8bbee0b0b85 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 348 | b8bbee0b0b85 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 408 | c8383aa4bfa1 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 408 | c8383aa4bfa1 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` (suite 1) | 350 | n/a |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` (suite 2) | 388 | n/a |
