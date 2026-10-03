# r1 Phase 9 — acceptance-criteria re-verification and check-off (issue #824, remediation cycle 1)

Timestamp: 2026-10-03T13-43
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p9-t1.ps1 -Worktree WORKTREE (P9-T1 count check, run after the re-verification lines were written); later sections record P9-T2 to P9-T14 and P9-T16
EXIT_CODE: 0
Output Summary: P9-T1 printed REVERIFIED=27 REGRESSED-COUNT=0 CHECKED=27; the re-verification lines below name a passing remediation-cycle-1 artifact for every criterion checked at P0-T1.

## P9-T1 re-verification (criteria checked at P0-T1)

RE-VERIFIED AC-1: FEATURE/evidence/qa-gates/r1-ac1-ac2.2026-10-03T13-22.md (RAWINVOCATION=1, RAWCONTAINMENT=0 in both roots; hook-command-invocation.ps1 unchanged)
RE-VERIFIED AC-2: FEATURE/evidence/qa-gates/r1-ac1-ac2.2026-10-03T13-22.md (the same four Test-CommandLineRawContainment locations; CLAUDE-RAW and CODEX-RAW contribute none)
RE-VERIFIED AC-3: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md (P824-A1, P824-A2, P824-D1 to P824-D11 PASSED in S1 and S2); FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-4: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t4.2026-10-03T13-06.md (U1 51 passed); FEATURE/evidence/other/r1-p2-t5.2026-10-03T13-07.md (U2 51 passed, EQUAL=True)
RE-VERIFIED AC-5: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-6: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-7: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-8: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-9: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-10: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-11: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-12: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-13: FEATURE/evidence/regression-testing/r1-pass-after-pester.2026-10-03T13-19.md; FEATURE/evidence/other/r1-p2-t6.2026-10-03T13-07.md
RE-VERIFIED AC-15: FEATURE/evidence/regression-testing/r1-hook-suites-full.2026-10-03T13-20.md (3636 passed, 0 failed)
RE-VERIFIED AC-16: FEATURE/evidence/regression-testing/r1-hook-suites-full.2026-10-03T13-20.md; FEATURE/evidence/qa-gates/r1-test-integrity.2026-10-03T13-22.md (NAMED=11 BAD-DELETES=0 SET-DIFFERENCES=0)
RE-VERIFIED AC-17: FEATURE/evidence/regression-testing/r1-hook-suites-full.2026-10-03T13-20.md; FEATURE/evidence/other/r1-call-site-derivation.2026-10-03T13-23.md (CALL-SITES=37 FILES=13) and the addendum in FEATURE/evidence/other/containment-path-hook-audit.md
RE-VERIFIED AC-18: FEATURE/evidence/regression-testing/r1-hook-suites-full.2026-10-03T13-20.md
RE-VERIFIED AC-19: FEATURE/evidence/regression-testing/r1-hook-suites-full.2026-10-03T13-20.md
RE-VERIFIED AC-20: FEATURE/evidence/regression-testing/r1-hook-suites-full.2026-10-03T13-20.md
RE-VERIFIED AC-21: FEATURE/evidence/regression-testing/r1-hook-suites-full.2026-10-03T13-20.md
RE-VERIFIED AC-22: FEATURE/evidence/qa-gates/r1-ac22.2026-10-03T13-22.md (HITS=0, FILES-SCANNED=194 > 192)
RE-VERIFIED AC-23: FEATURE/evidence/qa-gates/r1-ac23-ac24.2026-10-03T13-22.md; FEATURE/evidence/qa-gates/r1-identity.2026-10-03T13-41.md; FEATURE/evidence/other/r1-p6-t3.2026-10-03T13-18.md
RE-VERIFIED AC-24: FEATURE/evidence/qa-gates/r1-ac23-ac24.2026-10-03T13-22.md; FEATURE/evidence/qa-gates/r1-identity.2026-10-03T13-41.md; FEATURE/evidence/other/r1-p6-t3.2026-10-03T13-18.md
RE-VERIFIED AC-25: FEATURE/evidence/qa-gates/r1-ac25.2026-10-03T13-23.md (LEGACY 43 passed, 497 lines, unchanged)
RE-VERIFIED AC-26: FEATURE/evidence/qa-gates/r1-poshqc-format.2026-10-03T13-28.md; FEATURE/evidence/qa-gates/r1-poshqc-analyze.2026-10-03T13-29.md; FEATURE/evidence/qa-gates/r1-poshqc-test.2026-10-03T13-31.md; FEATURE/evidence/qa-gates/r1-coverage-delta.2026-10-03T13-40.md
RE-VERIFIED AC-28: FEATURE/evidence/qa-gates/r1-line-counts.2026-10-03T13-41.md
RE-VERIFIED AC-29: FEATURE/evidence/qa-gates/r1-ac29.2026-10-03T13-22.md (PINS=5, S3 unchanged)

