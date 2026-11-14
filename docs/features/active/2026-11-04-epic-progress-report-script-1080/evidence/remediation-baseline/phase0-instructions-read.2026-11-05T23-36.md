# Phase 0 Instructions Read (Issue #1080, remediation cycle 1, P0-T1)

Timestamp: 2026-11-05T23-36
Command: Read tool over each file below, in the listed order
EXIT_CODE: 0

Policy Order: CLAUDE.md, then the general code-change and unit-test rules, then the tier rule, then the PowerShell rule, then the authoritative `.github` copies, per the `policy-compliance-order` skill.

## Policy files read (10)

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

## Review inputs read (4)

1. `remediation-inputs.2026-11-05T23-27.md` (findings 1 to 4, all autonomous)
2. `code-review.2026-11-05T23-23.md` (Go; two Minor, one Nit, four Info)
3. `policy-audit.2026-11-05T23-23.md` (fully compliant; two non-blocking gaps)
4. `feature-audit.2026-11-05T23-23.md` (AC1 to AC9 PASS)

## Applicable constraints noted

- Toolchain order format, analyze, test; restart on change or failure. PowerShell has no type-check step and no branch-coverage gate; line coverage at or above 85% per production file, no regression on changed lines.
- Wrapper seams for native executables; mocks match production signatures; no temporary files in tests; one behavior per `It`.
- File-size tiers 500, 700, and 800 logical lines.
- No policy file is modified; no Python is added.

Output Summary: 10 policy files and 4 review inputs read in the required order; the cycle scope is the four findings in the four change-set files.
