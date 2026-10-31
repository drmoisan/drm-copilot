# Phase 0 Instructions Read (Issue #1010)

Timestamp: 2026-10-30T19-47
Command: Read (policy files in policy-compliance-order)
EXIT_CODE: 0
Output Summary: Nine files read in order; `.claude/hooks` and `.codex/hooks` are T3 in `quality-tiers.yml`.

Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> language/domain rules (quality-tiers, powershell, tonality) -> environment and evidence skills

## Files Read

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/tonality.md`
7. `.claude/skills/execution-environment/SKILL.md`
8. `.claude/skills/acceptance-criteria-tracking/SKILL.md`
9. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

## Tier Classification (from `quality-tiers.yml`)

- `.claude/hooks`: T3 ("Enforcement hooks shipped to consumers; adapters over the Claude Code hook payload API")
- `.codex/hooks`: T3 ("Enforcement hooks shipped to consumers; adapters over the Codex hook API")
- `.claude/lib/worktree-resolution`: T3 (consumed, not edited)

Consequence: no property-test or mutation obligation; uniform line coverage >= 85% per edited production file; no PowerShell branch gate.
