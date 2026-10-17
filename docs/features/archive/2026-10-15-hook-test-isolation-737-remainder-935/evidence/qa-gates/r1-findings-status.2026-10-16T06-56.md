# R1 Findings Ledger (P5-T4)

Timestamp: 2026-10-16T06-56
Command: ledger of the nine findings closed or dispositioned by remediation cycle R1
EXIT_CODE: 0
Output Summary: nine findings, each listed once; seven FIXED or NO-CHANGE dispositions from Phases 1-3, and COV-1 recorded as a population mismatch awaiting CI.

- COV-1: COV-1-OUTCOME: MEASUREMENT-POPULATION-MISMATCH (DENOMINATOR); COV-1-STATUS: awaiting_ci (P7-T6, AC-24). Local post-change covered 11598, missed 682, denominator 12280, 94.45% vs baseline 90.42% over 18116. Evidence: `qa-gates/coverage-comparison.2026-10-16T06-56.md`, `qa-gates/r1-coverage-run.2026-10-16T06-56.md`, `qa-gates/r1-coverage-pre.2026-10-16T06-28.md`, `baseline/r1-coverage-baseline.2026-10-16T04-40.md`, `baseline/r1-coverage-population.2026-10-16T04-39.md`.
- CR-N1: FIXED (P1-T1). Evidence: `qa-gates/r1-p1-ps-test.2026-10-16T05-30.md`.
- CR-N2: FIXED (P2-T1, P2-T2, P2-T3). Evidence: `qa-gates/r1-p2-ps-test.2026-10-16T05-46.md`.
- CR-N3: FIXED (P3-T1, P3-T3). Evidence: `regression-testing/r1-cr-n3-fail-before.2026-10-16T05-56.md`, `qa-gates/r1-fixture-names.2026-10-16T05-47.md`, `qa-gates/r1-p3-ps-test.2026-10-16T06-09.md`.
- CR-N4: NO-CHANGE (disposition, r1-dispositions). Evidence: `other/r1-dispositions.2026-10-16T05-13.md`.
- CR-N5: FIXED (P1-T2). Evidence: `qa-gates/r1-p1-ps-test.2026-10-16T05-30.md`.
- CR-N6: FIXED (P1-T3). Evidence: `other/r1-dispositions.2026-10-16T05-13.md`, `qa-gates/r1-p1-ps-test.2026-10-16T05-30.md`.
- CR-N7: NO-CHANGE (disposition, r1-dispositions). Evidence: `other/r1-dispositions.2026-10-16T05-13.md`.
- CR-N8: FIXED (P2-T4). Evidence: `qa-gates/r1-p2-ps-test.2026-10-16T05-46.md`.

Every FIXED task's acceptance held and is checked off in `remediation-plan.2026-10-16T03-40.md`. The Phase 4 final QA loop (`qa-gates/r1-loop-status.2026-10-16T06-26.md`) passed in one pass after all fixes.
