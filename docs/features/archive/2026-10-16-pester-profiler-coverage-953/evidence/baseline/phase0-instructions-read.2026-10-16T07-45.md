# Phase 0 Instructions Read (issue #953)

Timestamp: 2026-10-16T07-45
Policy Order: CLAUDE.md, copilot-instructions, general-code-change, general-unit-test, quality-tiers, powershell, python, python-suppressions, shell, github-actions, ci-workflows

## Files read (P0-T7 through P0-T14, in order)

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md`
4. `.claude/rules/general-unit-test.md`
5. `.claude/rules/quality-tiers.md`
6. `quality-tiers.yml` (lines 13-14: `scripts/powershell/PoshQC` is tier T3; no property-test or mutation obligation)
7. `.claude/rules/powershell.md`
8. `.claude/rules/python.md`
9. `.claude/rules/python-suppressions.md`
10. `.claude/rules/shell.md`
11. `.github/instructions/github-actions.instructions.md`
12. `.claude/rules/ci-workflows.md`

## Notes

- Root `CLAUDE.md` states no coverage threshold, so the 85% line default governs; PowerShell has no branch-coverage gate.
- Seven-stage toolchain loop with restart on failure or file change; 500-line file limit; no temporary files in tests.
- PowerShell Change Budget: at most three production PowerShell files written with Write/Edit outside the large path.
