# Phase 0 policy read (P0-T1)

Timestamp: 2026-10-16T00-17

Policy Order:

1. CLAUDE.md
2. .github/copilot-instructions.md
3. .github/instructions/general-code-change.instructions.md
4. .github/instructions/general-unit-test.instructions.md
5. .github/instructions/powershell-code-change.instructions.md
6. .github/instructions/powershell-unit-test.instructions.md
7. .claude/rules/general-code-change.md
8. .claude/rules/general-unit-test.md
9. .claude/rules/powershell.md
10. .claude/rules/quality-tiers.md
11. .claude/rules/tonality.md

Files read:

- CLAUDE.md
- .github/copilot-instructions.md
- .github/instructions/general-code-change.instructions.md
- .github/instructions/general-unit-test.instructions.md
- .github/instructions/powershell-code-change.instructions.md
- .github/instructions/powershell-unit-test.instructions.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/powershell.md
- .claude/rules/quality-tiers.md
- .claude/rules/tonality.md

Output Summary: All eleven policy files were read in the order above. CLAUDE.md and the four .claude/rules files other than powershell.md were provided in loaded session context and the remaining files were read from disk.
Command: test -f CLAUDE.md && test -f .github/copilot-instructions.md && test -f .github/instructions/general-code-change.instructions.md && test -f .github/instructions/general-unit-test.instructions.md && test -f .github/instructions/powershell-code-change.instructions.md && test -f .github/instructions/powershell-unit-test.instructions.md && test -f .claude/rules/general-code-change.md && test -f .claude/rules/general-unit-test.md && test -f .claude/rules/powershell.md && test -f .claude/rules/quality-tiers.md && test -f .claude/rules/tonality.md && echo ALL-11-PRESENT
EXIT_CODE: 0
Fields Added At: 2026-10-16T04-56
Verification Output: ALL-11-PRESENT (all eleven listed policy files exist on disk).
Note: No command was run when this artifact was first written; the read was an observation. The command shown above is the verifying command run when the missing fields were added, and it confirms that each of the eleven files listed under Files read exists.
