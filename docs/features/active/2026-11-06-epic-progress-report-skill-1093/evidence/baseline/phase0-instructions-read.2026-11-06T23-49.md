# Phase 0 Policy Reads — Issue #1093

Timestamp: 2026-11-06T23-49
Command: Read tool over the eleven files below, in order
EXIT_CODE: 0
Output Summary: eleven policy and environment files read in the required order before any code or test change.

Policy Order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.github/copilot-instructions.md`
7. `.github/instructions/general-code-change.instructions.md`
8. `.github/instructions/general-unit-test.instructions.md`
9. `.github/instructions/powershell-code-change.instructions.md`
10. `.github/instructions/powershell-unit-test.instructions.md`
11. `.claude/skills/execution-environment/SKILL.md`

Notes:

- `quality-tiers.yml` exists at the repository root, so the tier system applies; the uniform 85 percent line-coverage threshold applies to PowerShell, with no branch gate (Pester does not measure branch coverage).
- Tests use no temporary file, network call or wall-clock read; files stay at or below 700 lines.
