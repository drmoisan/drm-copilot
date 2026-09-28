# Full Tree, One Process, Coverage On, As CI Runs It (Remediation Cycle 1, P2-T5)

Timestamp: 2026-09-27T20-16
Command: sh SCRATCH/run-ps.sh SCRATCH/poshqc-ci-mirror.ps1 -Root "."   (Bash tool, run_in_background; output redirected to SCRATCH/rem-p2-ci-mirror.txt)
EXIT_CODE: 0

## Summary lines (verbatim; ANSI colour codes removed from the "Tests Passed:" line)

```text
PESTER-VERSION 5.6.1
PESTER-FAILED-TOTAL=0
Tests Passed: 5550, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
JUNIT-SUMMARY CaseCount=5559 FailedCount=0
```

JUNIT-FAILED lines: none.

The run printed "Starting code coverage." and "Processing code coverage result." (coverage was enabled by the repository runsettings, as in CI) and completed in 464.99 s.

## Acceptance (clean case)

- PESTER-VERSION reads 5.6.1: yes.
- Exit 0: yes.
- PESTER-FAILED-TOTAL=0: yes.
- JUNIT-SUMMARY FailedCount=0: yes.
- CaseCount at least PRE_CASES plus 1 (5558 + 1 = 5559): yes, CaseCount=5559.
- "Tests Passed:" line carries "Failed: 0": yes.

## Comparison with the fail-before run (P0-T14)

| Measure | P0-T14 (before) | P2-T5 (after) |
| --- | --- | --- |
| Exit code | 1 | 0 |
| PESTER-FAILED-TOTAL | 35 | 0 |
| Tests Passed / Failed | 5514 / 35 | 5550 / 0 |
| JUNIT-SUMMARY CaseCount / FailedCount | 5558 / 35 | 5559 / 0 |

All 35 pre-fix failures (26 scheduling, 6 historical-runs, 2 write-intent, 1 guard) now pass in the same one-process, coverage-on invocation that CI uses.

Output Summary: PASS (clean case). Exit 0; PESTER-VERSION 5.6.1; PESTER-FAILED-TOTAL=0; "Tests Passed: 5550, Failed: 0"; JUNIT-SUMMARY CaseCount=5559 FailedCount=0; no JUNIT-FAILED line.
