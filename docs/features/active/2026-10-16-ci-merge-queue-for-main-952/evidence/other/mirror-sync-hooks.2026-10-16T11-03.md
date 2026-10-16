# Mirror Sync: Hooks (P3-T14)

Timestamp: 2026-10-16T11-03
Command: git add .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1; git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1; git checkout-index -f --prefix=extensions/drm-copilot/resources/codex-and-agents-customizations/ -- .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1; git hash-object over the eight paths
EXIT_CODE: 0
Output Summary: PAIRS_EQUAL=4/4 hooks

| Source | Source hash | Mirror | Mirror hash |
|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 | a7250a43d70088f5c1d3c73588363f875368b036 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 | a7250a43d70088f5c1d3c73588363f875368b036 |
| .claude/hooks/enforce-epic-merge-gate-command.ps1 | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd |
| .codex/hooks/enforce-epic-merge-gate.ps1 | d14b90abe54b3500a464be50e4a659c14f20c1e4 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 | d14b90abe54b3500a464be50e4a659c14f20c1e4 |
| .codex/hooks/enforce-epic-merge-gate-command.ps1 | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1 | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd |
