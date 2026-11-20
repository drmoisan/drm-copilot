# Phase 0 Instructions Read (P0-T1)

Timestamp: 2026-11-03T23-07
Policy Order: CLAUDE.md, then repository tone policy, then general code-change and unit-test policies, then PowerShell-specific policies, then the .claude rule mirrors, then the execution skills.

Files read, in order:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/powershell-code-change.instructions.md`
6. `.github/instructions/powershell-unit-test.instructions.md`
7. `.claude/rules/general-code-change.md`
8. `.claude/rules/general-unit-test.md`
9. `.claude/rules/powershell.md`
10. `.claude/skills/execution-environment/SKILL.md`
11. `.claude/skills/atomic-plan-contract/SKILL.md`
12. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
13. `.claude/skills/acceptance-criteria-tracking/SKILL.md`

Key constraints applied: tests create no temporary files; Pester 5 with PoshQC settings; format, analyze, test loop restarted on change or failure; PoshQC MCP results carry no output, so counts come from JUnit and coverage XML; evidence under the feature `evidence/<kind>/` folders with no absolute paths.
