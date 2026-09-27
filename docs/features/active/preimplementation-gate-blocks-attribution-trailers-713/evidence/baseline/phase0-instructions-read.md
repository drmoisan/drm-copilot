# Phase 0 Policy Reading (issue #713)

Timestamp: 2026-09-27T03-15

Policy Order:
1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md`
4. `.github/instructions/general-code-change.instructions.md`
5. `.claude/rules/general-unit-test.md`
6. `.github/instructions/general-unit-test.instructions.md`
7. `.claude/rules/powershell.md`
8. `.github/instructions/powershell-code-change.instructions.md`
9. `.github/instructions/powershell-unit-test.instructions.md`
10. `.claude/rules/quality-tiers.md`
11. `.claude/rules/tonality.md`
12. `.github/instructions/tonality.instructions.md`
13. `.claude/rules/plan-acceptance-gates.md`

Files Read:
1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md`
4. `.github/instructions/general-code-change.instructions.md`
5. `.claude/rules/general-unit-test.md`
6. `.github/instructions/general-unit-test.instructions.md`
7. `.claude/rules/powershell.md`
8. `.github/instructions/powershell-code-change.instructions.md`
9. `.github/instructions/powershell-unit-test.instructions.md`
10. `.claude/rules/quality-tiers.md`
11. `.claude/rules/tonality.md`
12. `.github/instructions/tonality.instructions.md`
13. `.claude/rules/plan-acceptance-gates.md`

Notes: PowerShell is the only in-scope code language. Toolchain: PoshQC format, PoshQC analyze, Pester (type checking not applicable). Line coverage threshold 85 percent; no PowerShell branch-coverage gate. 500-line file cap.
