# Phase 0 policy reads (remediation cycle 2, P0-T3 to P0-T9)

Timestamp: 2026-10-16T15-33
Policy Order: CLAUDE.md, copilot-instructions, general-code-change, general-unit-test, quality-tiers, powershell, python, ci-workflows, github-actions

Files read (in order):

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

- `quality-tiers.yml:13-14`: `scripts/powershell/PoshQC` is tier `T3` (no property-test or mutation obligation).
- Coverage: the root `CLAUDE.md` states no coverage threshold, so the 85% line default governs; Pester measures no branch coverage, so no PowerShell branch gate applies.
- File size limit: 500 lines for production and test code.
- Workflow `pwsh` steps: a deliberately failing nested command needs an explicit exit-code reset or `exit 0`; workflows must pass actionlint and keep `on:` triggers.
