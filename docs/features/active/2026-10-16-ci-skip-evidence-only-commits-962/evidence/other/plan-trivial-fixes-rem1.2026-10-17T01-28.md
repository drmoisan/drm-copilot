# Preflight trivial fixes — remediation plan cycle 1 (issue #962)

Timestamp: 2026-10-17T01-28
Command: preflight review of remediation-plan.2026-10-17T01-20.md against the tree at f31be197980abba0ec4f2c249a2ba1e7371556d7
EXIT_CODE: 0
Output Summary: PREFLIGHT: ALL CLEAR. No plan text was edited. One observation is recorded; it needs no edit.

## Citations re-derived

- `.github/workflows/_security-scan.yml` lines 41-43 (plugin step), 45-50 (scan step), line 47 `        shell: bash`, line 48 `        run: |`; 50 lines total; LF endings. Matches RPD-1 and P1-T3.
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` line 308 (old `It` name verbatim), line 315 (`continue-on-error` count assertion), lines 309-319, line 321 (closing brace), lines 322-323, 323 lines total; LF endings. Matches RPD-2, section 4, and P1-T1.
- Helpers `Get-TestJobLine`, `Get-TestStepBlock`, `Get-TestStepName` (lines 26-69): lines are `TrimEnd()`ed and step blocks start at `      - `, so the new assertions (a) and (b) fail before P1-T3 and pass after it. Rows W9, W10, W14 for `_security-scan.yml` (lines 196, 210, 252) are unaffected by the inserted line.
- `.github/workflows/README.md` line 139 `### Security scan`, line 140 empty, line 141 old body, 141 lines total; line 115 carries `continue-on-error: true`. Matches RPD-4 and P1-T5.
- Reference plan `plan.2026-10-16T10-27.md` section 5 recipes (line 137 onward), CR-README (line 600), section 10 `### Security scan` (line 1471, body line 1473). CR-README compares only the base prefix and checks tokens in the appended text; line 141 is in the appended text. Matches RPD-4.
- `(AC-18)`, `(AC-19)`, `(AC-20)`, `(AC-21)`, `(AC-36)` Pester rows exist only in `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`; latest `final-pester-list.2026-10-17T00-15.md` reports Totals 5, 9, 21, 3, 1. Matches P2-T4.
- `tests/scripts/workflows/` contains exactly five test files. Matches P0-T4 and P1-T4.
- All 15 P0-T1 policy files exist. `evidence/other/security-scan-findings.2026-10-17T01-18.md` (cited by the README replacement text) exists.
- `.claude/hooks/check-powershell-test-purity.ps1` forbidden patterns (lines 102-119): none occurs in the section 4 replacement block.

## Observation (no edit)

- P0-T2 lists ` M .../spec.md`, `?? .../remediation-inputs.2026-10-17T01-20.md`, and `?? .../remediation-plan.2026-10-17T01-20.md` as permitted porcelain entries. Commit f31be1979 already holds all three, so the porcelain is empty at execution start. The P0-T2 condition is a permitted-set ("every porcelain entry is one of"), and an empty listing satisfies it. P2-T8 likewise permits these entries without requiring them. No edit is required.

## Fixes applied

None.
