# Post-Change Historical-Runs Timing (P2-T5)

Timestamp: 2026-09-29T19-50
Command: sh SCRATCH/run-ps.sh SCRATCH/timing.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -Runs 3
EXIT_CODE: 0
Output Summary:
- A8 run in the background; no other command was started during the run.
- PESTER-VERSION=5.6.1, equal to the P0-T10 value.
- CODE-COVERAGE-ENABLED=False
- Elapsed seconds: run 1 = 82.05, run 2 = 82.86, run 3 = 69.8. Median = 82.05 s.
- All three runs: Total=9 Passed=9 Failed=0.
- Result: PASS for this task's acceptance condition. The AC-2 ratio is evaluated in P2-T6.

Full A8 output:

```
PESTER-VERSION=5.6.1
CODE-COVERAGE-ENABLED=False
RUN index=1 ElapsedSeconds=82.05 Total=9 Passed=9 Failed=0
RUN index=2 ElapsedSeconds=82.86 Total=9 Passed=9 Failed=0
RUN index=3 ElapsedSeconds=69.8 Total=9 Passed=9 Failed=0
MEDIAN-SECONDS=82.05
```
