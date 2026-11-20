# Final QA — two-tree single-process run, restart pass (P3-T3)

Timestamp: 2026-11-04T16-03
Command: sh SCRATCH/issue-1067-runpaths.sh qa2-twotrees "tests/scripts/dev-tools,tests/scripts/powershell/PoshQC" (one fresh pwsh -NoProfile process, sorted file order, no shuffle)
EXIT_CODE: 0

```
TOTAL Tests=953 Passed=944 Failed=0 Skipped=9 NotRun=0
CONTAINERS Total=61 Failed=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent
PROBE GH-FUNCTION=absent
```

All 61 `FILE` lines report `failed=0` (lines with a non-zero failed value: 0). The 9 skipped tests are the pre-existing skips of the P0-T8 baseline, outside the change set.

Output Summary: Tests=953 (equal to P0-T8), Failed=0, every FILE line failed=0, and both probes absent at the end of the run (P0-T8: =1 and present).
