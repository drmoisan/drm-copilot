# Baseline File Sizes (Issue #1010, P0-T4)

Timestamp: 2026-10-30T20-37
Command: wc -l <file> and sha256sum <file> for each of the eight edited production files
EXIT_CODE: 0
Output Summary: Eight physical line counts recorded. Codex gate pair 500 and 500 (equal). Every source and bundle pair is byte-identical (equal SHA-256 prefix).

| File | Physical lines | SHA-256 prefix |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 470 | 023c1fca3268 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 470 | 023c1fca3268 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 267 | b5f90ede9807 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 267 | b5f90ede9807 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | 96ccbfdd2f48 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | 96ccbfdd2f48 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 210 | 3eefbc73c1ce |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 210 | 3eefbc73c1ce |
