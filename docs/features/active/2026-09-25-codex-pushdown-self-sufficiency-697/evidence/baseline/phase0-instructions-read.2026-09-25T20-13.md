# Phase 0 Instructions Read (Issue #697)

Timestamp: 2026-09-25T20-13
Policy Order: CLAUDE.md -> general code change -> general unit test -> quality tiers -> language rules (Python, PowerShell, TypeScript) -> commenting -> tonality -> plan acceptance gates -> atomic plan contract -> evidence conventions

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/python.md`
6. `.claude/rules/python-suppressions.md`
7. `.claude/rules/powershell.md`
8. `.claude/rules/typescript.md`
9. `.claude/rules/typescript-suppressions.md`
10. `.claude/rules/self-explanatory-code-commenting.md`
11. `.claude/rules/tonality.md`
12. `.claude/rules/plan-acceptance-gates.md`
13. `.claude/skills/atomic-plan-contract/SKILL.md`
14. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

Key constraints noted: 500-line file limit; line coverage >= 85% and branch >= 75% (PowerShell line only); no temporary files in tests; suppressions only per pre-authorized patterns; evidence only under `<FEATURE>/evidence/<kind>/`; no absolute host paths in artifacts.
