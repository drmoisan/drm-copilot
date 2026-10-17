# R1 QC Line Counts (Issue #927, AC-20, AC-M22; loop pass 2)

Timestamp: 2026-10-16T08-45
Command: grep -c '^' (four helper paths, Claude gate and mirror, Codex gate and mirror, suites A, B, D, E, F, DocsOnly suite)
EXIT_CODE: 0
Output Summary: Every count matches the plan value (suite E 159 because CR-5 is retained) and every value is below 500. No formatter line-count branch applies (no POST_FORMAT_COUNT record exists).

LINE_COUNT: .claude/hooks/hook-docs-only-diff.ps1 478
LINE_COUNT: .codex/hooks/hook-docs-only-diff.ps1 478
LINE_COUNT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 478
LINE_COUNT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 478
LINE_COUNT: .claude/hooks/enforce-epic-merge-gate.ps1 491
LINE_COUNT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 491
LINE_COUNT: .codex/hooks/enforce-epic-merge-gate.ps1 411
LINE_COUNT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 411
LINE_COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 328
LINE_COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 245
LINE_COUNT: tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 239
LINE_COUNT: tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 159
LINE_COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 188
LINE_COUNT: tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 243
ALL_BELOW_500: true
