# Phase 0 Instructions Read (issue #997)

Timestamp: 2026-10-29T16-08
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> quality-tiers -> language rules (PowerShell, Python) -> commenting -> plan-acceptance-gates -> execution-environment -> evidence conventions -> feature inputs

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md` (no `quality-tiers.yml` at the repository root is assumed; tier gates apply only when it exists)
5. `.claude/rules/powershell.md`
6. `.claude/rules/python.md`
7. `.claude/rules/python-suppressions.md`
8. `.claude/rules/self-explanatory-code-commenting.md`
9. `.claude/rules/plan-acceptance-gates.md`
10. `.claude/skills/execution-environment/SKILL.md`
11. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
12. `FEATURE/spec.md`
13. `FEATURE/research/research.2026-10-29T11-46.md`

Output Summary: all thirteen inputs read; work mode `full-bug`, AC source `spec.md` (AC-01 to AC-32).
