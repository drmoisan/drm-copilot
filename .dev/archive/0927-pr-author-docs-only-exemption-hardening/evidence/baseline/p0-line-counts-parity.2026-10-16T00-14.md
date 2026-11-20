# P0-T6 Line Counts and Mirror Parity (issue #927)

Timestamp: 2026-10-16T00-14
Command: grep -c '^' .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1
EXIT_CODE: 0
Output Summary: Line counts match the plan anchors (265, 355, 472, 243, 385, 218, 209, 149). All five canonical/mirror pairs are byte-identical (cmp -s exit 0, equal git hashes). None of the four helper paths exists yet (test -f exit 1 for each).

## Line counts

- .claude/hooks/enforce-pr-author-skill.docs-only.ps1: 265
- .claude/hooks/enforce-pr-author-skill.ps1: 355
- .claude/hooks/enforce-epic-merge-gate.ps1: 472
- .claude/hooks/enforce-epic-merge-gate-resolution.ps1: 243
- .codex/hooks/enforce-epic-merge-gate.ps1: 385
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1: 218
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1: 209
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1: 149

## Mirror parity (cmp -s)

- CMP enforce-pr-author-skill.docs-only.ps1 (claude bundle): exit 0
- CMP enforce-pr-author-skill.ps1 (claude bundle): exit 0
- CMP enforce-epic-merge-gate.ps1 (claude bundle): exit 0
- CMP enforce-epic-merge-gate-resolution.ps1 (claude bundle): exit 0
- CMP .codex/hooks/enforce-epic-merge-gate.ps1 (codex bundle): exit 0

## git hash-object (canonical = mirror)

- HASH .claude/hooks/enforce-pr-author-skill.docs-only.ps1: fca2d311fd6c6fc8ff842dd57d135776df06bc23 (mirror equal)
- HASH .claude/hooks/enforce-pr-author-skill.ps1: 1f92d257e1c5f3b821cef4ef3475cb1dcff2aa32 (mirror equal)
- HASH .claude/hooks/enforce-epic-merge-gate.ps1: 19f7c5e2384713176e3fce61014c5cd937cf9f81 (mirror equal)
- HASH .claude/hooks/enforce-epic-merge-gate-resolution.ps1: fd886ab35a4c7e482d29e4270c3dd87c98a776fa (mirror equal)
- HASH .codex/hooks/enforce-epic-merge-gate.ps1: 807a776677f0364878a400f07bd7d9cd24a91694 (mirror equal)

## Helper paths (test -f)

- .claude/hooks/hook-docs-only-diff.ps1: exit 1
- .codex/hooks/hook-docs-only-diff.ps1: exit 1
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1: exit 1
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1: exit 1
