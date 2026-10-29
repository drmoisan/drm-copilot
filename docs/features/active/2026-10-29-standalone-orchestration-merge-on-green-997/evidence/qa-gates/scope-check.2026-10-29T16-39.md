# Scope Check Against MERGE_BASE (issue #997)

Timestamp: 2026-10-29T16-39
Command: MB=$(git merge-base origin/main HEAD); git diff --quiet "$MB" -- <path> for each path below; git diff --name-only "$MB"; git status --porcelain
EXIT_CODE: 0
Output Summary: every protected path has no diff against the merge base; the combined change list contains only files named in the plan plus the feature folder.

Protected paths (git diff --quiet exit code):

| Path | Exit |
| --- | --- |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 0 |
| `.claude/hooks/hook-docs-only-diff.ps1` | 0 |
| `.claude/skills/epic-orchestrate/SKILL.md` | 0 |
| `.claude/settings.json` | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 0 |
| `.claude/skills/execution-environment/SKILL.md` | 0 |
| `.agents/skills/execution-environment/SKILL.md` | 0 |
| `.github/skills/execution-environment/SKILL.md` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | 0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | 0 |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | 0 |
| `.codex/` | 0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/` | 0 |

Combined file list (tracked changes from `git diff --name-only` plus untracked entries from `git status --porcelain`):

- `.claude/hooks/enforce-epic-merge-gate.ps1`
- `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` (untracked, new)
- `.claude/rules/orchestrator-state.md`
- `.claude/rules/parallel-orchestration.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` (untracked, new)
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1` (untracked, new)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` (untracked, new)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` (untracked, new)
- `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997/` (feature folder and evidence, untracked)
