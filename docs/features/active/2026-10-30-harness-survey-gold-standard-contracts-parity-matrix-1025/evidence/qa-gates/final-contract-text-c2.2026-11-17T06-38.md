# Final Contract Text — Remediation Cycle 2 (Issue 1025, [P2-T4])

Timestamp: 2026-11-17T06-37
Head: ca9845148acd68c9fc02ff2adb3754d9af6606bb (Phase 1 commit; the contract files are unchanged since it)
Command: `sh SCRATCH/issue-1025-textcheck.sh all` (Text Checks (a), (b) and (c) over all 65 contracts and both trees)
EXIT_CODE: 1 (the script exits with the status of its final grep guard: 1 means the last grep matched nothing; the pass criteria are 0 violations, 0 differing pairs and each grep exit 1 with 0 lines)
Output Summary: 65 contracts x 2 copies, 0 lint violations; 65 cmp pairs, 0 differing; every regression grep exits 1 with empty output in both trees, including the R3–R5 grep (11 lines per tree in [P0-T1], now 0). Source-check rows across the Phase 1 task-check records: 88 = 32 named + 56 sweep fixes.

## (a) Contract lint

Command: `sh SCRATCH/issue-1025-lint-contracts.sh <all 65 names>` (`Get-HarnessSkillContractViolation` from `scripts/harness/HarnessSkillContract.psm1`, base and bundle copy)
EXIT_CODE: 0
Output: `CONTRACTS_CHECKED: 65 (x2 copies)`, `VIOLATIONS: 0`

## (b) Mirror identity

Command: `cmp -s` of each of the 65 base contracts against its bundle twin
EXIT_CODE: 0
Output: `PAIRS=65 DIFFERING=0`

## (c) Regression greps (per tree)

| Grep | Base tree exit / lines | Bundle tree exit / lines | [P0-T1] lines per tree |
| --- | --- | --- | --- |
| 1 (cycle 1 R1 form) | 1 / 0 | 1 / 0 | 0 |
| 1 (inputs R1 form, with `listed below`) | 1 / 0 | 1 / 0 | 0 |
| 2 (R2) | 1 / 0 | 1 / 0 | 0 |
| 3 (cycle 1 sweep) | 1 / 0 | 1 / 0 | 0 |
| 4 (forbidden tokens) | 1 / 0 | 1 / 0 | 0 |
| R3–R5 (Verification Command 3) | 1 / 0 | 1 / 0 | 11 |

## Source-Check Rows (Phase 1 task-check records)

| Record | Rows | Basis |
| --- | --- | --- |
| `evidence/other/task-check.P1-T1.2026-11-17T05-08.md` | 10 | R3 8 (CR-9) + D-C2-1 2 |
| `evidence/other/task-check.P1-T2.2026-11-17T05-15.md` | 9 | R4 part 1 (CR-10) |
| `evidence/other/task-check.P1-T3.2026-11-17T05-22.md` | 8 | R4 part 2 (CR-10) |
| `evidence/other/task-check.P1-T4.2026-11-17T05-25.md` | 4 | R5 (CR-11) |
| `evidence/other/task-check.P1-T5.2026-11-17T05-29.md` | 1 | CR-14 (D-C2-2) |
| `evidence/other/task-check.P1-T7.2026-11-17T05-40.md` | 56 | sweep fixes (`sweep-fixes.2026-11-17T05-40.md`: 56) |
| Total | 88 | 32 named (29 findings, 2 under D-C2-1, 1 under CR-14) + 56 sweep fixes |

Acceptance: 0 lint violations and no differing `cmp` pair among 65; every grep exits 1 with empty output (R3–R5 was 11 lines per tree in [P0-T1]); source-check rows 32 named plus the `sweep-fixes` count (56). PASS.
