# Remediation Cycle 1 - Phase 0 Instructions Read (P0-T9)

Timestamp: 2026-10-16T11-25
Policy Order: CLAUDE.md, copilot-instructions, general-code-change, general-unit-test, quality-tiers, powershell, python

Files read (P0-T3 through P0-T8, in order):

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md`
4. `.claude/rules/general-unit-test.md`
5. `.claude/rules/quality-tiers.md`
6. `quality-tiers.yml`
7. `.claude/rules/powershell.md`
8. `.claude/rules/python.md`

Notes:

- `quality-tiers.yml:13-14` maps `scripts/powershell/PoshQC` to tier T3: no property-test density or mutation-score obligation.
- The root `CLAUDE.md` states no coverage threshold, so the 85% line default governs; PowerShell has no branch-coverage gate.
- Toolchain order for PowerShell: format, analyze, test. Files at most 500 lines. No temporary files in tests.
