# Phase 0 Instructions Read - Remediation Cycle 2 (Issue 1080)

Timestamp: 2026-11-06T00-30
Plan: docs/features/active/2026-11-04-epic-progress-report-script-1080/remediation-plan.2026-11-06T00-11.md
Task: P0-T1
Policy Order: CLAUDE.md, then general code change, then general unit test, then quality tiers, then PowerShell rules, then the authoritative `.github` sources.

## Policy files read (in order)

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

## Review inputs read

1. `docs/features/active/2026-11-04-epic-progress-report-script-1080/remediation-inputs.2026-11-06T00-11.md`
2. `docs/features/active/2026-11-04-epic-progress-report-script-1080/code-review.2026-11-06T00-11.md`
3. `docs/features/active/2026-11-04-epic-progress-report-script-1080/policy-audit.2026-11-06T00-11.md`
4. `docs/features/active/2026-11-04-epic-progress-report-script-1080/feature-audit.2026-11-06T00-11.md`

## Review files committed in this task

All four review inputs and the plan were untracked at the start of this task and are committed in the P0-T1 commit:

- `remediation-inputs.2026-11-06T00-11.md`
- `code-review.2026-11-06T00-11.md`
- `policy-audit.2026-11-06T00-11.md`
- `feature-audit.2026-11-06T00-11.md`
- `remediation-plan.2026-11-06T00-11.md` (with the two preflight fixes recorded in `evidence/other/preflight-fixes.2026-11-06T00-29.md`, committed with it)

## Notes

- Scope: CR-1 (feature-summary table only) and the wave-cell overflow Nit, inside the four change-set files.
- Constraints carried forward: no `issue.md` acceptance-criterion change, no Python, no `.claude/rules` or `.github/instructions` edit, per-file line coverage at or above 85%, file sizes below the 700 advisory tier where possible.
