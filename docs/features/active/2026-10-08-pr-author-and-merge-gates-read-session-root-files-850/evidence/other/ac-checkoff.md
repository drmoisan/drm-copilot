# Acceptance-criteria check-off log (issue #850)

Timestamp: 2026-10-08T23-57
Command: sh SCRATCH/run-ps.sh SCRATCH/checkbox-count.ps1 -Path FEATURE/spec.md -FromLine 204 -Line <lines> (one run per check-off task)
EXIT_CODE: 0
Output Summary:
  Source: FEATURE/spec.md (full-bug; sole AC source). Entries are appended per check-off task.

## P1-T13 (2026-10-08T23-57)

- AC-30 (spec line 248): checked. Evidence: P1-T9 `evidence/regression-testing/cr4-pass-after.2026-10-08T23-55.md` (B14 passes; FailedCount=0), fail-before P1-T2 `evidence/regression-testing/cr4-fail-before.2026-10-08T23-52.md`.
- AC-31 (spec line 249): checked. Evidence: P1-T9 `evidence/regression-testing/cr4-pass-after.2026-10-08T23-55.md` (B11, B12, X1 pass); export count 7 unchanged (P1-T3 LOAD-CHECK ExportCount=7).
- A14 output: `CHECKBOX checked=2 unchecked=45`, `LINE n=248 state=checked`, `LINE n=249 state=checked`.

## P2-T14 (2026-10-09T00-01)

- AC-32 (spec line 253): checked. Evidence: P2-T9 `evidence/regression-testing/cr5-parallel-pass-after.2026-10-08T23-59.md` (Y7 passes; FailedCount=0); fail-before P2-T2 `evidence/regression-testing/cr5-parallel-fail-before.2026-10-08T23-57.md`.
- AC-33 (spec line 254): checked. Evidence: P2-T10 `evidence/qa-gates/pester-set-rem-p2.2026-10-08T23-59.md` (224/224 pass) and P2-T11 `evidence/qa-gates/cr5-parallel-unchanged-rows.2026-10-09T00-00.md` (Tests.ps1 diff exit 0; WorktreeResolution suite removed=0).
- A14 output: `CHECKBOX checked=4 unchecked=43`, `LINE n=253 state=checked`, `LINE n=254 state=checked`.

## P3-T16 (2026-10-09T00-08)

- AC-34 (line 255), AC-35 (line 259), AC-36 (line 260), AC-37 (line 261): checked. Evidence: P3-T11 `evidence/regression-testing/erem-diagnostics-pass-after.2026-10-09T00-06.md` (T-EREM-DX 8/8 pass); fail-before P3-T2 `evidence/regression-testing/erem-diagnostics-fail-before.2026-10-09T00-02.md` (8/8 fail).
- AC-38 (line 262): checked. Evidence: P3-T12 `evidence/qa-gates/pester-set-rem-p3.2026-10-09T00-06.md` (232/232 pass) and P3-T13 `evidence/qa-gates/erem-decision-unchanged.2026-10-09T00-07.md` (three suites added=0 removed=0; Tests.ps1 added=1 removed=0).
- A14 output: `CHECKBOX checked=9 unchecked=38`; lines 255, 259, 260, 261, 262 `state=checked`.

## P4-T13 (2026-10-09T00-13)

- AC-15 (line 227), AC-16 (line 228), AC-17 (line 229), AC-18 (line 230): checked. Evidence: P4-T9 `evidence/regression-testing/wir-prnumber-pass-after.2026-10-09T00-12.md` (T-WIR-PR 11/11 pass); fail-before P4-T2 `evidence/regression-testing/wir-prnumber-fail-before.2026-10-09T00-09.md` (11/11 fail); P4-T10 SET-LIB 266/266.
- A14 output: `CHECKBOX checked=13 unchecked=34`; lines 227-230 `state=checked`.

## P5-T17 (2026-10-09T00-25)

- AC-19 to AC-24 (lines 231-236) and AC-26 to AC-29 (lines 241-244): checked. Evidence: P5-T12 `evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md` (T-MRG-IR 19/19 pass, after the WIR corrective re-Write recorded in WLOG entry 8); fail-before P5-T2 `evidence/regression-testing/merge-item-fail-before.2026-10-09T00-15.md`; P5-T13 `evidence/regression-testing/merge-worktree-resolution-p5.2026-10-09T00-22.md` (M5 and M6, 10/10 pass).
- AC-25 (line 237): checked. Evidence: P5-T14 `evidence/qa-gates/pester-set-mrg-p5.2026-10-09T00-23.md` (SET-MRG 160/160; no rule CR update).
- A14 output: `CHECKBOX checked=24 unchecked=23`; lines 231-237 and 241-244 `state=checked`.
