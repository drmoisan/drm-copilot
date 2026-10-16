# R3 scratch tools (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T11-56
Command: grep -c -F -e 'def find_classes' SCRATCH/r3/read_coverage_927.py
EXIT_CODE: 0
Output Summary: Five scratch files written with the Write tool outside the repository, copied from the cited appendices (plan.2026-10-15T07-41.md Appendix S; remediation-plan.2026-10-16T05-25.md Appendix S2; remediation-plan.2026-10-16T11-20.md Appendices A1, A2, A3). Each token grep prints 1; the shell wrapper contains 0 carriage returns.

WRITE: SCRATCH/r3/read_coverage_927.py (Appendix S of FEATURE/plan.2026-10-15T07-41.md, section 14)
WRITE: SCRATCH/r3/read_report_totals_927.py (Appendix S2 of FEATURE/remediation-plan.2026-10-16T05-25.md, section 12)
WRITE: SCRATCH/r3/read_hook_aggregate_927.py (Appendix A1 of FEATURE/remediation-plan.2026-10-16T11-20.md)
WRITE: SCRATCH/r3/run-poshqc-927.ps1 (Appendix A2 of FEATURE/remediation-plan.2026-10-16T11-20.md)
WRITE: SCRATCH/r3/run-poshqc-927.sh (Appendix A3 of FEATURE/remediation-plan.2026-10-16T11-20.md)

COUNT_FIND_CLASSES: 1
Command 2: grep -c -F -e 'def report_line' SCRATCH/r3/read_report_totals_927.py
EXIT_CODE_2: 0
COUNT_REPORT_LINE: 1
Command 3: grep -c -F -e 'HOOK_AGGREGATE_LINE: counters=' SCRATCH/r3/read_hook_aggregate_927.py
EXIT_CODE_3: 0
COUNT_HOOK_AGGREGATE: 1
Command 4: grep -c -F -e 'Invoke-PoshQCTest -Root $root' SCRATCH/r3/run-poshqc-927.ps1
EXIT_CODE_4: 0
COUNT_INVOKE_POSHQC_TEST: 1
Command 5: grep -c -F -e 'POSHQC_EXIT_CODE=' SCRATCH/r3/run-poshqc-927.sh
EXIT_CODE_5: 0
COUNT_POSHQC_EXIT_CODE: 1
Command 6: awk '/\r/{n++} END{print n+0}' SCRATCH/r3/run-poshqc-927.sh
EXIT_CODE_6: 0
CARRIAGE_RETURN_LINES: 0
