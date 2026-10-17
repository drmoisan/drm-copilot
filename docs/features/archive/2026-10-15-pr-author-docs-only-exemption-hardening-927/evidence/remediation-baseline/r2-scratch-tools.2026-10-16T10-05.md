# R2 Scratch Tools (Issue #927)

Timestamp: 2026-10-16T10-05
Command: grep -c -F -e 'def find_classes' SCRATCH/927/tools/read_coverage_927.py
EXIT_CODE: 0
Output Summary: Five scratch files written outside the repository with the Write tool (LF line endings, not committed). Each identity grep printed 1; the shell wrapper contains 0 carriage returns.

## Files written

- `SCRATCH/927/tools/read_coverage_927.py` (Appendix S of `plan.2026-10-15T07-41.md`, section 14, exact content)
- `SCRATCH/927/tools/read_report_totals_927.py` (Appendix S2 of `remediation-plan.2026-10-16T05-25.md`, section 12, exact content)
- `SCRATCH/927/tools/read_hook_aggregate_927.py` (Appendix A1)
- `SCRATCH/927/r2/run-poshqc-927.ps1` (Appendix A2)
- `SCRATCH/927/r2/run-poshqc-927.sh` (Appendix A3)

## Verification

- Command 1: `grep -c -F -e 'def find_classes' SCRATCH/927/tools/read_coverage_927.py`
  - EXIT_CODE_1: 0
  - Output: `1`
- Command 2: `grep -c -F -e 'def report_line' SCRATCH/927/tools/read_report_totals_927.py`
  - EXIT_CODE_2: 0
  - Output: `1`
- Command 3: `grep -c -F -e 'HOOK_AGGREGATE_LINE: counters=' SCRATCH/927/tools/read_hook_aggregate_927.py`
  - EXIT_CODE_3: 0
  - Output: `1`
- Command 4: `grep -c -F -e 'Invoke-PoshQCTest -Root $root' SCRATCH/927/r2/run-poshqc-927.ps1`
  - EXIT_CODE_4: 0
  - Output: `1`
- Command 5: `grep -c -F -e 'POSHQC_EXIT_CODE=' SCRATCH/927/r2/run-poshqc-927.sh`
  - EXIT_CODE_5: 0
  - Output: `1`
- Command 6: `awk '/\r/{n++} END{print n+0}' SCRATCH/927/r2/run-poshqc-927.sh`
  - EXIT_CODE_6: 0
  - Output: `0`
