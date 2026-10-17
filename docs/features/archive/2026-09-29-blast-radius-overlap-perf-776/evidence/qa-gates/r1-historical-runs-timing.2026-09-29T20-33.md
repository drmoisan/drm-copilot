# Remediation Historical-Runs Timing (P2-T6)

Timestamp: 2026-09-29T20-33
Command: sh SCRATCH/run-ps.sh SCRATCH/timing.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -Runs 3
EXIT_CODE: 0
Output Summary:
- Run in the background and exclusively: no other test, analyzer, formatter, or benchmark command was started during the run.
- PESTER-VERSION=5.6.1 (equals ORIGINAL-BASELINE P0-T10 value 5.6.1); CODE-COVERAGE-ENABLED=False.
- Elapsed seconds: run 1 = 47.18, run 2 = 37.99, run 3 = 40.09. Median = 40.09 s.
- All three runs: Total=9 Passed=9 Failed=0.
- Result: PASS.

Full A8 output:

```
PESTER-VERSION=5.6.1
CODE-COVERAGE-ENABLED=False
RUN index=1 ElapsedSeconds=47.18 Total=9 Passed=9 Failed=0
RUN index=2 ElapsedSeconds=37.99 Total=9 Passed=9 Failed=0
RUN index=3 ElapsedSeconds=40.09 Total=9 Passed=9 Failed=0
MEDIAN-SECONDS=40.09
```
