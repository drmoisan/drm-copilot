# Phase 0 — Policy Instructions Read

- Timestamp: 2026-06-24T15-30
- Issue: #231
- Feature: require-pr-author-agent-for-prs

## Policy Order

Read in the required policy-compliance order for PowerShell-scoped work:

1. `CLAUDE.md` — repository standing instructions, tone policy, policy-compliance reading order, architecture.
2. `.github/copilot-instructions.md` — repository tone/communication policy (read; authoritative tone source; not modified per directive item 8).
3. `.github/instructions/general-code-change.instructions.md` — baseline code change rules (mirrored by `.claude/rules/general-code-change.md`, read).
4. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (mirrored by `.claude/rules/general-unit-test.md`, read).
5. `.github/instructions/powershell-code-change.instructions.md` — PowerShell-specific code change rules.
6. `.github/instructions/powershell-unit-test.instructions.md` — PowerShell-specific unit test rules.
7. `.claude/rules/powershell.md` — PowerShell toolchain and coding standards (auto-loaded; read).
8. `.claude/rules/quality-tiers.md` — module rigor tier system and uniform coverage thresholds (auto-loaded; read).

## Files Read (explicit list)

- `CLAUDE.md`
- `.github/instructions/powershell-code-change.instructions.md`
- `.github/instructions/powershell-unit-test.instructions.md`
- `.claude/rules/powershell.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/tonality.md`

## Notes

- `.github/copilot-instructions.md` and `.github/instructions/*` are authoritative tone/policy sources. Per execution directive item 8 they MUST NOT be modified.
- PowerShell toolchain contract: format (`run_poshqc_format`) -> analyze (`run_poshqc_analyze`) -> test (`run_poshqc_test`); restart from format on any failure or file change. Type checking is not applicable to PowerShell.
- Coverage policy: line >= 85%, branch >= 75% uniformly across tiers; no regression on changed lines.
- File size limit: 500 lines for production, test, and reusable script files.
