# P0-T14 Mirror-pair baseline (MP-EXIST)

Timestamp: 2026-10-08T23-19
Command: sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1 .claude/hooks/enforce-pr-author-skill.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1 .claude/hooks/enforce-epic-merge-gate-authorization.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1 .claude/hooks/enforce-epic-worktree-removal-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 .claude/lib/worktree-resolution/EpicScopeResolution.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/EpicScopeResolution.psm1 .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
EXIT_CODE: 0
Output Summary:
  PAIR equal=True primary=.claude/hooks/enforce-pr-author-skill.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1
  PAIR equal=True primary=.claude/hooks/enforce-pr-author-skill-helpers.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
  PAIR equal=True primary=.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
  PAIR equal=True primary=.claude/hooks/enforce-epic-merge-gate.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
  PAIR equal=True primary=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1
  PAIR equal=True primary=.claude/hooks/enforce-epic-merge-gate-authorization.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1
  PAIR equal=True primary=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
  PAIR equal=True primary=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
  PAIR equal=True primary=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
  PAIR equal=True primary=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1
  PAIR equal=True primary=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1
  PAIR equal=True primary=.claude/lib/worktree-resolution/EpicScopeResolution.psm1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/EpicScopeResolution.psm1
  PAIR equal=True primary=.claude/skills/orchestrate/SKILL.md mirror=extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
  PAIR-SUMMARY pairs=13 unequal=0

## Full output

```text
PAIR equal=True primary=.claude/hooks/enforce-pr-author-skill.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1
PAIR equal=True primary=.claude/hooks/enforce-pr-author-skill-helpers.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
PAIR equal=True primary=.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
PAIR equal=True primary=.claude/hooks/enforce-epic-merge-gate.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
PAIR equal=True primary=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1
PAIR equal=True primary=.claude/hooks/enforce-epic-merge-gate-authorization.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1
PAIR equal=True primary=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
PAIR equal=True primary=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
PAIR equal=True primary=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
PAIR equal=True primary=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1
PAIR equal=True primary=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1
PAIR equal=True primary=.claude/lib/worktree-resolution/EpicScopeResolution.psm1 mirror=extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/EpicScopeResolution.psm1
PAIR equal=True primary=.claude/skills/orchestrate/SKILL.md mirror=extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
PAIR-SUMMARY pairs=13 unequal=0
```
