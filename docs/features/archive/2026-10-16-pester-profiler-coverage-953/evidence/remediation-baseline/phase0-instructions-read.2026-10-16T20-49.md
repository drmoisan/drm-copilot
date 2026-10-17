# Phase 0 Instructions Read (remediation cycle 3, P0-T3 through P0-T9)

Timestamp: 2026-10-16T20-49
Policy Order: CLAUDE.md, copilot-instructions, general-code-change, general-unit-test, quality-tiers, powershell, python, ci-workflows, github-actions

Files read, in order:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md`
4. `.claude/rules/general-unit-test.md`
5. `.claude/rules/quality-tiers.md`
6. `quality-tiers.yml`
7. `.claude/rules/powershell.md`
8. `.claude/rules/python.md`
9. `.claude/rules/ci-workflows.md`
10. `.github/instructions/github-actions.instructions.md`

Observations:

- `quality-tiers.yml:13-14` classifies `scripts/powershell/PoshQC` as tier T3: no property-test density or mutation-score obligation.
- The root `CLAUDE.md` states no coverage threshold, so the 85% line default governs; Pester measures no branch coverage, so no branch gate applies.
- Toolchain order for PowerShell: format, analyze, test (type checking not applicable). Per the plan's "No MCP PoshQC evidence" rule, all PoshQC evidence comes from the self-hosted module `scripts/powershell/PoshQC/PoshQC.psd1`.
- File size limit: 500 lines for production and test code.
