# Phase 0 Instructions-Read Evidence — Issue #286 (Remediation Cycle 2)

- Timestamp: 2026-07-03T20-00
- Policy Order: CLAUDE.md → general-code-change.md → general-unit-test.md → powershell.md → typescript.md → tonality.md

## Files Read (in required order)

1. `CLAUDE.md` — repository standing instructions, tone policy, policy-compliance reading order, architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, toolchain loop, 500-line file limit).
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy (core principles, coverage requirements).
4. `.claude/rules/powershell.md` — PowerShell toolchain (PoshQC format/analyze/test via MCP) and coding standards.
5. `.claude/rules/typescript.md` — TypeScript toolchain (Prettier/ESLint/TSC/Vitest) and coding standards.
6. `.claude/rules/tonality.md` — required professional tone policy (applies to the reworded CI-1 caveat prose).

## Scope Confirmation

This remediation is additive/textual only. No Python logic, validators, `model_policy`/`model_budget` config, or acceptance criteria are altered. Affected file classes: PowerShell (Pester verification only), Markdown (skill docs), and JSON (pack manifest).
