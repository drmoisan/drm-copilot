# Phase 0 Instructions Read (P0-T1)

Timestamp: 2026-10-28T13-02
Command: Read tool over the policy files listed below, in order
EXIT_CODE: 0
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> powershell -> quality-tiers -> tonality -> execution-environment skill -> evidence-and-timestamp-conventions skill -> acceptance-criteria-tracking skill

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/tonality.md`
7. `.claude/skills/execution-environment/SKILL.md`
8. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
9. `.claude/skills/acceptance-criteria-tracking/SKILL.md`

Tier classification: `quality-tiers.yml` exists at the repository root. The project entry `.claude/hooks` is classified `T3` (enforcement hooks; adapters over the Claude Code hook payload API). All four changed hook files (CHF) fall under `.claude/hooks` and are therefore T3. T3 gates: uniform line coverage >= 85% (PowerShell has no branch gate), untyped escape hatches <= 5 per file (not applicable to PowerShell), no property-test, mutation, or golden-test obligation.

Output Summary: nine policy sources read in the required order; tiers apply (CHF are T3); PowerShell toolchain is format -> analyze -> test with per-file line coverage >= 85% read from artifacts/pester/powershell-coverage.xml.
