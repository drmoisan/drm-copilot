# Phase 0 — Instructions Read Evidence

Timestamp: 2026-04-12T02-15

Policy Order:
1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.github/instructions/powershell-code-change.instructions.md`
5. `.github/instructions/powershell-unit-test.instructions.md`

## Files Read

- [x] `.github/copilot-instructions.md` — Tone policy: strictly professional, factual, neutral tone; no jokes, humor, metaphors, emojis, hype, or grandiose narration.
- [x] `.github/instructions/general-code-change.instructions.md` — Agent code change policy: design principles, classes/functions/APIs, error handling, module structure, naming/docs, performance/I/O, interaction with existing code, mandatory toolchain loop (format → lint → type-check → test).
- [x] `.github/instructions/general-unit-test.instructions.md` — General unit test policy: independence, isolation, fast execution, determinism, readability, coverage (≥80% repo-wide, ≥90% new code), scenario completeness, Arrange-Act-Assert pattern, no external dependencies, no temp files.
- [x] `.github/instructions/powershell-code-change.instructions.md` — PowerShell code change policy: Invoke-Formatter via MCP, PSScriptAnalyzer via MCP, PowerShell 7+ compatibility, advanced functions with CmdletBinding, ShouldProcess for destructive actions, no Invoke-Expression.
- [x] `.github/instructions/powershell-unit-test.instructions.md` — PowerShell unit test policy: Pester v5.x, Describe/Context/It structure, *.Tests.ps1 naming, mcp_drmcopilotext_run_poshqc_test as approved test runner, mirror test location to code under test.
