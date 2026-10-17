# P1-T31 Line counts (500-line cap)

Timestamp: 2026-10-12T18-23
Command: grep -c '' .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1
EXIT_CODE: 0
Output Summary:
- All eight values are at most 500 (largest: helpers at 438).
- Main hook 355 and helpers 438 match the plan's expected totals.
- Result: PASS

LINES: .claude/hooks/enforce-pr-author-skill.ps1 355
LINES: .claude/hooks/enforce-pr-author-skill-helpers.ps1 438
LINES: .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 233
LINES: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 265
LINES: tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 218
LINES: tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 209
LINES: tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 149
LINES: tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1 141
