# Baseline — Residual `artifacts/research` References

Timestamp: 2026-06-24T13-09
Command: Grep pattern `artifacts[/\\]research` across the repository (content/files mode, unlimited)
EXIT_CODE: 0
Output Summary: 96 files match the pattern. They fall into two classes.

## Operational / enforcement / instruction files (must reach zero by P9-T7)

Claude ecosystem (root):
- .claude/hooks/validate-task-researcher-output.ps1
- .claude/hooks/enforce-evidence-locations.ps1
- .claude/agents/task-researcher.md
- .claude/agents/orchestrator.md
- .claude/skills/research-issue/SKILL.md
- .claude/skills/orchestrate/SKILL.md
- .claude/skills/evidence-and-timestamp-conventions/SKILL.md

Claude ecosystem (bundled):
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md
- extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md

Codex ecosystem (bundled):
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/research-issue/SKILL.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md

GitHub Copilot ecosystem (root):
- .github/prompts/research-issue.prompt.md
- .github/prompts/fillout-prd-feature.prompt.md
- .github/agents/task-researcher.agent.md

GitHub Copilot ecosystem (bundled):
- extensions/drm-copilot/resources/customizations/.github/prompts/research-issue.prompt.md
- extensions/drm-copilot/resources/customizations/.github/prompts/fillout-prd-feature.prompt.md
- extensions/drm-copilot/resources/customizations/.github/agents/task-researcher.agent.md

Tests (updated by Phases 1-3):
- tests/scripts/dev_tools/test_validate_evidence_locations.py
- tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
- tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1

Documentation accuracy (P8-T3):
- docs/engineering/claude-code-architecture.md (note: not in the 96-match grep list above; verify during P8-T3)

## Allowed (historical / generated / out-of-scope) — expected to remain

- testResults.xml (generated)
- This feature's own plan/spec/issue under docs/features/active/2026-06-24-relocate-research-canonical-location-227/ (the spec/plan reference the retired path as context; this feature's research relocates in P8-T1)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md (historical research-basis reference; out of scope per plan Open Questions)
- All historical feature documents under docs/features/active/* and docs/features/archive/* (plan/spec/issue/research/audit/feature-audit/policy-audit/code-review/user-story/baseline records). These are historical records, not enforcement/instruction files (spec Non-Goals).

The pre-change reference set above is the comparison baseline for the P9-T7 residual-reference grep. After implementation, the operational set must reach zero `artifacts/research` matches (test files updated, hooks/validators/prose updated); the allowed set is expected to still match.
