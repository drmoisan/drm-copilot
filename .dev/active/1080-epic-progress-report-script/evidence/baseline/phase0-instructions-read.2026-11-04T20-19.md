# Phase 0 Instructions Read (Issue #1080)

Timestamp: 2026-11-04T20-19
Command: Read tool, files read in the order below
EXIT_CODE: 0
Policy Order: CLAUDE.md, general code change, general unit test, quality tiers, PowerShell rule, then the .github copies (tone, general code change, general unit test, PowerShell code change, PowerShell unit test)

## Files Read

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
11. the recovered reference script (read in full; read-only, location not recorded)

Output Summary: ten policy files and the recovered reference script read in the plan order. Key constraints applied: wrapper seams `Invoke-<Tool>Exe -<Tool>Args <string[]>`, mock signature parity, ShouldProcess for the state write, no temporary files or wall clock in tests, line coverage of at least 85% per production file (no Pester branch gate), file-size tiers 500/700/800, direct mode with at most three production PowerShell files.
