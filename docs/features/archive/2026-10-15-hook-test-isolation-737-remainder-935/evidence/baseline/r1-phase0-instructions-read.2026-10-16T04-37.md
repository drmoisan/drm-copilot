# R1 Phase 0 Policy Reads (P0-T1)

Timestamp: 2026-10-16T04-37
Task: [P0-T1] of `remediation-plan.2026-10-16T03-40.md`
Policy Order: CLAUDE.md -> tone policy -> general code change -> general unit test -> quality tiers -> PowerShell code change and unit test -> plan acceptance gates -> feature inputs (spec, remediation inputs, code review)

Files read, in this order (15):

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/tonality.md`
4. `.github/instructions/general-code-change.instructions.md`
5. `.claude/rules/general-code-change.md`
6. `.github/instructions/general-unit-test.instructions.md`
7. `.claude/rules/general-unit-test.md`
8. `.claude/rules/quality-tiers.md` (note: `quality-tiers.yml` exists at the repository root)
9. `.github/instructions/powershell-code-change.instructions.md`
10. `.github/instructions/powershell-unit-test.instructions.md`
11. `.claude/rules/powershell.md`
12. `.claude/rules/plan-acceptance-gates.md`
13. `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
14. `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-inputs.2026-10-16T03-20.md`
15. `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T03-20.md`

Notes:
- Root `CLAUDE.md` states no coverage threshold; the 85% line default applies. PowerShell has no branch-coverage gate.
- PowerShell toolchain (Option A): PoshQC MCP format, analyze, test; type checking not applicable.
