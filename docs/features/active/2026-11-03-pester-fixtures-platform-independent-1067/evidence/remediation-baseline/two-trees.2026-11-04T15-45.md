# Baseline — two-tree single-process run (P0-T8)

Timestamp: 2026-11-04T15-45
Command: sh SCRATCH/issue-1067-runpaths.sh base-twotrees "tests/scripts/dev-tools,tests/scripts/powershell/PoshQC" (one fresh pwsh -NoProfile process, files in sorted order, no shuffle)
EXIT_CODE: 0

```
TOTAL Tests=953 Passed=944 Failed=0 Skipped=9 NotRun=0
CONTAINERS Total=61 Failed=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=1
PROBE GH-FUNCTION=present
```

Every one of the 61 `FILE` lines reports `failed=0`. The 9 skipped tests are pre-existing skips in suites outside the change set; the five change-set suites report no skipped test.

Output Summary: Tests=953, Failed=0, 61 containers. Both probes show the leaks at the end of the run (POSHQC_SKIP_SCRIPT_EXECUTION=1, GH-FUNCTION=present), the fail-before signal for R1-F1 and R1-F5 at tree scope. Tests=953 is the reference count for P3-T3.
