# Phase 0 Policy Reading ([P0-T1])

Timestamp: 2026-09-25T18-56

Policy Order:
1. CLAUDE.md
2. .github/copilot-instructions.md
3. .github/instructions/tonality.instructions.md
4. .github/instructions/general-code-change.instructions.md
5. .github/instructions/general-unit-test.instructions.md
6. .github/instructions/powershell-code-change.instructions.md
7. .github/instructions/powershell-unit-test.instructions.md
8. .github/instructions/python-code-change.instructions.md
9. .github/instructions/python-unit-test.instructions.md
10. .github/instructions/python-suppressions.instructions.md
11. .claude/rules/general-code-change.md
12. .claude/rules/general-unit-test.md
13. .claude/rules/quality-tiers.md
14. .claude/rules/powershell.md
15. .claude/rules/python.md
16. .claude/rules/python-suppressions.md
17. .claude/rules/tonality.md
18. .claude/rules/orchestrator-state.md
19. .claude/rules/plan-acceptance-gates.md

Files Read:
- CLAUDE.md
- .github/copilot-instructions.md
- .github/instructions/tonality.instructions.md
- .github/instructions/general-code-change.instructions.md
- .github/instructions/general-unit-test.instructions.md
- .github/instructions/powershell-code-change.instructions.md
- .github/instructions/powershell-unit-test.instructions.md
- .github/instructions/python-code-change.instructions.md
- .github/instructions/python-unit-test.instructions.md
- .github/instructions/python-suppressions.instructions.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/quality-tiers.md
- .claude/rules/powershell.md
- .claude/rules/python.md
- .claude/rules/python-suppressions.md
- .claude/rules/tonality.md
- .claude/rules/orchestrator-state.md
- .claude/rules/plan-acceptance-gates.md

Notes: No conflicting instructions were identified between the files read. PowerShell rules require the 500-line cap, advanced functions, no temporary files in tests, and the mock-signature parity and seam rules; the plan's section 0 rule 4 governs where counts are read (PoshQC module functions or R-SCOPED, not MCP results).
