# Windows PowerShell QC Log Result (P4-T8, AC-7)

Timestamp: 2026-10-01T20-23
RUN_ID: 36918378249; WINDOWS_JOB_ID: 110557965705; conclusion `success`.

Command: gh run view 36918378249 --log --job 110557965705 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: exactly one line: `Tests Passed: 6091, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0` (ANSI color codes removed in this record).

The Windows job did not fail, so no `[-]` failing-test filter is recorded.

Acceptance: exactly one line containing `Failed: 0,`. Met.
