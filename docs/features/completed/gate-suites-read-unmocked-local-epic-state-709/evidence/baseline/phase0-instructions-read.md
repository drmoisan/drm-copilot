# P0-T1 Policy Reads

Timestamp: 2026-09-27T09-58
Policy Order: CLAUDE.md, then repository tone policy, then general code-change and unit-test policy, then PowerShell-specific policy, then the .claude/rules mirrors (policy-compliance-order skill)

Files read, in order:

1. CLAUDE.md
2. .github/copilot-instructions.md
3. .github/instructions/tonality.instructions.md
4. .github/instructions/general-code-change.instructions.md
5. .github/instructions/general-unit-test.instructions.md
6. .github/instructions/powershell-code-change.instructions.md
7. .github/instructions/powershell-unit-test.instructions.md
8. .claude/rules/general-code-change.md
9. .claude/rules/general-unit-test.md
10. .claude/rules/quality-tiers.md
11. .claude/rules/powershell.md
12. .claude/rules/tonality.md

Key constraints applied to this plan: 500-line file limit; no temporary files in tests; Pester 5.x; format, analyze, test loop with restart on change or failure; line coverage >= 85% with no regression (no PowerShell branch gate); at most three test files per batch.
