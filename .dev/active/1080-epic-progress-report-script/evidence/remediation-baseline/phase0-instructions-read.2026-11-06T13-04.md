# Phase 0 Policy Reading — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-04
Plan: docs/features/active/2026-11-04-epic-progress-report-script-1080/remediation-plan.2026-11-06T12-43.md
Task: P0-T1
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/quality-tiers.md -> .claude/rules/powershell.md -> .github/copilot-instructions.md -> .github/instructions/general-code-change.instructions.md -> .github/instructions/general-unit-test.instructions.md -> .github/instructions/powershell-code-change.instructions.md -> .github/instructions/powershell-unit-test.instructions.md

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

1. `remediation-inputs.2026-11-06T12-43.md` (NB-1 Minor, NB-2 Nit, NB-3 Nit; sweep and three-mutant verification)
2. `code-review.2026-11-06T12-43.md` (verdict Go; NB-1 to NB-3 plus four Info items)
3. `policy-audit.2026-11-06T12-43.md` (Ready for PR; NB-1 to NB-3 open, non-blocking)
4. `feature-audit.2026-11-06T12-43.md` (0 PARTIAL, 0 FAIL; NB-1 to NB-3 listed)

## Key constraints applied

- Fail fast with clear terminating errors (general code change policy, Error Handling).
- Pester 5 tests, one behavior per `It`, no temporary files, in-memory fixtures (PowerShell and general unit test policies).
- Line coverage at or above 85% per production file; no PowerShell branch gate.
- File size: 500 guidance, 700 advisory, above 800 blocked.
- `quality-tiers.yml` classifies `scripts/dev-tools` as T4 (per the policy audit), so no property, mutation, or golden obligation.

## Files committed in this task

- `remediation-inputs.2026-11-06T12-43.md`
- `code-review.2026-11-06T12-43.md`
- `policy-audit.2026-11-06T12-43.md`
- `feature-audit.2026-11-06T12-43.md`
- `remediation-plan.2026-11-06T12-43.md` (with the preflight fix and the P0-T1 checkbox)
- `evidence/other/preflight-fixes.2026-11-06T13-03.md`
- this artifact
