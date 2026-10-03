# P0-T2 Policy files read

Timestamp: 2026-10-03T09-36
Policy Order: CLAUDE.md, then general code-change, general unit-test, quality tiers, language-specific (PowerShell), then tonality, plan acceptance gates, and evidence conventions.

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/tonality.md`
7. `.claude/rules/plan-acceptance-gates.md`
8. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

`.claude/rules/python.md` is not read because no Python file is edited by this plan; PARITY-PYTEST only runs existing Python tests.

Timestamp source: the `TS=` value printed by SCRATCH/steps/p0-t2.ps1 (A0 only).
