# Phase 0 Instructions Read (P0-T2)

Timestamp: 2026-09-29T18-55
Policy Order: (1) tone -> (2) general code change -> (3) general unit test -> (4) PowerShell code change and unit test -> (5) quality tiers and plan acceptance gates -> (6) evidence conventions

Files read (in order):

1. `.github/copilot-instructions.md`
2. `CLAUDE.md`
3. `.claude/rules/tonality.md`
4. `.github/instructions/general-code-change.instructions.md`
5. `.claude/rules/general-code-change.md`
6. `.github/instructions/general-unit-test.instructions.md`
7. `.claude/rules/general-unit-test.md`
8. `.github/instructions/powershell-code-change.instructions.md`
9. `.github/instructions/powershell-unit-test.instructions.md`
10. `.claude/rules/powershell.md`
11. `.claude/rules/quality-tiers.md`
12. `.claude/rules/plan-acceptance-gates.md`
13. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

Key constraints noted:

- Professional, neutral tone; no hyperbole or humor.
- 500-line limit per production and test file.
- PowerShell line coverage >= 85%; no branch-coverage gate for Pester; no coverage regression on changed lines.
- PowerShell toolchain via MCP: format -> analyze -> test; restart on any change or failure.
- No temporary files in tests; mock sparingly.
- Evidence only under `<FEATURE>/evidence/<kind>/`.
