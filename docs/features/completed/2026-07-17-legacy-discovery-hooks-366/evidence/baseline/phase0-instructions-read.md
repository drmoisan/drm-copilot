# Phase 0 — Policy Read Evidence

- Timestamp: 2026-07-18T00-00
- Feature: 2026-07-17-legacy-discovery-hooks-366

## Policy Order

1. [P0-T1] `.github/copilot-instructions.md`
2. [P0-T2] `.github/instructions/general-code-change.instructions.md`
3. [P0-T3] `.github/instructions/general-unit-test.instructions.md`
4. [P0-T4] `.github/instructions/powershell-code-change.instructions.md`
5. [P0-T5] `.github/instructions/powershell-unit-test.instructions.md`

## Files Read (full contents)

- `.github/copilot-instructions.md` — repository tone/communication policy (strictly professional, factual, neutral tone; no jokes/hype/metaphor/emoji).
- `.github/instructions/general-code-change.instructions.md` — baseline design principles, class/function guidance, error handling, module structure (500-line cap), naming, I/O boundaries, and the mandatory format-lint-typecheck-test toolchain loop.
- `.github/instructions/general-unit-test.instructions.md` — cross-language unit test policy: independence, isolation, fast execution, determinism, readability, coverage floors, scenario completeness, AAA structure, no external dependencies, no temp files.
- `.github/instructions/powershell-code-change.instructions.md` — PowerShell-specific toolchain (PoshQC format/analyze/test via MCP functions only), advanced-function/CmdletBinding conventions, ShouldProcess for state changes, Write-Error/throw for failures, 500-line cap.
- `.github/instructions/powershell-unit-test.instructions.md` — Pester v5.x via `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, sparing mocking, `*.Tests.ps1` naming, `Describe`/`Context`/`It` structure mirroring source layout.

No policy document under `.claude/rules/` or `.github/instructions/` was modified as a side effect of this read.
