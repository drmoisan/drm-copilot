# Phase 0 Policy Reads (remediation cycle 1, P0-T1)

Timestamp: 2026-10-01T18-58
Policy Order: CLAUDE.md, general-code-change, general-unit-test, powershell, shell, quality-tiers, ci-workflows, tonality, plan-acceptance-gates, github-actions instructions, evidence-and-timestamp-conventions skill, acceptance-criteria-tracking skill

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/shell.md`
6. `.claude/rules/quality-tiers.md`
7. `.claude/rules/ci-workflows.md`
8. `.claude/rules/tonality.md`
9. `.claude/rules/plan-acceptance-gates.md`
10. `.github/instructions/github-actions.instructions.md`
11. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
12. `.claude/skills/acceptance-criteria-tracking/SKILL.md`

Notes relevant to this cycle:
- PowerShell toolchain runs through the MCP PoshQC tools only (binding constraint 1 of the plan).
- Test files are limited to 500 lines; no temporary files in tests; no skip without an equivalent non-Windows assertion.
- Line coverage for PowerShell must remain at or above 85%; no branch gate for PowerShell.
- Evidence is written under `<FEATURE>/evidence/<kind>/` only.
