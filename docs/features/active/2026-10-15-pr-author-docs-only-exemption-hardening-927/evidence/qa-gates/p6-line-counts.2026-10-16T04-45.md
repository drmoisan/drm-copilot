# P6-T7 Line Counts (issue #927, AC-20, AC-M22; loop pass 2)

Timestamp: 2026-10-16T04-45
Command: grep -c '^' <each file listed below>
EXIT_CODE: 0
Output Summary: Every edited hook and its mirror prints its planned count (docs-only 224, pr-author 359, Claude gate 490, resolution sibling 278, Codex gate 410). The four helper copies print 397. Every other count (the three DocsOnly suites, suites A to E, and the eight Appendix K suites) is below 500; the largest is 467.

## Hooks and mirrors

- .claude/hooks/enforce-pr-author-skill.docs-only.ps1: 224 (mirror 224)
- .claude/hooks/enforce-pr-author-skill.ps1: 359 (mirror 359)
- .claude/hooks/enforce-epic-merge-gate.ps1: 490 (mirror 490)
- .claude/hooks/enforce-epic-merge-gate-resolution.ps1: 278 (mirror 278)
- .codex/hooks/enforce-epic-merge-gate.ps1: 410 (mirror 410)

## Helper paths

- .claude/hooks/hook-docs-only-diff.ps1: 397
- .codex/hooks/hook-docs-only-diff.ps1: 397
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1: 397
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1: 397

## DocsOnly suites

- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1: 242
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1: 261
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1: 163

## New suites A to E

- A tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1: 318
- B tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1: 218
- C tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1: 199
- D tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1: 169
- E tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1: 159

## Appendix K suites

- enforce-epic-merge-gate.Tests.ps1: 467
- enforce-epic-merge-gate.Authorization.Tests.ps1: 183
- enforce-epic-merge-gate.ItemResolution.Tests.ps1: 311
- enforce-epic-merge-gate.WorktreeResolution.Tests.ps1: 257
- enforce-epic-merge-gate.TriggerScoping.Tests.ps1: 189
- enforce-epic-merge-gate.Coverage.Tests.ps1: 45
- hook-command-parser.AcceptanceCases.Tests.ps1: 232
- hook-command-consumers.Issue824.Tests.ps1: 130
