# Baseline Longest-Match Search

Timestamp: 2026-10-08T17-32
Command: grep -rnE 'Sort-Object[^|]*Length' --include='*.ps1' --include='*.psm1' --exclude-dir=worktrees --exclude-dir=state .claude .codex extensions/drm-copilot/resources
EXIT_CODE: 0
Output Summary: Exactly 10 matching lines, at the five expected source locations and their five bundled mirrors.

```
.claude/hooks/enforce-epic-wave-barrier.ps1:134
.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:236
.claude/hooks/enforce-parallel-cohort-barrier.ps1:185
.claude/hooks/enforce-parallel-drift-gate.ps1:233
.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:236
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1:134
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:236
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1:185
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1:233
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:236
```

Each line is a `Sort-Object -Property Length -Descending` over `$unique.Keys`.
