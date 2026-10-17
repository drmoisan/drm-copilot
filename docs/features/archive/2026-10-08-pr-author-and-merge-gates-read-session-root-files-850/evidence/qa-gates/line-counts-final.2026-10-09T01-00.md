# P8-T14 Line caps over FINAL-PS

Timestamp: 2026-10-09T01-00
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .claude/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
EXIT_CODE: 0
Output Summary:
  .claude/hooks/enforce-pr-author-skill.ps1 LineCount=326
  .claude/hooks/enforce-pr-author-skill-helpers.ps1 LineCount=429
  .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 LineCount=200
  .claude/hooks/enforce-epic-merge-gate.ps1 LineCount=470
  .claude/hooks/enforce-epic-merge-gate-resolution.ps1 LineCount=278
  .claude/hooks/enforce-epic-worktree-removal-gate.ps1 LineCount=459
  .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 LineCount=262
  .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 LineCount=464
  .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 LineCount=497
  .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 LineCount=484
  tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 LineCount=341
  tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 LineCount=297
  tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 LineCount=167
  tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 LineCount=193
  tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 LineCount=100
  tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 LineCount=154
  tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 LineCount=283
  tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 LineCount=452
  tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 LineCount=180
  tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 LineCount=498
  tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 LineCount=457
  tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 LineCount=170
  tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 LineCount=176
  tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 LineCount=243
  tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 LineCount=230
  tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 LineCount=450
  tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 LineCount=118
  tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 LineCount=405
  tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 LineCount=374

## Full output

```text
.claude/hooks/enforce-pr-author-skill.ps1 LineCount=326
.claude/hooks/enforce-pr-author-skill-helpers.ps1 LineCount=429
.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 LineCount=200
.claude/hooks/enforce-epic-merge-gate.ps1 LineCount=470
.claude/hooks/enforce-epic-merge-gate-resolution.ps1 LineCount=278
.claude/hooks/enforce-epic-worktree-removal-gate.ps1 LineCount=459
.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 LineCount=262
.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 LineCount=464
.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 LineCount=497
.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 LineCount=484
tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 LineCount=341
tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 LineCount=297
tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 LineCount=167
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 LineCount=193
tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 LineCount=100
tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 LineCount=154
tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 LineCount=283
tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 LineCount=452
tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 LineCount=180
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 LineCount=498
tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 LineCount=457
tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 LineCount=170
tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 LineCount=176
tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 LineCount=243
tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 LineCount=230
tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 LineCount=450
tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 LineCount=118
tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 LineCount=405
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 LineCount=374
```