## P9-T2 to P9-T14 check-offs
CHECKED-OFF AC-14 (P9-T2, step script SCRATCH/steps/r1-p9-t2.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-expect-fail-pester.2026-10-03T13-01 and r1-pass-after-pester.2026-10-03T13-19 (P824-D12 to P824-D15 in S1 and S2; R824-P21 to R824-P25 in U1 and U2; A824-WT8 in S6, S7, S8); unchanged prior rows P824-D8, P824-D9, P824-D10, P824-A3 PASSED in r1-pass-after-pester
CHECKED-OFF AC-30 (P9-T3, step script SCRATCH/steps/r1-p9-t3.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-pass-after-pester.2026-10-03T13-19 (A824-WT3 PASSED in S6, S7, S8); fail-before-exception.2026-10-03T13-03
CHECKED-OFF AC-31 (P9-T4, step script SCRATCH/steps/r1-p9-t4.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-expect-fail-pester.2026-10-03T13-01 and r1-pass-after-pester.2026-10-03T13-19 (A824-WT4-1 to -5 and A824-WT5-1 to -5 in S6, S7, S8; R824-W1 to R824-W5 in U1 and U2); r1-p3-t4.2026-10-03T13-09
CHECKED-OFF AC-32 (P9-T5, step script SCRATCH/steps/r1-p9-t5.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-expect-fail-pester.2026-10-03T13-01 and r1-pass-after-pester.2026-10-03T13-19 (A824-WT3 negative control asserting Test-CommandLineRawContainment true; A824-WT6 to A824-WT9)
CHECKED-OFF AC-33 (P9-T6, step script SCRATCH/steps/r1-p9-t6.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): qa-gates r1-poshqc-format.2026-10-03T13-28, r1-poshqc-analyze.2026-10-03T13-29, r1-poshqc-test.2026-10-03T13-31, r1-coverage-delta.2026-10-03T13-40
CHECKED-OFF AC-34 (P9-T7, step script SCRATCH/steps/r1-p9-t7.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-expect-fail-pester.2026-10-03T13-01 and r1-pass-after-pester.2026-10-03T13-19 (F824-1, F824-2, F824-3); r1-p4-t2.2026-10-03T13-11 (U3 7 passed); r1-p4-t3.2026-10-03T13-11 (docstring: RETIRED=0, FALLBACK=1); r1-coverage-delta.2026-10-03T13-40 (FR-HOOK 95.28, FR-THRESH 100)
CHECKED-OFF AC-35 (P9-T8, step script SCRATCH/steps/r1-p9-t8.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-expect-fail-pytest.2026-10-03T13-02 and r1-pass-after-pytest.2026-10-03T13-19 (test_listed_copy_names_no_consuming_product, 6 nodes); r1-p5-t1 to r1-p5-t3 (2026-10-03T13-13)
CHECKED-OFF AC-36 (P9-T9, step script SCRATCH/steps/r1-p9-t9.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-expect-fail-pytest.2026-10-03T13-02 and r1-pass-after-pytest.2026-10-03T13-19 (test_surface_does_not_hard_code_solution_file, 14 nodes; test_pushed_roots_carry_no_hard_coded_solution_file); r1-p5-t4 to r1-p5-t10 (2026-10-03T13-13); r1-p5-t11.2026-10-03T13-14; r1-p6-t3.2026-10-03T13-18 (parity exit 0); r1-pytest.2026-10-03T13-40
CHECKED-OFF AC-37 (P9-T10, step script SCRATCH/steps/r1-p9-t10.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-expect-fail-pytest.2026-10-03T13-02 and r1-pass-after-pytest.2026-10-03T13-19 (test_review_workflow_step_eight_uses_governing_thresholds, 2 nodes); r1-p5-t12.2026-10-03T13-14
CHECKED-OFF AC-38 (P9-T11, step script SCRATCH/steps/r1-p9-t11.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-expect-fail-pytest.2026-10-03T13-02 and r1-pass-after-pytest.2026-10-03T13-19 (test_precedence_copy_states_per_metric_fallback, 14 nodes); r1-p5-t13 to r1-p5-t18 (2026-10-03T13-15); r1-p4-t3.2026-10-03T13-11
CHECKED-OFF AC-39 (P9-T12, step script SCRATCH/steps/r1-p9-t12.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-p5-t19.2026-10-03T13-16 (81 passed; numstat 31/1); r1-p6-t3.2026-10-03T13-18 (guards 121 passed); fail-before-exception-ac39.2026-10-03T13-16
CHECKED-OFF AC-40 (P9-T13, step script SCRATCH/steps/r1-p9-t13.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): r1-p5-t21.2026-10-03T13-17 (RESOLVED=4, OPEN=1, heading-to-status map)
CHECKED-OFF AC-41 (P9-T14, step script SCRATCH/steps/r1-p9-t14.ps1, TS=2026-10-03T13-44, CHECKED=1, EXIT_CODE=0): every P8 artifact of loop pass 2 (qa-gates r1-*.2026-10-03T13-28 to 13-42) and r1-qc-loop-complete.2026-10-03T13-42

## P9-T16 pending CI

PENDING-CI AC-27: left unchecked. AC-27 depends on the poshqc / PowerShell QC job (windows-latest, every suite with coverage) and the poshqc / PowerShell hook suites (Linux) job (ubuntu-latest, tests/scripts/claude-hooks and tests/scripts/codex-hooks, coverage disabled) of .github/workflows/_poshqc.yml, and on the rest of the repository CI on the PR head. It is checked off at orchestration step S9 after the CI green gate.

P9-T16 result (SCRATCH/steps/r1-p9-t16.ps1, TS=2026-10-03T13-45, EXIT_CODE=0): CHECKED=40, UNCHECKED=1, AC27-UNCHECKED=1; re-run P8-T18 commands printed no file-name line, HOSTPATH-GREP-EXIT=1, JUNIT-COUNT=0.
