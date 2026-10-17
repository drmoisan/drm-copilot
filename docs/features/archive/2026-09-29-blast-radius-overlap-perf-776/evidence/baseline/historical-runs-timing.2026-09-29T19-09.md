# Baseline Historical-Runs Timing (P0-T10)

Timestamp: 2026-09-29T19-09
Command: git status --porcelain -- .claude/lib/blast-radius; sh SCRATCH/run-ps.sh SCRATCH/timing.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -Runs 3
EXIT_CODE: 0
Output Summary:
- git status --porcelain -- .claude/lib/blast-radius: no output (exit 0); modules unmodified at BASE_SHA 43c9e95eaa39b3d896a9da5501cd57953033c2bc.
- A8 run in the background; no other command was started during the run.
- Elapsed seconds: run 1 = 214.04, run 2 = 213.12, run 3 = 213.02. Median = 213.12 s.
- All three runs: Total=9 Passed=9 Failed=0. Coverage disabled.
- Result: PASS.

Full A8 output:

```
PESTER-VERSION=5.6.1
CODE-COVERAGE-ENABLED=False
RUN index=1 ElapsedSeconds=214.04 Total=9 Passed=9 Failed=0
RUN index=2 ElapsedSeconds=213.12 Total=9 Passed=9 Failed=0
RUN index=3 ElapsedSeconds=213.02 Total=9 Passed=9 Failed=0
MEDIAN-SECONDS=213.12
```
