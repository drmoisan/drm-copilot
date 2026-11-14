# Phase 0 Policy Read (P0-T1)

Timestamp: 2026-11-04T03-41
Policy Order: CLAUDE.md, then the cross-language Claude rules, then the PowerShell Claude rule, then the Copilot tone policy, then the general and PowerShell instruction files (policy-compliance-order skill).

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.github/copilot-instructions.md`
6. `.github/instructions/general-code-change.instructions.md`
7. `.github/instructions/general-unit-test.instructions.md`
8. `.github/instructions/powershell-code-change.instructions.md`
9. `.github/instructions/powershell-unit-test.instructions.md`

Key constraints applied to this item:

- Toolchain order format, analyze, test; restart on any failure or file change.
- No temporary files, TestDrive, or real file-system writes in tests; mock seams instead.
- No weakened assertions; per-file line coverage of at least 85% with no regression on changed lines; no PowerShell branch gate.
- Bugfix workflow: failing regression test first, minimal fix, re-run.
- Large path: more than three production PowerShell files.
