# Phase 0 Instructions Read (remediation plan P0-T2)

Timestamp: 2026-09-29T20-11
Policy Order: CLAUDE.md -> general code change -> general unit test -> PowerShell-specific -> tiers and plan gates -> evidence conventions -> remediation context

Files read, in order:

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
14. `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/remediation-inputs.2026-09-29T20-15.md`
15. `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/plan.2026-09-29T18-10.md`

Key constraints noted:
- 500-line limit per production and test file; line coverage >= 85% per touched file; changed lines must not regress.
- PowerShell toolchain: format, analyze, test (no type check); restart on any change or failure.
- No temporary files in tests; no edits to policy files; no edits to existing tests or fixtures.
- Evidence only under FEATURE/evidence/<kind>/.
